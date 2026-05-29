import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/auth_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../widgets/auth_field.dart';
import '../widgets/auth_scaffold.dart';
import 'forgot_password_view.dart';
import 'register_view.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find();
  final emailParams = TextEditingController();
  final passParams = TextEditingController();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final rememberMe = true.obs;

  @override
  void onClose() {
    emailParams.dispose();
    passParams.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> doLogin() async {
    if (isLoading.value) return;
    final email = emailParams.text.trim();
    final pass = passParams.text;
    if (email.isEmpty || pass.isEmpty) {
      SnackbarService.showWarning('Error', 'Campos requeridos');
      return;
    }
    if (!Validators.isValidEmail(email)) {
      SnackbarService.showWarning('Error', 'Correo electrónico inválido');
      return;
    }

    isLoading.value = true;
    try {
      final success = await _authService.login(email, pass);
      if (isClosed) return;
      if (success) {
        final initialRoute = await _authService.getInitialRoute();
        if (isClosed) return;
        Get.offAllNamed(initialRoute);
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> doGoogleLogin() async {
    await _authService.loginWithGoogle();
    if (_authService.isLoggedIn.value) {
      final initialRoute = await _authService.getInitialRoute();
      Get.offAllNamed(initialRoute);
    }
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return AuthScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 20,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandHeader(),
                    const SizedBox(height: 28),
                    _LoginCard(controller: controller),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppL10n.of(context).authLoginNoAccount,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Get.to(() => const RegisterView()),
                          style: TextButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            ' ${AppL10n.of(context).authLoginRegister}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isWide) ...[
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 14,
                            color: AppTheme.textSecondary
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Encriptación de grado bancario AES-256',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.2,
                              color: AppTheme.textSecondary
                                  .withValues(alpha: 0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Finanzas Personales',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFF1A1C1C),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Accede a tu libertad financiera',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  final LoginController controller;
  const _LoginCard({required this.controller});

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
            color: const Color(0xFF630ED4).withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenido de nuevo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(height: 22),

            // Email
            AuthField(
              label: 'Correo electrónico',
              controller: controller.emailParams,
              icon: Icons.mail_outline_rounded,
              hint: 'nombre@ejemplo.com',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contraseña',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () =>
                        Get.to(() => const ForgotPasswordView()),
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Obx(
              () => AuthField(
                controller: controller.passParams,
                icon: Icons.lock_outline_rounded,
                hint: '••••••••',
                isPassword: true,
                isPasswordVisible: controller.isPasswordVisible.value,
                onTogglePassword: controller.togglePasswordVisibility,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.doLogin(),
              ),
            ),
            const SizedBox(height: 18),

            // Remember + CTA
            Obx(
              () => Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: controller.rememberMe.value,
                      onChanged: (v) =>
                          controller.rememberMe.value = v ?? false,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      side: const BorderSide(color: AppTheme.borderLight),
                      activeColor: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Recordarme en este dispositivo',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 52,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.doLogin,
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
                      : Text(
                          AppL10n.of(context).authLoginButton,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 22),
            const _Divider(text: 'O CONTINÚA CON'),
            const SizedBox(height: 18),

            // Google + Bio (bio = placeholder visual)
            Row(
              children: [
                Expanded(
                  child: _SecondaryAuthBtn(
                    onPressed: controller.doGoogleLogin,
                    iconWidget: const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 28,
                      color: AppTheme.primary,
                    ),
                    label: 'Google',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SecondaryAuthBtn(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      SnackbarService.showWarning(
                        'Próximamente',
                        'Inicio con biometría disponible pronto.',
                      );
                    },
                    iconWidget: const Icon(
                      Icons.fingerprint_rounded,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                    label: 'Biometría',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  final String text;
  const _Divider({required this.text});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFEDEAF6);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textHint,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: color)),
      ],
    );
  }
}

class _SecondaryAuthBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget iconWidget;
  final String label;

  const _SecondaryAuthBtn({
    required this.onPressed,
    required this.iconWidget,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1C),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE2E0F7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
