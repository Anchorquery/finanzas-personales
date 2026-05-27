import 'package:get/get.dart';
import '../../../data/services/directus_service.dart';

import '../../../routes/app_routes.dart';
import '../../../core/utils/snackbar_service.dart';

class InvitationsController extends GetxController {
  final DirectusService _directusService = Get.find<DirectusService>();
  
  final invitations = <Invitation>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInvitations();
  }

  Future<void> loadInvitations() async {
    isLoading.value = true;
    try {
      final user = await _directusService.getCurrentUser();
      if (user != null) {
        final list = await _directusService.getPendingInvitations(user.email);
        invitations.assignAll(list);
      }
    } catch (e) {
      Get.log('Error loading invitations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptInvitation(Invitation invitation) async {
    isLoading.value = true;
    try {
      final user = await _directusService.getCurrentUser();
      if (user == null) return;

      // 1. Add member to organization
      final successMember = await _directusService.addMemberToOrganization(
        invitation.organizationId,
        user.id,
        invitation.role,
      );

      if (successMember) {
        // 2. Update invitation status
        await _directusService.updateInvitationStatus(invitation.id, 'accepted');
        
        SnackbarService.showSuccess(
          '¡Bienvenido!',
          'Te has unido a la organización ${invitation.organization?.name ?? ""}',
        );
        
        // 3. Move forward
        Get.offAllNamed(Routes.home);
      } else {
        SnackbarService.showError('Error', 'No se pudo unir a la organización');
      }
    } catch (e) {
      Get.log('Error accepting invitation: $e');
      SnackbarService.showError('Error', 'Sucedió algo inesperado');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectInvitation(Invitation invitation) async {
    isLoading.value = true;
    try {
      await _directusService.updateInvitationStatus(invitation.id, 'rejected');
      invitations.remove(invitation);
      
      if (invitations.isEmpty) {
        Get.offAllNamed(Routes.setup);
      }
    } catch (e) {
      Get.log('Error rejecting invitation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToSetup() {
    Get.toNamed(Routes.setup);
  }
}
