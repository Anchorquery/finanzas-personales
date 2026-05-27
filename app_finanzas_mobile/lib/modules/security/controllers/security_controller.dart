import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/directus_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/utils/snackbar_service.dart';

class SecurityController extends GetxController {
  final DirectusService _directusService = Get.find();
  final AuthService _authService = Get.find();

  final isLoading = false.obs;

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
