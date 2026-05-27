import 'package:get/get.dart';
import 'package:app_finanzas_mobile/data/services/directus_service.dart';
import 'package:app_finanzas_mobile/data/services/auth_service.dart';
import 'package:app_finanzas_mobile/modules/workspaces/controllers/workspaces_controller.dart';
import 'package:app_finanzas_mobile/routes/app_routes.dart';

class OrganizationsController extends GetxController {
  final DirectusService _directusService = Get.find<DirectusService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<Organization> organizations = <Organization>[].obs;
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;
  final RxList<Invitation> pendingInvitations = <Invitation>[].obs;
  final RxBool isLoading = false.obs;

  void _showSnackbar(String title, String message) {
    if (Get.testMode) {
      return;
    }
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onInit() {
    super.onInit();
    loadOrganizations();
  }

  void _setLoading(bool value) {
    if (isLoading.value == value) return;
    Future.microtask(() => isLoading.value = value);
  }

  Future<void> loadOrganizations() async {
    _setLoading(true);
    try {
      final orgs = await _directusService.getUserOrganizations();
      organizations.assignAll(orgs);
      
      final activeId = _authService.activeOrganizationId.value;
      if (activeId.isNotEmpty) {
        await loadMembersOfActive();
      }
    } catch (e) {
      Get.log('Error loading organizations: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMembersOfActive() async {
    final orgId = _authService.activeOrganizationId.value;
    if (orgId.isEmpty) return;
    
    try {
      final orgMembers = await _directusService.getOrganizationMembers(orgId);
      members.assignAll(orgMembers);
      
      final allInvites = await _directusService.getPendingInvitations();
      pendingInvitations.assignAll(allInvites.where((inv) => inv.organization?.id == orgId).toList());
      
    } catch (e) {
      Get.log('Error loading members/invites: $e');
    }
  }

  Future<void> switchOrganization(String orgId) async {
    if (_authService.activeOrganizationId.value == orgId) return;

    _setLoading(true);
    try {
      await _authService.setActiveOrganization(orgId);
      
      if (Get.isRegistered<WorkspacesController>()) {
        await Get.find<WorkspacesController>().loadWorkspaces();
      }
      
      await loadMembersOfActive();
      
      _showSnackbar(
        'Organización Cambiada',
        'Se ha seleccionado correctamente la organización.',
      );
    } catch (e) {
      Get.log('Error switching organization: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createOrganization(String name) async {
    _setLoading(true);
    try {
      final newOrg = await _directusService.createOrganization(name);
      await loadOrganizations();
      await switchOrganization(newOrg.id);
      Get.toNamed(Routes.setup);
      _showSnackbar(
        'Éxito',
        'Organización "${newOrg.name}" creada correctamente.',
      );
    } catch (e) {
      _showSnackbar('Error', 'No se pudo crear la organización: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveSettings({required String name, String? geminiKey}) async {
    final orgId = _authService.activeOrganizationId.value;
    if (orgId.isEmpty) return;

    _setLoading(true);
    try {
      await _directusService.updateOrganization(orgId, {'name': name});
      
      final existingSettings = await _directusService.getOrganizationSettings(orgId);
      if (existingSettings == null) {
        await _directusService.createOrganizationSettings(orgId, apiKey: geminiKey, aiEnabled: true);
      } else {
        await _directusService.updateOrganizationSettings(existingSettings['id'], {
          'gemini_api_key': geminiKey,
        });
      }

      await loadOrganizations();
      _showSnackbar('Éxito', 'Configuración guardada correctamente.');
    } catch (e) {
      _showSnackbar('Error', 'Error al guardar configuración: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> inviteMember(String email, String role) async {
    final orgId = _authService.activeOrganizationId.value;
    if (orgId.isEmpty) return;

    _setLoading(true);
    try {
      await _directusService.createInvitation(email, orgId, role);
      await loadMembersOfActive();
      _showSnackbar('Éxito', 'Se ha enviado la invitación a $email');
    } catch (e) {
      _showSnackbar('Error', 'No se pudo enviar la invitación: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> revokeInvitation(String inviteId) async {
    isLoading.value = true;
    try {
      await _directusService.deleteInvitation(inviteId);
      await loadMembersOfActive();
      _showSnackbar('Éxito', 'Invitación revocada.');
    } catch (e) {
      _showSnackbar('Error', 'No se pudo revocar la invitación: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
