import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../widgets/auth_scaffold.dart';

// ════════════════════════════════════════════════════════════════════════
// Controller
// ════════════════════════════════════════════════════════════════════════

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

// ════════════════════════════════════════════════════════════════════════
// View — split mobile + desktop
// ════════════════════════════════════════════════════════════════════════

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());
    return AuthScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1024) {
            return _DesktopRegister(controller: controller);
          }
          return _MobileRegister(controller: controller);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// MOBILE — registro_violet_fintech
// Glass sticky header + centered card "Comienza tu viaje"
// ─────────────────────────────────────────────────────────────────────────

class _MobileRegister extends StatelessWidget {
  final RegisterController controller;
  const _MobileRegister({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sticky glass header
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.80),
            border: const Border(
              bottom: BorderSide(color: Color(0x14000000)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Finanzas Personales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _RegisterCard(
                  controller: controller,
                  variant: _CardVariant.mobile,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// DESKTOP — registro_desktop
// 2-col grid: LEFT branding + bento features, RIGHT register card 480
// ─────────────────────────────────────────────────────────────────────────

class _DesktopRegister extends StatelessWidget {
  final RegisterController controller;
  const _DesktopRegister({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT — branding + bento
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Finanzas Personales',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1C1C),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Tu futuro financiero,',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          letterSpacing: -1,
                          color: Color(0xFF1A1C1C),
                        ),
                      ),
                      const Text(
                        'asegurado hoy.',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          letterSpacing: -1,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(
                        width: 480,
                        child: Text(
                          'Únete a miles de profesionales que confían en nuestra infraestructura premium para gestionar sus activos con total transparencia.',
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Bento feature cards
                      Row(
                        children: const [
                          Expanded(
                            child: _BentoCard(
                              icon: Icons.verified_user_outlined,
                              title: 'Seguridad de grado bancario',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _BentoCard(
                              icon: Icons.bolt_outlined,
                              title: 'Transacciones instantáneas',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // RIGHT — register card
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _RegisterCard(
                  controller: controller,
                  variant: _CardVariant.desktop,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _BentoCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCCC3D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 26),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1C),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared register card body
// ─────────────────────────────────────────────────────────────────────────

enum _CardVariant { mobile, desktop }

class _RegisterCard extends StatelessWidget {
  final RegisterController controller;
  final _CardVariant variant;
  const _RegisterCard({
    required this.controller,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = variant == _CardVariant.mobile;
    return Container(
      padding: EdgeInsets.all(isMobile ? 32 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 12),
        border: Border.all(
          color: isMobile
              ? const Color(0x33CCC3D8)
              : const Color(0xFFF1F0FB),
        ),
        boxShadow: [
          BoxShadow(
            color: isMobile
                ? Colors.black.withValues(alpha: 0.05)
                : const Color(0xFF630ED4).withValues(alpha: 0.04),
            blurRadius: isMobile ? 30 : 48,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isMobile ? 'Comienza tu viaje' : 'Crea tu cuenta',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1C1C),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isMobile
                  ? 'Únete a la nueva era de la banca digital premium.'
                  : 'Comienza tu viaje financiero en segundos.',
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Nombre
            _RegLabel('Nombre completo'),
            const SizedBox(height: 6),
            _RegField(
              controller: controller.nameParams,
              icon: Icons.person_outline_rounded,
              hint: isMobile ? 'Ej. Alejandro García' : 'John Doe',
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: 20),

            // Email
            _RegLabel('Correo electrónico'),
            const SizedBox(height: 6),
            _RegField(
              controller: controller.emailParams,
              icon: Icons.mail_outline_rounded,
              hint: isMobile ? 'nombre@ejemplo.com' : 'nombre@empresa.com',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 20),

            // Password grid 2 col en desktop, stack mobile
            if (isMobile) ...[
              _RegLabel('Contraseña'),
              const SizedBox(height: 6),
              Obx(
                () => _RegField(
                  controller: controller.passParams,
                  icon: Icons.lock_outline_rounded,
                  hint: '••••••••',
                  isPassword: true,
                  isPasswordVisible: controller.isPasswordVisible.value,
                  onTogglePassword: controller.togglePasswordVisibility,
                  autofillHints: const [AutofillHints.newPassword],
                ),
              ),
              const SizedBox(height: 20),
              _RegLabel('Confirmar contraseña'),
              const SizedBox(height: 6),
              Obx(
                () => _RegField(
                  controller: controller.confirmParams,
                  icon: Icons.enhanced_encryption_outlined,
                  hint: '••••••••',
                  isPassword: true,
                  isPasswordVisible: controller.isPasswordVisible.value,
                  onTogglePassword: controller.togglePasswordVisibility,
                  autofillHints: const [AutofillHints.newPassword],
                ),
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RegLabel('Contraseña'),
                        const SizedBox(height: 6),
                        Obx(
                          () => _RegField(
                            controller: controller.passParams,
                            icon: Icons.lock_outline_rounded,
                            hint: '••••••••',
                            isPassword: true,
                            isPasswordVisible:
                                controller.isPasswordVisible.value,
                            onTogglePassword:
                                controller.togglePasswordVisibility,
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RegLabel('Confirmar'),
                        const SizedBox(height: 6),
                        Obx(
                          () => _RegField(
                            controller: controller.confirmParams,
                            icon: Icons.enhanced_encryption_outlined,
                            hint: '••••••••',
                            isPassword: true,
                            isPasswordVisible:
                                controller.isPasswordVisible.value,
                            onTogglePassword:
                                controller.togglePasswordVisibility,
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),

            // Terms
            Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: controller.acceptedTerms.value,
                      onChanged: (v) =>
                          controller.acceptedTerms.value = v ?? false,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      activeColor: AppTheme.primary,
                      side: const BorderSide(color: Color(0xFFE2E0F7)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
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
            const SizedBox(height: 24),

            // CTA
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: AppTheme.primary.withValues(alpha: 0.2),
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
                          children: const [
                            Text(
                              'Crear Cuenta',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Footer link login
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¿Ya tienes ${isMobile ? "cuenta" : "una cuenta"}?',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isMobile ? 'Entrar' : 'Inicia sesión',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegLabel extends StatelessWidget {
  final String text;
  // ignore: unused_element_parameter
  const _RegLabel(this.text);

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

class _RegField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final List<String>? autofillHints;
  final TextInputType keyboardType;

  const _RegField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.autofillHints,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E0F7), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
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
