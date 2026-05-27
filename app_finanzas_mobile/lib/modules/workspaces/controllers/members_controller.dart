import 'package:app_finanzas_mobile/data/services/auth_service.dart';
import 'package:app_finanzas_mobile/data/services/directus_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/snackbar_service.dart';
import 'workspaces_controller.dart';

class MembersController extends GetxController {
  final DirectusService _directusService = Get.find<DirectusService>();
  final WorkspacesController _workspacesController =
      Get.find<WorkspacesController>();
  final AuthService _authService = Get.find<AuthService>();

  final inviteEmailController = TextEditingController();
  final isInviting = false.obs;
  final isLoading = false.obs;
  final accessScope = 'restricted'.obs;

  final members = <User>[].obs;
  final invitations = <Invitation>[].obs;
  final selectedMemberIds = <String>{}.obs;

  String get _activeWorkspaceId =>
      _workspacesController.activeWorkspace?.id ?? '';
  String get _activeOrgId => _authService.activeOrganizationId.value;
  Workspace? get _activeWorkspace => _workspacesController.activeWorkspace;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  Future<void> loadMembers() async {
    final workspaceId = _activeWorkspaceId;
    if (workspaceId.isEmpty) {
      members.clear();
      invitations.clear();
      selectedMemberIds.clear();
      return;
    }

    isLoading.value = true;
    try {
      final orgMembers = await _directusService.getOrganizationMembers(
        _activeOrgId,
      );
      members.assignAll(
        orgMembers
            .map(
              (member) => User.fromJson(member['user'] as Map<String, dynamic>),
            )
            .toList(),
      );

      final workspaceSettings = await _directusService.getWorkspaceSettings(
        workspaceId,
      );
      accessScope.value =
          workspaceSettings?['access_scope']?.toString() ??
          _activeWorkspace?.accessScope ??
          'restricted';
      selectedMemberIds
        ..clear()
        ..addAll(_parseMemberIds(workspaceSettings?['access_member_ids']));

      final pending = await _directusService.getWorkspaceInvitations(
        workspaceId,
      );
      invitations.assignAll(
        pending.where((invite) => invite.status == 'pending').toList(),
      );
    } catch (e) {
      SnackbarService.showError(
        'Error',
        'No se pudieron cargar los miembros: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendInvite() async {
    final email = inviteEmailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      SnackbarService.showError('Error', 'Ingrese un correo valido');
      return;
    }

    if (_activeWorkspaceId.isEmpty || _activeOrgId.isEmpty) {
      SnackbarService.showError(
        'Error',
        'Necesitas una organizacion y un workspace activo para invitar miembros.',
      );
      return;
    }

    isInviting.value = true;
    try {
      await _directusService.createWorkspaceInvitation(
        _activeWorkspaceId,
        email,
        'member',
      );
      inviteEmailController.clear();
      await loadMembers();
      SnackbarService.showSuccess(
        'Invitacion enviada',
        'El miembro fue invitado a la organizacion y luego podra usar este workspace.',
      );
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo enviar la invitacion: $e');
    } finally {
      isInviting.value = false;
    }
  }

  Future<void> revokeInvitation(String invitationId) async {
    try {
      await _directusService.cancelWorkspaceInvitation(invitationId);
      await loadMembers();
      SnackbarService.showSuccess(
        'Invitacion revocada',
        'La invitacion fue cancelada.',
      );
    } catch (e) {
      SnackbarService.showError(
        'Error',
        'No se pudo revocar la invitacion: $e',
      );
    }
  }

  Future<void> updateAccessScope(String scope) async {
    accessScope.value = scope;
    if (scope == 'organization') {
      selectedMemberIds.clear();
    }
    await _persistAccessSettings();
  }

  Future<void> toggleMemberAccess(String userId, bool enabled) async {
    if (enabled) {
      selectedMemberIds.add(userId);
    } else {
      selectedMemberIds.remove(userId);
    }
    await _persistAccessSettings();
  }

  bool hasWorkspaceAccess(User member) {
    if (isWorkspaceOwner(member)) {
      return true;
    }

    if (accessScope.value == 'organization') {
      return true;
    }

    return selectedMemberIds.contains(member.id);
  }

  bool isWorkspaceOwner(User member) {
    return member.id == _activeWorkspace?.userId;
  }

  void removeMember(String id) {
    SnackbarService.showWarning(
      'Gestion centralizada',
      'Los miembros ahora se administran desde la organizacion. Usa Organization Settings para quitarlos o cambiar roles.',
    );
  }

  Future<void> _persistAccessSettings() async {
    final workspace = _activeWorkspace;
    if (workspace == null) {
      return;
    }

    try {
      final updated = await _directusService.updateWorkspace(workspace.id, {
        'access_scope': accessScope.value,
        'access_member_ids': selectedMemberIds.toList(),
      });
      _workspacesController.activeWorkspaceRx.value = updated;
      await _workspacesController.loadWorkspaces();
    } catch (e) {
      SnackbarService.showError(
        'Error',
        'No se pudo actualizar el acceso del workspace: $e',
      );
    }
  }

  List<String> _parseMemberIds(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed == 'null') {
        return const <String>[];
      }

      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        return trimmed
            .substring(1, trimmed.length - 1)
            .split(',')
            .map((item) => item.replaceAll('"', '').trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }

      return <String>[trimmed];
    }

    return const <String>[];
  }

  @override
  void onClose() {
    inviteEmailController.dispose();
    super.onClose();
  }
}
