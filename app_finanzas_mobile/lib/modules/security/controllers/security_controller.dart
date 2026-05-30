import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/directus_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/biometric_auth_service.dart';
import '../../../core/utils/snackbar_service.dart';

class SecurityController extends GetxController {
  final DirectusService _directusService = Get.find();
  final AuthService _authService = Get.find();
  final BiometricAuthService? _bio = Get.isRegistered<BiometricAuthService>()
      ? Get.find<BiometricAuthService>()
      : null;

  final isLoading = false.obs;

  // ── Biometría ──────────────────────────────────────────────────────────
  final bioSupported = false.obs;
  final bioEnrolledInOs = false.obs;
  final bioEnabled = false.obs;
  final bioKind = BiometricKind.none.obs;

  @override
  void onInit() {
    super.onInit();
    refreshBiometricState();
  }

  Future<void> refreshBiometricState() async {
    final b = _bio;
    if (b == null) return;
    bioSupported.value = await b.isAvailable();
    bioEnrolledInOs.value = await b.hasEnrolledBiometrics();
    bioKind.value = await b.getPreferredKind();
    bioEnabled.value = await b.isEnabled();
  }

  String get bioLabel {
    switch (bioKind.value) {
      case BiometricKind.face:
        return 'Face ID';
      case BiometricKind.fingerprint:
        return 'Huella digital';
      case BiometricKind.iris:
        return 'Iris';
      case BiometricKind.none:
        return 'Biometría';
    }
  }

  IconData get bioIcon {
    switch (bioKind.value) {
      case BiometricKind.face:
        return Icons.face_rounded;
      default:
        return Icons.fingerprint_rounded;
    }
  }

  /// Activa o desactiva el inicio con biometría.
  Future<void> toggleBiometric(bool enable) async {
    final b = _bio;
    if (b == null) return;
    if (!bioSupported.value || !bioEnrolledInOs.value) {
      SnackbarService.showWarning(
        'No disponible',
        'Configura una huella o Face ID en los ajustes del sistema primero.',
      );
      return;
    }

    if (enable) {
      final ok = await b.authenticate(
        reason: 'Confirma con ${bioLabel.toLowerCase()} para activarla',
      );
      if (!ok) {
        SnackbarService.showWarning(
          'No activado',
          'No pudimos verificar tu biometría.',
        );
        return;
      }
      String? email;
      try {
        final user = await _directusService.getCurrentUser();
        email = user?.email;
      } catch (_) {}
      if (email == null || email.isEmpty) {
        SnackbarService.showError(
          'Error',
          'No se encontró tu correo. Vuelve a iniciar sesión.',
        );
        return;
      }
      await b.enableFor(email);
      bioEnabled.value = true;
      SnackbarService.showSuccess(
        '¡Listo!',
        'Podrás entrar con $bioLabel la próxima vez.',
      );
    } else {
      await b.disable();
      bioEnabled.value = false;
      SnackbarService.showSuccess(
        'Desactivada',
        'El inicio con $bioLabel quedó desactivado.',
      );
    }
  }

  /// Solicitar cambio de contraseña vía email
  Future<void> changePassword() async {
    String? email;
    try {
      final user = await _directusService.getCurrentUser();
      email = user?.email;
    } catch (_) {}

    if (email == null || email.isEmpty) {
      SnackbarService.showError('Error', 'No se encontró el email del usuario');
      return;
    }

    isLoading.value = true;
    try {
      final sent = await _directusService.requestPasswordReset(email);
      if (sent) {
        SnackbarService.showSuccess(
          'Correo Enviado',
          'Revisa tu bandeja de entrada para restablecer tu contraseña',
        );
      } else {
        SnackbarService.showError(
          'Error',
          'No se pudo enviar el correo de restablecimiento',
        );
      }
    } catch (e) {
      SnackbarService.showError('Error', 'Error al solicitar cambio: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Cerrar todas las sesiones (logout)
  Future<void> closeAllSessions() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF192540),
        title: const Text('Cerrar Sesiones',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Se cerrará tu sesión actual y tendrás que iniciar sesión nuevamente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Cerrar Sesiones',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _authService.logout();
  }
}
