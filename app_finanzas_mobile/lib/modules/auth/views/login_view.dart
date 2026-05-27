import 'package:flutter/material.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import 'register_view.dart';
import 'forgot_password_view.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/auth_service.dart';
import '../../../l10n/gen/app_localizations.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find();
  final emailParams = TextEditingController();
  final passParams = TextEditingController();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

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
    if (isLoading.value) return; // Guard against double-tap
    final email = emailParams.text.trim();
    final pass = passParams.text;
    if (email.isEmpty || pass.isEmpty) {
      SnackbarService.showWarning("Error", "Campos requeridos");
      return;
    }
    if (!Validators.isValidEmail(email)) {
      SnackbarService.showWarning("Error", "Correo electrónico inválido");
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
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Logo Container
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.inputFillDark
                            : AppTheme.inputFillLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.inputBorderDark
                              : Colors.transparent,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.trending_up,
                            size: 36,
                            color: AppTheme.loginButtonColor,
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.loginButtonColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    "Finanzas Personales",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Gestiona tu crecimiento con IA",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Fields
                  AutofillGroup(
                    child: Column(
                      children: [
                        AuthTextField(
                          controller: controller.emailParams,
                          hint: "Correo Electrónico",
                          icon: Icons.email_outlined,
                          isDark: isDark,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => AuthTextField(
                            controller: controller.passParams,
                            hint: "Contraseña",
                            icon: Icons.lock_outline,
                            isDark: isDark,
                            isPassword: true,
                            isPasswordVisible: controller.isPasswordVisible.value,
                            onTogglePassword: controller.togglePasswordVisibility,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => controller.doLogin(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.to(() => const ForgotPasswordView()),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppL10n.of(context).authLoginForgot,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  SizedBox(
                    height: 54,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.doLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.loginButtonColor,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          disabledBackgroundColor: AppTheme.loginButtonColor
                              .withValues(alpha: 0.5),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                AppL10n.of(context).authLoginButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: isDark
                              ? AppTheme.inputBorderDark
                              : AppTheme.inputBorderLight,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "O CONTINÚA CON",
                          style: TextStyle(
                            color: AppTheme.textHint,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: isDark
                              ? AppTheme.inputBorderDark
                              : AppTheme.inputBorderLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Google Button
                  SocialLoginButton(
                    text: "Google",
                    icon: Icons.g_mobiledata,
                    isDark: isDark,
                    onPressed: () async {
                      await controller._authService.loginWithGoogle();
                      if (controller._authService.isLoggedIn.value) {
                        final initialRoute = await controller._authService
                            .getInitialRoute();
                        Get.offAllNamed(initialRoute);
                      }
                    },
                  ),

                  const SizedBox(height: 48),

                  // Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppL10n.of(context).authLoginNoAccount,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => const RegisterView()),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          ' ${AppL10n.of(context).authLoginRegister}',
                          style: TextStyle(
                            color: AppTheme.loginButtonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
