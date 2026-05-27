import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/auth_service.dart';
import '../../../l10n/gen/app_localizations.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = Get.find();
  final emailController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> requestReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      SnackbarService.showWarning("Error", "Ingresa tu correo electrónico");
      return;
    }
    if (!Validators.isValidEmail(email)) {
      SnackbarService.showWarning("Error", "Correo electrónico inválido");
      return;
    }

    isLoading.value = true;
    final success = await _authService.recoverPassword(email);
    if (isClosed) return;
    isLoading.value = false;

    if (success) {
      emailController.clear();
      Get.back();
      SnackbarService.showSuccess(
        "Correo Enviado",
        "Revisa tu bandeja de entrada para restablecer tu contraseña.",
      );
    } else {
      SnackbarService.showError(
        "Error",
        "No se pudo enviar el correo. Verifica que el email sea correcto.",
      );
    }
  }
}

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());
    final t = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.authForgotTitle),
        backgroundColor: Colors.transparent,
      ),
      // Background handled by Theme (Dark)
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  t.authForgotHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: t.authLoginEmail,
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.requestReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor: Colors.white12,
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              t.authForgotButton,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
