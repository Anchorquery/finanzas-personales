import 'package:get/get.dart';
import 'package:app_finanzas_mobile/data/services/directus_service.dart';
import 'package:app_finanzas_mobile/data/services/auth_service.dart';

class InvitationsController extends GetxController {
  final DirectusService _directusService = Get.find<DirectusService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<Invitation> invitations = <Invitation>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInvitations();
  }

  Future<void> loadInvitations() async {
    isLoading.value = true;
    try {
      final list = await _directusService.getPendingInvitations();
      invitations.assignAll(list);
    } catch (e) {
      Get.log('Error loading initial invitations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptInvitation(Invitation invitation) async {
    isLoading.value = true;
    try {
      await _directusService.acceptInvitation(invitation.id);
      
      Get.snackbar('Éxito', 'Has aceptado la invitación de ${invitation.organization?.name ?? 'la organización'}.');
      
      final nextRoute = await _authService.getInitialRoute();
      Get.offAllNamed(nextRoute);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo aceptar la invitación: $e');
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
        Get.offAllNamed('/setup');
      }
      Get.snackbar('Información', 'Invitación rechazada.');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo rechazar la invitación: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToSetup() {
    Get.toNamed('/setup');
  }
}
