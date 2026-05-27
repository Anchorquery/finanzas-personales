import 'package:get/get.dart';
import '../../core/utils/app_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart' as dio;
import 'directus_service.dart';
import '../../core/utils/snackbar_service.dart';
import '../../routes/app_routes.dart';

class AuthService extends GetxService {
  final DirectusService _directusService = Get.find<DirectusService>();
  GoogleSignIn? _googleSignIn;
  bool _isLoggingOut = false;

  final isLoggedIn = false.obs;
  final currentUser = ''.obs;
  final activeOrganizationId = ''.obs;

  Future<void> setActiveOrganization(String orgId) async {
    activeOrganizationId.value = orgId;
    await AppStorage.write(key: 'active_org_id', value: orgId);
  }

  Future<String?> getActiveOrganization() async {
    if (activeOrganizationId.value.isNotEmpty) {
      return activeOrganizationId.value;
    }
    final id = await AppStorage.read(key: 'active_org_id');
    if (id != null) {
      activeOrganizationId.value = id;
    }
    return id;
  }

  @override
  void onInit() {
    super.onInit();
    try {
      _googleSignIn = GoogleSignIn();
    } catch (e) {
      Get.log('GoogleSignIn init error (likely missing ClientID on Web): $e');
    }
  }

  Future<void> checkLoginStatus() async {
    final token = await AppStorage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      isLoggedIn.value = true;
    }
  }

  Future<String> getInitialRoute() async {
    Get.log('AuthService: getInitialRoute called');
    if (!isLoggedIn.value) {
      Get.log('AuthService: Not logged in, returning login route');
      return Routes.login;
    }

    try {
      Get.log(
        'AuthService: LOGGED IN. Fetching initial data status from Directus...',
      );
      final status = await _directusService.getInitialDataStatus();
      Get.log('AuthService: status: $status');

      if (status['hasOrg'] != true) {
        if (status['hasInvitations'] == true) {
          Get.log(
            'AuthService: No org but has invitations, returning /invitations',
          );
          return '/invitations';
        }
        Get.log('AuthService: No org, returning /setup');
        return Routes.setup;
      }

      final orgs = await _directusService.getUserOrganizations();
      if (orgs.isNotEmpty) {
        final savedId = await AppStorage.read(key: 'active_org_id');
        final String? orgWithCompleteSetup = status['orgWithCompleteSetup'];
        final String? orgNeedingSetup = status['orgNeedingSetup'];

        if (orgWithCompleteSetup != null && savedId != orgWithCompleteSetup) {
          Get.log(
            'AuthService: Switching to fully configured org: $orgWithCompleteSetup',
          );
          await setActiveOrganization(orgWithCompleteSetup);
        } else if (savedId != null && orgs.any((o) => o.id == savedId)) {
          Get.log('AuthService: Using saved org ID: $savedId');
          activeOrganizationId.value = savedId;
        } else if (orgNeedingSetup != null) {
          Get.log('AuthService: Using org pending setup: $orgNeedingSetup');
          await setActiveOrganization(orgNeedingSetup);
        } else {
          Get.log('AuthService: Setting first org as active: ${orgs.first.id}');
          await setActiveOrganization(orgs.first.id);
        }
      }

      final hasWorkspace = status['hasWorkspace'] == true;
      if (!hasWorkspace) {
        Get.log('AuthService: No workspace available, returning /setup');
        return Routes.setup;
      }

      Get.log(
        'AuthService: Workspace available. Entering home even if setup is partial.',
      );
      return Routes.home;
    } catch (e, stack) {
      Get.log('AuthService ERROR in getInitialRoute: $e');
      Get.log(stack.toString());
      return Routes.login;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final success = await _directusService.login(email, password);
      if (success) {
        isLoggedIn.value = true;
        return true;
      }
      SnackbarService.showError(
        'Error de Acceso',
        'Correo o contraseña incorrectos',
      );
      return false;
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        SnackbarService.showError(
          'Datos Inválidos',
          'El correo o la contraseña no son correctos.',
        );
      } else {
        SnackbarService.showError(
          'Error de Conexión',
          'No se pudo conectar con el servidor. Verifica tu internet.',
        );
      }
      return false;
    } catch (e) {
      SnackbarService.showError('Error Inesperado', 'Detalle: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    return await _directusService.createUser(name, email, password);
  }

  Future<bool> recoverPassword(String email) async {
    return await _directusService.requestPasswordReset(email);
  }

  Future<bool> loginWithGoogle() async {
    try {
      _googleSignIn ??= GoogleSignIn();

      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return false;

      SnackbarService.showWarning(
        'Falta Configuración',
        'Backend no configurado para SSO Google.',
      );

      // Limpiar sesión de Google ya que no se completó el flujo
      await _googleSignIn!.signOut();
      return false;
    } catch (e) {
      SnackbarService.showError(
        'Error',
        'Fallo al iniciar sesión con Google: $e',
      );
      return false;
    }
  }

  Future<void> logout({bool clearServerSession = true}) async {
    if (_isLoggingOut) {
      return;
    }

    _isLoggingOut = true;
    try {
      if (clearServerSession) {
        await _directusService.logout(notifyAuthService: false);
      }

      try {
        if (_googleSignIn != null) {
          await _googleSignIn!.signOut();
        }
      } catch (_) {}

      isLoggedIn.value = false;
      currentUser.value = '';
      activeOrganizationId.value = '';
      await AppStorage.delete(key: 'active_org_id');
      await AppStorage.delete(key: 'auth_token');
      await AppStorage.delete(key: 'refresh_token');
      Get.offAllNamed(Routes.login);
    } finally {
      _isLoggingOut = false;
    }
  }
}
