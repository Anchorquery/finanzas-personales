import 'package:get/get.dart';
import '../../../data/services/directus_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/utils/snackbar_service.dart';

class ProfileController extends GetxController {
  final DirectusService _directusService = Get.find();
  final AuthService _authService = Get.find();

  final user = Rxn<User>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      isLoading.value = true;
      final userData = await _directusService.getCurrentUser();
      user.value = userData;
    } catch (e) {
      // print("Error loading user: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(String firstName) async {
    try {
      final ok = await _directusService.updateCurrentUserProfile({'first_name': firstName});
      if (ok) {
        await loadUser();
        SnackbarService.showSuccess('Éxito', 'Perfil actualizado');
      } else {
        SnackbarService.showError('Error', 'No se pudo actualizar el perfil');
      }
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo actualizar el perfil');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
