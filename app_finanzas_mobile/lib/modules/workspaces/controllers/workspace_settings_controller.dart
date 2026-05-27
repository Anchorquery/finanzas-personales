import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/services/directus_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import 'workspaces_controller.dart';

class WorkspaceMember {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String role; // 'Admin', 'Editor', 'Viewer'
  final String status; // 'Active', 'Pending'

  WorkspaceMember({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
    required this.status,
  });
}

class WorkspaceSettingsController extends GetxController {
  final DirectusService _directusService = Get.find<DirectusService>();
  final WorkspacesController workspacesController =
      Get.find<WorkspacesController>();

  late Rx<Workspace> workspace;
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final accounts = <Account>[].obs;
  final orgMembers = <Map<String, dynamic>>[].obs;
  final workspaceMembers = <String>[].obs; // IDs de miembros con acceso

  // Funds / Currency Section
  final aiPredictiveAnalysis = false.obs;
  final aiCategorization = true.obs;
  final selectedCurrency = 'USD'.obs;

  @override
  void onInit() {
    super.onInit();
    Workspace? ws = Get.arguments as Workspace?;
    ws ??= workspacesController.activeWorkspace;

    if (ws != null) {
      workspace = ws.obs;
      aiPredictiveAnalysis.value = ws.aiPredictiveAnalysis;
      aiCategorization.value = ws.aiCategorization;
      selectedCurrency.value = ws.currency;
      loadAccounts();
      loadMembers();
    } else {
      Future.delayed(Duration.zero, () {
        Get.back();
        SnackbarService.showError(
          'Error',
          'No se ha seleccionado ningún espacio',
        );
      });
    }
  }

  Future<void> loadMembers() async {
    try {
      final orgId = _authService.activeOrganizationId.value;
      if (orgId.isEmpty) return;

      final members = await _directusService.getOrganizationMembers(orgId);
      orgMembers.assignAll(members);
      workspaceMembers.assignAll(
        workspace.value.accessMemberIds,
      );
    } catch (e) {
      Get.log('Error loading workspace members: $e');
    }
  }

  Future<void> addMemberToWorkspace(String userId) async {
    if (workspaceMembers.contains(userId)) return;

    final updatedMembers = [...workspaceMembers, userId];
    try {
      await updateWorkspace({
        'access_member_ids': updatedMembers,
        'access_scope': 'restricted',
      });
      workspaceMembers.assignAll(updatedMembers);
      SnackbarService.showSuccess('Éxito', 'Miembro agregado al workspace');
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo agregar el miembro: $e');
    }
  }

  Future<void> removeMemberFromWorkspace(String userId) async {
    if (!workspaceMembers.contains(userId)) return;

    // No permitir remover al dueño
    if (userId == workspace.value.userId) {
      SnackbarService.showWarning('No permitido', 'No puedes remover al dueño del workspace');
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Remover Miembro', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Remover a este miembro del workspace? Ya no podrá ver los datos.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Remover', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final updatedMembers = workspaceMembers.where((id) => id != userId).toList();
    try {
      await updateWorkspace({
        'access_member_ids': updatedMembers,
      });
      workspaceMembers.assignAll(updatedMembers);
      SnackbarService.showSuccess('Éxito', 'Miembro removido');
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo remover: $e');
    }
  }

  Future<void> setAccessScope(String scope) async {
    await updateWorkspace({'access_scope': scope});
  }

  Future<void> loadAccounts() async {
    try {
      final data = await _directusService.getAccounts(
        workspaceId: workspace.value.id,
      );
      accounts.assignAll(data);
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudieron cargar las cuentas');
    }
  }

  Future<void> updateWorkspaceName(String name) async {
    await updateWorkspace({'name': name});
  }

  Future<void> updateAIPreference(String field, bool value) async {
    if (field == 'ai_predictive_analysis') {
      aiPredictiveAnalysis.value = value;
    } else {
      aiCategorization.value = value;
    }
    await updateWorkspace({field: value});
  }

  Future<void> updateCurrency(String value) async {
    selectedCurrency.value = value;
    await updateWorkspace({'currency': value});
  }

  Future<void> updateWorkspace(Map<String, dynamic> data) async {
    try {
      final updated = await _directusService.updateWorkspace(
        workspace.value.id,
        data,
      );
      workspace.value = updated;
      await workspacesController.loadWorkspaces();
      await loadAccounts();
    } catch (e) {
      SnackbarService.showError(
        'Error',
        'No se pudo actualizar el espacio: $e',
      );
    }
  }

  Future<void> deleteWorkspace() async {
    Get.defaultDialog(
      title: '¿Eliminar Espacio?',
      middleText:
          'Esta acción no se puede deshacer. Se perderán todos los datos financieros asociados.',
      textConfirm: 'Eliminar',
      textCancel: 'Cancelar',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back(); // Cerrar dialogo
        isLoading.value = true;
        try {
          await _directusService.deleteWorkspace(workspace.value.id);
          await workspacesController.loadWorkspaces();
          Get.offAllNamed(Routes.home);
          SnackbarService.showSuccess(
            'Éxito',
            'Espacio eliminado correctamente',
          );
        } catch (e) {
          SnackbarService.showError(
            'Error',
            'No se pudo eliminar el espacio: $e',
          );
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Fecha no disponible';
    return DateFormat('d MMM yyyy', 'es_ES').format(date);
  }
}
