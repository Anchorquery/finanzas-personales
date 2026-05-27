import 'package:app_finanzas_mobile/core/theme/app_theme.dart';
import 'package:app_finanzas_mobile/core/utils/snackbar_service.dart';
import 'package:app_finanzas_mobile/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import 'package:app_finanzas_mobile/routes/app_routes.dart';
import '../../home/controllers/home_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  if (!isWide)
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                      onPressed: () => Get.find<HomeController>().scaffoldKey.currentState?.openDrawer(),
                    ),
                  Expanded(
                    child: Text(
                      AppL10n.of(context).settingsTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.saveSettings,
                    child: Text(
                      AppL10n.of(context).commonSave,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'ORGANIZACIÓN'),
            const SizedBox(height: 12),
            _buildOrganizationSection(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'INTELIGENCIA ARTIFICIAL'),
            const SizedBox(height: 12),
            _buildAISection(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'APARIENCIA'),
            const SizedBox(height: 12),
            _buildAppearanceSection(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'NOTIFICACIONES'),
            const SizedBox(height: 12),
            _buildNotificationsSection(context),
            const SizedBox(height: 32),
            // Logout option
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.accentRed),
                title: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: AppTheme.accentRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: controller.logout,
              ),
            ),
            const SizedBox(height: 40),
          ],
        );
      }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      final name = user?.firstName ?? '';
      final email = user?.email ?? '';
      final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

      return Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.surfaceDark,
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: AppTheme.avatarBg,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.avatarFg,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (name.isNotEmpty)
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 4),
          if (email.isNotEmpty)
            Text(email, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'PLAN PRO CON IA',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildOrganizationSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Obx(() {
        final orgName = controller.organizationName.value;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.orgGradientStart, AppTheme.orgGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.domain_rounded, // Organization icon
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            orgName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          subtitle: const Text(
            'Configuración de Organización',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          // No trailing icon as user requested not to show workspace/selection
          // trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
          onTap: () {
            Get.toNamed(Routes.organizations);
          },
        );
      }),
    );
  }

  Widget _buildAISection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentAI, AppTheme.accentAIDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Gemini',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Coach IA · Escaneo de recibos',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  final hasKey = controller.apiKey.value.isNotEmpty;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasKey
                          ? AppTheme.accentGreen.withValues(alpha: 0.15)
                          : AppTheme.accentRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasKey ? 'Activo' : 'Sin configurar',
                      style: TextStyle(
                        color:
                            hasKey ? AppTheme.accentGreen : AppTheme.accentRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),

          // AI Enable toggle
          Obx(() => SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: const Text(
                  'Habilitar funciones IA',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Coach financiero y escaneo de recibos',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: controller.aiEnabled.value,
                activeThumbColor: Colors.white,
                activeTrackColor: AppTheme.accentAI,
                inactiveTrackColor: AppTheme.surfaceDark,
                onChanged: (val) => controller.aiEnabled.value = val,
              )),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),

          // API Key field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'API Key de Gemini',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        SnackbarService.showAI(
                          '¿Dónde obtengo la key?',
                          'Ve a aistudio.google.com → Get API Key',
                        );
                      },
                      child: const Text(
                        'Obtener key →',
                        style: TextStyle(
                            color: AppTheme.accentAI,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() => TextField(
                      controller: controller.apiKeyController,
                      obscureText: !controller.isApiKeyVisible.value,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'AIza...',
                        hintStyle: const TextStyle(
                            color: Colors.white24, fontSize: 13),
                        filled: true,
                        fillColor: AppTheme.backgroundDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppTheme.accentAI, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Copiar key
                            if (controller.apiKeyController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.copy_rounded,
                                    size: 16, color: Colors.white38),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: controller.apiKeyController.text));
                                  SnackbarService.showSuccess(
                                      'Copiado', 'API key copiada');
                                },
                              ),
                            // Mostrar/ocultar
                            IconButton(
                              icon: Icon(
                                controller.isApiKeyVisible.value
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 18,
                                color: Colors.white38,
                              ),
                              onPressed: () => controller.isApiKeyVisible
                                  .value = !controller.isApiKeyVisible.value,
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 4),
                const Text(
                  'La key se almacena de forma segura en tu organización.',
                  style: TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Botón validar y guardar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isValidatingKey.value
                        ? null
                        : controller.saveAndValidateAISettings,
                    icon: controller.isValidatingKey.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.verified_rounded, size: 18),
                    label: Text(
                      controller.isValidatingKey.value
                          ? 'Validando...'
                          : 'Validar y Guardar',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentAI,
                      disabledBackgroundColor:
                          AppTheme.accentAI.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dark_mode,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Tema',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildThemeToggle(),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            title: const Text(
              'Icono de App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Predeterminado',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
              ],
            ),
            onTap: () {
              // Navigate to app icon settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.themeToggleBg,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption('Claro', ThemeMode.light),
          _buildThemeOption('Oscuro', ThemeMode.dark),
          _buildThemeOption('Auto', ThemeMode.system),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String label, ThemeMode mode) {
    return GestureDetector(
      onTap: () => controller.toggleTheme(mode),
      child: Obx(() {
        final isSelected = controller.currentThemeMode.value == mode;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.themeToggleSelected
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Obx(
          () => SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            title: const Text(
              'Push Notificaciones',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            subtitle: const Text(
              'Alertas de gastos en tiempo real',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            value: controller.notificationsEnabled.value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.surfaceDark,
            onChanged: (val) => controller.toggleNotifications(val),
          ),
        ),
      ),
    );
  }
}
