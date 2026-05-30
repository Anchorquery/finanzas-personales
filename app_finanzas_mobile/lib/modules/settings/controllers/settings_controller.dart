import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:langchain_core/chat_models.dart' as lc;
import 'package:langchain_core/prompts.dart';
import 'package:langchain_google/langchain_google.dart';
import '../../../data/services/directus_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';
import '../../ai_coach/controllers/ai_coach_controller.dart';
import '../../../routes/app_routes.dart';

class SettingsController extends GetxController {
  final DirectusService _directusService = Get.find<DirectusService>();
  final AuthService _authService = Get.find<AuthService>();
  final _storage = GetStorage();
  late final WorkspacesController workspacesController;

  final user = Rxn<User>();
  final apiKey = ''.obs;
  final aiEnabled = false.obs;
  final isLoading = true.obs;
  final isValidatingKey = false.obs;
  final isApiKeyVisible = false.obs;

  // UI State
  final currentThemeMode = ThemeMode.system.obs;
  final notificationsEnabled = true.obs;
  final organizationName = 'Cargando...'.obs;
  final workspaceMembersCount = 0.obs;

  late final TextEditingController apiKeyController;

  @override
  void onInit() {
    super.onInit();
    apiKeyController = TextEditingController();
    if (Get.isRegistered<WorkspacesController>()) {
      workspacesController = Get.find<WorkspacesController>();
    } else {
      workspacesController = Get.put(WorkspacesController());
    }
    _loadPersistedPreferences();
    loadSettings();
  }

  @override
  void onClose() {
    apiKeyController.dispose();
    super.onClose();
  }

  void _loadPersistedPreferences() {
    // LIGHT ONLY (DESIGN.md): app solo claro; no restaurar tema guardado.
    currentThemeMode.value = ThemeMode.light;
    notificationsEnabled.value =
        _storage.read<bool>('notifications_enabled') ?? true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.changeThemeMode(ThemeMode.light);
    });
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      final userData = await _directusService.getCurrentUser();
      user.value = userData;

      final org = await _directusService.getOrganization();
      if (org != null) {
        organizationName.value = org.name;
        final settings =
            await _directusService.getOrganizationSettings(org.id);
        if (settings != null) {
          apiKey.value = settings['gemini_api_key'] ?? '';
          aiEnabled.value = settings['ai_enabled'] ?? false;
          apiKeyController.text = apiKey.value;
        }
      } else {
        organizationName.value = 'Sin Organización';
      }

      _loadMembersCount();
    } catch (e) {
      Get.log('Error loading settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMembersCount() {
    workspaceMembersCount.value = 1;
  }

  // ignore: avoid_unused_constructor_parameters
  void toggleTheme(ThemeMode mode) {
    // LIGHT ONLY (DESIGN.md): tema fijo claro; el toggle queda inerte.
    currentThemeMode.value = ThemeMode.light;
    Get.changeThemeMode(ThemeMode.light);
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    _storage.write('notifications_enabled', value);
    _applyCoachNightly();
  }

  /// Schedules or cancels the nightly Coach reminder based on
  /// [notificationsEnabled].
  Future<void> _applyCoachNightly() async {
    if (!Get.isRegistered<NotificationService>()) return;
    final notif = Get.find<NotificationService>();
    if (notificationsEnabled.value) {
      await notif.scheduleCoachNightly();
    } else {
      await notif.cancelCoachNightly();
    }
  }

  Future<void> saveSettings() async {
    try {
      isLoading.value = true;
      _storage.write('theme_mode', currentThemeMode.value.index);
      _storage.write('notifications_enabled', notificationsEnabled.value);
      SnackbarService.showSuccess('Guardado', 'Ajustes actualizados correctamente');
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudieron guardar los ajustes');
    } finally {
      isLoading.value = false;
    }
  }

  /// Valida la API key con Gemini y la guarda si es válida.
  Future<void> saveAndValidateAISettings() async {
    final key = apiKeyController.text.trim();
    if (key.isEmpty) {
      // Guardar deshabilitado si el campo está vacío
      await saveAISettings('', false);
      return;
    }

    isValidatingKey.value = true;
    try {
      // Ping de validación: envía un mensaje mínimo a Gemini
      final model = ChatGoogleGenerativeAI(
        apiKey: key,
        defaultOptions: const ChatGoogleGenerativeAIOptions(
          model: 'gemini-2.0-flash',
          temperature: 0,
        ),
      );
      await model.invoke(
        PromptValue.chat([lc.ChatMessage.humanText('ping')]),
      );

      // Si no lanzó excepción, la key es válida
      await saveAISettings(key, aiEnabled.value);
      SnackbarService.showSuccess(
        '✅ API Key válida',
        'Gemini configurado correctamente.',
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('API key') || msg.contains('INVALID_ARGUMENT') ||
          msg.contains('API_KEY_INVALID')) {
        SnackbarService.showError(
          '🔑 API Key inválida',
          'Verifica que la key sea correcta en console.cloud.google.com',
        );
      } else if (msg.contains('PERMISSION_DENIED')) {
        SnackbarService.showError(
          '🚫 Sin permisos',
          'La key no tiene acceso a la API de Generative AI.',
        );
      } else {
        SnackbarService.showError(
          'Error de conexión',
          'No se pudo verificar. Revisa tu internet e intenta de nuevo.',
        );
      }
    } finally {
      isValidatingKey.value = false;
    }
  }

  Future<void> saveAISettings(String key, bool enabled) async {
    try {
      final org = await _directusService.getOrganization();
      if (org == null) return;
      final current = await _directusService.getOrganizationSettings(org.id);
      if (current != null) {
        await _directusService.updateOrganizationSettings(current['id'], {
          'gemini_api_key': key,
          'ai_enabled': enabled,
        });
        apiKey.value = key;
        aiEnabled.value = enabled;
        // Invalidate cached API key so AICoachController re-fetches on next init
        if (Get.isRegistered<AICoachController>()) {
          Get.find<AICoachController>().invalidateApiKeyCache();
        } else {
          GetStorage().remove('ai_gemini_key_cached');
        }
        SnackbarService.showSuccess('Guardado', 'Configuración AI actualizada');
      } else {
        SnackbarService.showError(
            'Error', 'No se encontró la configuración de la organización');
      }
    } catch (e) {
      SnackbarService.showError('Error', 'Fallo al guardar: $e');
    }
  }

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title:
            const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
