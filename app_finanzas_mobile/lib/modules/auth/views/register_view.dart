import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/auth_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routes/app_routes.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find();
  final nameParams = TextEditingController();
  final emailParams = TextEditingController();
  final passParams = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    nameParams.dispose();
    emailParams.dispose();
    passParams.dispose();
    super.onClose();
  }

  Future<void> doRegister() async {
    if (isLoading.value) return; // Guard against double-tap
    final name = nameParams.text.trim();
    final email = emailParams.text.trim();
    final pass = passParams.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      SnackbarService.showWarning("Error", "Todos los campos son obligatorios");
      return;
    }
    if (!Validators.isValidEmail(email)) {
      SnackbarService.showWarning("Error", "Correo electrónico inválido");
      return;
    }
    if (pass.length < 8) {
      SnackbarService.showWarning(
          "Error", "La contraseña debe tener al menos 8 caracteres");
      return;
    }

    isLoading.value = true;
    try {
      final success = await _authService.register(name, email, pass);
      if (isClosed) return;

      if (!success) {
        SnackbarService.showError(
          "Error",
          "No se pudo registrar. El correo podría estar en uso.",
        );
        return;
      }

      SnackbarService.showSuccess(
        "Éxito",
        "Usuario creado. Iniciando sesión...",
      );
      final loginSuccess = await _authService.login(email, pass);
      if (isClosed) return;

      if (loginSuccess) {
        final initialRoute = await _authService.getInitialRoute();
        if (isClosed) return;
        Get.offAllNamed(initialRoute);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.of(context).authRegisterTitle),
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
                  Icons.person_add,
                  size: 60,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller.nameParams,
                  decoration: const InputDecoration(
                    labelText: "Nombre Completo",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.emailParams,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Correo Electrónico",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.passParams,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock),
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
                          : controller.doRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        disabledBackgroundColor: Colors.white12,
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "REGISTRARME",
                              style: TextStyle(
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
