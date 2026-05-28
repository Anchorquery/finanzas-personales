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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    _BrandHeader(isDark: isDark),
                    const SizedBox(height: 28),
                    _LoginCard(controller: controller, isDark: isDark),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppL10n.of(context).authLoginNoAccount,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : AppTheme.textSecondary,
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
                            color: (isDark
                                    ? Colors.white
                                    : AppTheme.textSecondary)
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Encriptación de grado bancario AES-256',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.2,
                              color: (isDark
                                      ? Colors.white
                                      : AppTheme.textSecondary)
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
  final bool isDark;
  const _BrandHeader({required this.isDark});

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
        Text(
          'Finanzas Personales',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF1A1C1C),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Accede a tu libertad financiera',
          style: TextStyle(
            fontSize: 14,
            color:
                isDark ? Colors.white70 : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  final LoginController controller;
  final bool isDark;
  const _LoginCard({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0x14FFFFFF)
              : const Color(0xFFF1F0FB),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFF630ED4).withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenido de nuevo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(height: 22),

            // Email
            AuthField(
              label: 'Correo electrónico',
              controller: controller.emailParams,
              icon: Icons.mail_outline_rounded,
              hint: 'nombre@ejemplo.com',
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contraseña',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white70
                        : AppTheme.textSecondary,
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
                isDark: isDark,
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
                      side: BorderSide(
                        color: isDark
                            ? Colors.white24
                            : AppTheme.borderLight,
                      ),
                      activeColor: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Recordarme en este dispositivo',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark
                          ? Colors.white70
                          : AppTheme.textSecondary,
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
            _Divider(isDark: isDark, text: 'O CONTINÚA CON'),
            const SizedBox(height: 18),

            // Google + Bio (bio = placeholder visual)
            Row(
              children: [
                Expanded(
                  child: _SecondaryAuthBtn(
                    isDark: isDark,
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
                    isDark: isDark,
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
  final bool isDark;
  final String text;
  const _Divider({required this.isDark, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = isDark
        ? const Color(0x33FFFFFF)
        : const Color(0xFFEDEAF6);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white38
                  : AppTheme.textHint,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: color)),
      ],
    );
  }
}

class _SecondaryAuthBtn extends StatelessWidget {
  final bool isDark;
  final VoidCallback onPressed;
  final Widget iconWidget;
  final String label;

  const _SecondaryAuthBtn({
    required this.isDark,
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
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A1C1C),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isDark ? const Color(0x12FFFFFF) : Colors.white,
          side: BorderSide(
            color: isDark
                ? const Color(0x22FFFFFF)
                : const Color(0xFFE2E0F7),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
