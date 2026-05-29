import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/auth_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../widgets/auth_scaffold.dart';
import 'forgot_password_view.dart';
import 'register_view.dart';

// ════════════════════════════════════════════════════════════════════════
// Controller
// ════════════════════════════════════════════════════════════════════════

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

// ════════════════════════════════════════════════════════════════════════
// View — split mobile + desktop 1:1 con HTMLs
// ════════════════════════════════════════════════════════════════════════

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return AuthScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1024) {
            return _DesktopLogin(controller: controller);
          }
          return _MobileLogin(controller: controller);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// MOBILE — login_violet_fintech
// Branding header arriba + card "Bienvenido de nuevo" + Google/Bio
// ─────────────────────────────────────────────────────────────────────────

class _MobileLogin extends StatelessWidget {
  final LoginController controller;
  const _MobileLogin({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Branding header (texto grande)
              Column(
                children: const [
                  Text(
                    'Finanzas Personales',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gestión financiera premium a tu alcance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Login Card
              Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x33CCC3D8)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF630ED4).withValues(alpha: 0.08),
                      blurRadius: 50,
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
                      const SizedBox(height: 24),

                      // Email
                      const _FieldLabel('Correo electrónico'),
                      const SizedBox(height: 4),
                      _PlainField(
                        controller: controller.emailParams,
                        hint: 'ejemplo@finvault.com',
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Password label + forgot
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _FieldLabel('Contraseña'),
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
                      const SizedBox(height: 4),
                      Obx(
                        () => _PlainField(
                          controller: controller.passParams,
                          hint: '••••••••',
                          isPassword: true,
                          isPasswordVisible: controller.isPasswordVisible.value,
                          onTogglePassword:
                              controller.togglePasswordVisibility,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => controller.doLogin(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // CTA
                      SizedBox(
                        height: 56,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.doLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: AppTheme.primary
                                  .withValues(alpha: 0.20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const _Divider(text: 'O CONTINÚA CON'),
                      const SizedBox(height: 20),

                      // Google + Bio grid 2 cols
                      Row(
                        children: [
                          Expanded(
                            child: _SecondaryBtn(
                              onPressed: controller.doGoogleLogin,
                              icon: const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 28,
                                color: AppTheme.primary,
                              ),
                              label: 'Google',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SecondaryBtn(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                SnackbarService.showWarning(
                                  'Próximamente',
                                  'Inicio con biometría disponible pronto.',
                                );
                              },
                              icon: const Icon(
                                Icons.fingerprint_rounded,
                                size: 22,
                                color: AppTheme.primary,
                              ),
                              label: 'Biométricos',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      // Register footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                              AppL10n.of(context).authLoginRegister,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// DESKTOP — login_desktop
// Logo arriba + card 480 + footer "Encriptación AES-256"
// ─────────────────────────────────────────────────────────────────────────

class _DesktopLogin extends StatelessWidget {
  final LoginController controller;
  const _DesktopLogin({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo + identidad
              Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.20),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Finanzas Personales',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Color(0xFF1A1C1C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Accede a tu libertad financiera',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Login Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F0FB)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF630ED4).withValues(alpha: 0.06),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email
                      const _FieldLabel('Correo electrónico'),
                      const SizedBox(height: 4),
                      _IconField(
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
                          const _FieldLabel('Contraseña'),
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
                      const SizedBox(height: 4),
                      Obx(
                        () => _IconField(
                          controller: controller.passParams,
                          icon: Icons.lock_outline_rounded,
                          hint: '••••••••',
                          isPassword: true,
                          isPasswordVisible: controller.isPasswordVisible.value,
                          onTogglePassword:
                              controller.togglePasswordVisibility,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => controller.doLogin(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Remember me
                      Obx(
                        () => Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: controller.rememberMe.value,
                                onChanged: (v) => controller.rememberMe.value =
                                    v ?? false,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                side: const BorderSide(
                                    color: AppTheme.borderLight),
                                activeColor: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Recordarme en este dispositivo',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // CTA
                      SizedBox(
                        height: 48,
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.4,
                                    ),
                                  )
                                : Text(
                                    AppL10n.of(context).authLoginButton,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const _Divider(text: 'O CONTINÚA CON'),
                      const SizedBox(height: 16),

                      // Google + Bio
                      Row(
                        children: [
                          Expanded(
                            child: _SecondaryBtn(
                              onPressed: controller.doGoogleLogin,
                              icon: const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 26,
                                color: AppTheme.primary,
                              ),
                              label: 'Google',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SecondaryBtn(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                SnackbarService.showWarning(
                                  'Próximamente',
                                  'Inicio con biometría disponible pronto.',
                                );
                              },
                              icon: const Icon(
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
              ),
              const SizedBox(height: 24),

              // Register footer
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                        AppL10n.of(context).authLoginRegister,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Security badge
              Center(
                child: Opacity(
                  opacity: 0.5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Encriptación de grado bancario AES-256',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.4,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Shared field widgets (light only)
// ════════════════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

/// Input bordeado SIN icon prefix — usado en login mobile.
class _PlainField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final List<String>? autofillHints;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _PlainField({
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.autofillHints,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCCC3D8), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          color: Color(0xFF1A1C1C),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF7B7487).withValues(alpha: 0.6),
            fontSize: 14.5,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: const Color(0xFF7B7487),
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

/// Input bordeado CON icon prefix — usado en login desktop.
class _IconField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final List<String>? autofillHints;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _IconField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.autofillHints,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E0F7), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          color: Color(0xFF1A1C1C),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF7B7487),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF7B7487)),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 44, minHeight: 44),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: const Color(0xFF7B7487),
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final String text;
  const _Divider({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFEDEAF6),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7B7487),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFEDEAF6),
          ),
        ),
      ],
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  const _SecondaryBtn({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1C),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF9F9F9),
          side: const BorderSide(color: Color(0x66E2E0F7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
