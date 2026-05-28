import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_storage.dart';
import 'package:app_finanzas_mobile/data/services/directus_service.dart';
import 'package:app_finanzas_mobile/data/services/auth_service.dart';
import 'package:app_finanzas_mobile/core/utils/snackbar_service.dart';

import '../../../core/widgets/workspaces/workspace_selector_modal.dart';

class WorkspacesController extends GetxController {
  final DirectusService _directusService = Get.find<DirectusService>();
  final AuthService _authService = Get.find<AuthService>();

  final Rx<RxStatus> status = RxStatus.loading().obs;
  final RxList<Workspace> _workspaces = <Workspace>[].obs;
  final Rx<Workspace?> activeWorkspaceRx = Rx<Workspace?>(null);
  Workspace? get activeWorkspace => activeWorkspaceRx.value;

  // Form logic variables
  final RxString newWorkspaceName = ''.obs;
  final RxInt selectedIconCode = Icons.home.codePoint.obs;
  final RxInt selectedColorValue = const Color(0xFF7C3AED).toARGB32().obs;
  final RxBool isShared = false.obs;

  List<Workspace> get workspaces => _workspaces;
  List<Workspace> get visibleWorkspaces {
    final grouped = <String, List<Workspace>>{};

    for (final workspace in _workspaces) {
      final key = [
        workspace.organizationId ?? '',
        workspace.userId ?? '',
        workspace.name.trim().toLowerCase(),
        workspace.description.trim().toLowerCase(),
        workspace.type.name,
        workspace.currency,
      ].join('|');

      grouped.putIfAbsent(key, () => <Workspace>[]).add(workspace);
    }

    return grouped.values.map((group) {
      final active = group.firstWhereOrNull((workspace) => workspace.isActive);
      return active ?? group.first;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    // Preload icons/colors if needed
    loadWorkspaces();
  }

  Future<void> loadWorkspaces() async {
    status.value = RxStatus.loading();
    try {
      final activeOrgId = _authService.activeOrganizationId.value.isNotEmpty
          ? _authService.activeOrganizationId.value
          : await _authService.getActiveOrganization() ?? '';

      var remoteData = await _directusService.getWorkspaces(
        organizationId: activeOrgId.isEmpty ? null : activeOrgId,
      );

      if (remoteData.isEmpty && activeOrgId.isNotEmpty) {
        remoteData = await _directusService.getWorkspaces(
          organizationId: activeOrgId,
          restrictToCurrentUser: false,
        );
      }

      _workspaces.assignAll(remoteData);

      // Recuperar último workspace activo
      final lastActiveId = await AppStorage.read(key: 'last_active_workspace');

      if (lastActiveId != null &&
          _workspaces.any((w) => w.id == lastActiveId)) {
        activeWorkspaceRx.value = _workspaces.firstWhere(
          (w) => w.id == lastActiveId,
        );
      } else if (_workspaces.isNotEmpty) {
        // Default to first if none saved or saved one was deleted
        await setWorkspace(_workspaces.first);
      } else {
        activeWorkspaceRx.value = null;
      }

      status.value = RxStatus.success();
    } catch (e) {
      Get.log('Error loading workspaces: $e');
      status.value = RxStatus.error(e.toString());
    }
  }

  Future<void> setWorkspace(Workspace workspace) async {
    // Actualizar visualmente la lista (isActive flag)
    final newList = _workspaces.map((w) {
      return w.copyWith(isActive: w.id == workspace.id);
    }).toList();
    _workspaces.assignAll(newList);

    activeWorkspaceRx.value = workspace;

    // Persistir selección
    await AppStorage.write(key: 'last_active_workspace', value: workspace.id);

    // Feedback visual si es una acción del usuario (podríamos pasar un flag, pero por defecto asumimos que sí)
    // Evitar snackbar durante la carga inicial si es posible, pero aquí no diferenciamos fácil.
    // Podríamos comprobar si status es success ya.
    if (status.value.isSuccess) {
      Get.snackbar(
        'Espacio Cambiado',
        'Ahora estás en: ${workspace.name}',
        backgroundColor: const Color(0xFF059669),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> createWorkspace() async {
    if (status.value.isLoading) return; // Guard against double-tap
    final trimmedName = newWorkspaceName.value.trim();
    if (trimmedName.isEmpty) {
      SnackbarService.showError('Error', 'Por favor ingresa un nombre');
      return;
    }

    try {
      status.value = RxStatus.loading();

      final newWksp = Workspace(
        id: '', // DB generará ID
        name: trimmedName,
        type: WorkspaceType.personal, // Personal por defecto
        description: isShared.value ? 'Espacio Compartido' : 'Espacio Personal',
        isActive: false, // flag local o irrelevante en create
        organizationId: _authService.activeOrganizationId.value,
        colorValue: selectedColorValue.value,
        iconCodePoint: selectedIconCode.value,
      );

      final currentUser = await _directusService.getCurrentUser();
      if (currentUser == null) throw 'No se pudo obtener el usuario actual';

      final created = await _directusService.createWorkspace(
        newWksp,
        _authService.activeOrganizationId.value,
        currentUser.id,
      );

      if (created == null) throw 'No se pudo crear el espacio de trabajo';

      _workspaces.add(created);

      // Seleccionar el nuevo inmediatamente
      await setWorkspace(created);

      // Limpiar formulario
      newWorkspaceName.value = '';
      isShared.value = false;

      Get.back(); // Cerrar pantalla de creación
      SnackbarService.showSuccess('Éxito', 'Espacio "${created.name}" creado');

      status.value = RxStatus.success();
    } catch (e) {
      status.value = RxStatus.error(e.toString());
      SnackbarService.showError('Error', 'No se pudo crear el espacio: $e');
    }
  }

  // Alias para usar desde la UI si se prefiere 'select'
  Future<void> selectWorkspace(String workspaceId) async {
    final workspace = _workspaces.firstWhereOrNull((w) => w.id == workspaceId);
    if (workspace != null) {
      await setWorkspace(workspace);
    }
  }

  void showWorkspaceSelector(BuildContext context) {
    WorkspaceSelectorModal.show(context);
  }
}
