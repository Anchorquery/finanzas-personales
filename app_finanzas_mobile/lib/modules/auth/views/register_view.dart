import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/auth_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routes/app_routes.dart';
import '../widgets/auth_field.dart';
import '../widgets/auth_scaffold.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find();
  final nameParams = TextEditingController();
  final emailParams = TextEditingController();
  final passParams = TextEditingController();
  final confirmParams = TextEditingController();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final acceptedTerms = false.obs;

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  @override
  void onClose() {
    nameParams.dispose();
    emailParams.dispose();
    passParams.dispose();
    confirmParams.dispose();
    super.onClose();
  }

  Future<void> doRegister() async {
    if (isLoading.value) return;
    final name = nameParams.text.trim();
    final email = emailParams.text.trim();
    final pass = passParams.text;
    final confirm = confirmParams.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      SnackbarService.showWarning('Error', 'Todos los campos son obligatorios');
      return;
    }
    if (!Validators.isValidEmail(email)) {
      SnackbarService.showWarning('Error', 'Correo electrónico inválido');
      return;
    }
    if (pass.length < 8) {
      SnackbarService.showWarning(
        'Error',
        'La contraseña debe tener al menos 8 caracteres',
      );
      return;
    }
    if (pass != confirm) {
      SnackbarService.showWarning('Error', 'Las contraseñas no coinciden');
      return;
    }
    if (!acceptedTerms.value) {
      SnackbarService.showWarning(
        'Términos',
        'Debes aceptar los Términos y la Política de Privacidad.',
      );
      return;
    }

    isLoading.value = true;
    try {
      final success = await _authService.register(name, email, pass);
      if (isClosed) return;

      if (!success) {
        SnackbarService.showError(
          'Error',
          'No se pudo registrar. El correo podría estar en uso.',
        );
        return;
      }

      SnackbarService.showSuccess(
        'Éxito',
        'Usuario creado. Iniciando sesión...',
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

    return AuthScaffold(
      child: Column(
        children: [
          const _GlassHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RegisterCard(controller: controller),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppL10n.of(context).authRegisterHaveAccount,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              ' ${AppL10n.of(context).authRegisterLogin}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 13,
                            color: AppTheme.textSecondary
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SAFE & SECURE VAULTING',
                            style: TextStyle(
                              fontSize: 10.5,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _GlassHeader extends StatelessWidget {
  const _GlassHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        border: const Border(
          bottom: BorderSide(color: Color(0x14000000)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Finanzas Personales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const Spacer(),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFF1F0FB),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _RegisterCard extends StatelessWidget {
  final RegisterController controller;
  const _RegisterCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F0FB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Comienza tu viaje',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Crea tu cuenta y toma el control de tus finanzas.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            AuthField(
              label: 'Nombre Completo',
              controller: controller.nameParams,
              icon: Icons.person_outline_rounded,
              hint: 'Ej. Daniel García',
              autofillHints: const [AutofillHints.name],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AuthField(
              label: 'Correo Electrónico',
              controller: controller.emailParams,
              icon: Icons.mail_outline_rounded,
              hint: 'nombre@ejemplo.com',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Obx(
              () => AuthField(
                label: 'Contraseña',
                controller: controller.passParams,
                icon: Icons.lock_outline_rounded,
                hint: 'Mínimo 8 caracteres',
                isPassword: true,
                isPasswordVisible: controller.isPasswordVisible.value,
                onTogglePassword: controller.togglePasswordVisibility,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => AuthField(
                label: 'Confirmar Contraseña',
                controller: controller.confirmParams,
                icon: Icons.enhanced_encryption_outlined,
                hint: '••••••••',
                isPassword: true,
                isPasswordVisible: controller.isPasswordVisible.value,
                onTogglePassword: controller.togglePasswordVisibility,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.doRegister(),
              ),
            ),

            const SizedBox(height: 18),

            // Terms
            Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: controller.acceptedTerms.value,
                      onChanged: (v) =>
                          controller.acceptedTerms.value = v ?? false,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      activeColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: AppTheme.textSecondary,
                        ),
                        children: [
                          TextSpan(text: 'Acepto los '),
                          TextSpan(
                            text: 'Términos y Condiciones',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: ' y la '),
                          TextSpan(
                            text: 'Política de Privacidad',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 52,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.doRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor:
                        AppTheme.primary.withValues(alpha: 0.5),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppL10n.of(context).authRegisterButton,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
