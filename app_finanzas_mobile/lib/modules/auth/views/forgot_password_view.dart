import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/auth_service.dart';
import '../widgets/auth_scaffold.dart';

// ════════════════════════════════════════════════════════════════════════
// Controller — flujo multi-paso de recuperación
// ════════════════════════════════════════════════════════════════════════

/// Pasos del onboarding de recuperación.
enum ForgotStep { email, sent, reset, done }

class ForgotPasswordController extends GetxController {
  final AuthService _authService = Get.find();

  final emailController = TextEditingController();
  final tokenController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final step = ForgotStep.email.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmVisible = false.obs;

  /// Segundos para poder reenviar correo (cooldown anti-spam).
  final resendCooldown = 0.obs;
  Timer? _cooldownTimer;

  @override
  void onClose() {
    emailController.dispose();
    tokenController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _cooldownTimer?.cancel();
    super.onClose();
  }

  void togglePassword() =>
      isPasswordVisible.value = !isPasswordVisible.value;
  void toggleConfirm() => isConfirmVisible.value = !isConfirmVisible.value;

  // ── Paso 1 → 2: solicitar correo ──────────────────────────────────────
  Future<void> submitEmail() async {
    if (isLoading.value) return;
    final email = emailController.text.trim();
    if (email.isEmpty) {
      SnackbarService.showWarning('Error', 'Ingresa tu correo electrónico');
      return;
    }
    if (!Validators.isValidEmail(email)) {
      SnackbarService.showWarning('Error', 'Correo electrónico inválido');
      return;
    }

    isLoading.value = true;
    try {
      final ok = await _authService.recoverPassword(email);
      if (isClosed) return;
      if (!ok) {
        SnackbarService.showError(
          'Error',
          'No se pudo enviar el correo. Verifica tu conexión.',
        );
        return;
      }
      _startResendCooldown();
      step.value = ForgotStep.sent;
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  // ── Paso 2: reenviar correo ──────────────────────────────────────────
  Future<void> resendEmail() async {
    if (resendCooldown.value > 0) return;
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    isLoading.value = true;
    try {
      final ok = await _authService.recoverPassword(email);
      if (isClosed) return;
      if (ok) {
        SnackbarService.showSuccess(
          'Reenviado',
          'Te enviamos el correo nuevamente.',
        );
        _startResendCooldown();
      } else {
        SnackbarService.showError('Error', 'No se pudo reenviar.');
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void _startResendCooldown() {
    resendCooldown.value = 30;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendCooldown.value <= 1) {
        resendCooldown.value = 0;
        t.cancel();
      } else {
        resendCooldown.value -= 1;
      }
    });
  }

  /// Abre la app de correo (mailto sin destinatario solo dispara el cliente).
  Future<void> openMailApp() async {
    final uri = Uri.parse('mailto:');
    try {
      final launched = await launchUrl(uri);
      if (!launched) {
        SnackbarService.showWarning(
          'Sin app de correo',
          'Abre tu bandeja desde la app del correo.',
        );
      }
    } catch (_) {
      SnackbarService.showWarning(
        'Sin app de correo',
        'Abre tu bandeja desde la app del correo.',
      );
    }
  }

  // ── Paso 2 → 3 ────────────────────────────────────────────────────────
  void goToTokenStep() => step.value = ForgotStep.reset;

  // ── Paso 2: cambiar correo (volver a paso 1) ─────────────────────────
  void changeEmail() {
    tokenController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    step.value = ForgotStep.email;
  }

  // ── Paso 3 → 4: confirmar reset ──────────────────────────────────────
  Future<void> submitNewPassword() async {
    if (isLoading.value) return;
    final token = tokenController.text.trim();
    final pass = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (token.isEmpty) {
      SnackbarService.showWarning(
        'Error',
        'Pega el token que recibiste por correo.',
      );
      return;
    }
    if (pass.length < 8) {
      SnackbarService.showWarning(
        'Contraseña corta',
        'Mínimo 8 caracteres.',
      );
      return;
    }
    if (pass != confirm) {
      SnackbarService.showWarning(
        'No coinciden',
        'La contraseña y la confirmación no coinciden.',
      );
      return;
    }

    isLoading.value = true;
    try {
      final ok = await _authService.resetPassword(token, pass);
      if (isClosed) return;
      if (!ok) {
        SnackbarService.showError(
          'Token inválido',
          'El token expiró o es incorrecto. Solicita uno nuevo.',
        );
        return;
      }
      step.value = ForgotStep.done;
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  // ── Paso 4 ────────────────────────────────────────────────────────────
  void goToLogin() {
    Get.back();
  }
}

// ════════════════════════════════════════════════════════════════════════
// View — split mobile + desktop con AuthScaffold
// ════════════════════════════════════════════════════════════════════════

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return AuthScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          return _ForgotLayout(controller: controller, isDesktop: isDesktop);
        },
      ),
    );
  }
}

class _ForgotLayout extends StatelessWidget {
  final ForgotPasswordController controller;
  final bool isDesktop;
  const _ForgotLayout({required this.controller, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: isDesktop ? 32 : 36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 480 : 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppTheme.primary,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          AppTheme.primary.withValues(alpha: 0.08),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const Spacer(),
                  Obx(() => _StepIndicator(step: controller.step.value)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),

              // Card with animated step content
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
                child: Obx(() {
                  final step = controller.step.value;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _stepView(step),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepView(ForgotStep step) {
    switch (step) {
      case ForgotStep.email:
        return _StepEmail(key: const ValueKey('email'), c: controller);
      case ForgotStep.sent:
        return _StepSent(key: const ValueKey('sent'), c: controller);
      case ForgotStep.reset:
        return _StepReset(key: const ValueKey('reset'), c: controller);
      case ForgotStep.done:
        return _StepDone(key: const ValueKey('done'), c: controller);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════
// Step indicator (dots)
// ════════════════════════════════════════════════════════════════════════

class _StepIndicator extends StatelessWidget {
  final ForgotStep step;
  const _StepIndicator({required this.step});

  int get _index {
    switch (step) {
      case ForgotStep.email:
        return 0;
      case ForgotStep.sent:
        return 1;
      case ForgotStep.reset:
        return 2;
      case ForgotStep.done:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final active = i <= _index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == _index ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppTheme.primary
                : AppTheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Step 1 — Email
// ════════════════════════════════════════════════════════════════════════

class _StepEmail extends StatelessWidget {
  final ForgotPasswordController c;
  const _StepEmail({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HeroIcon(icon: Icons.lock_reset_rounded),
        const SizedBox(height: 16),
        const _Title('Recuperar contraseña'),
        const SizedBox(height: 8),
        const _Subtitle(
          'Ingresa el correo asociado a tu cuenta. Te enviaremos un código para crear una nueva contraseña.',
        ),
        const SizedBox(height: 24),
        const _FieldLabel('Correo electrónico'),
        const SizedBox(height: 4),
        _PlainField(
          controller: c.emailController,
          hint: 'ejemplo@finvault.com',
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => c.submitEmail(),
        ),
        const SizedBox(height: 20),
        Obx(
          () => _PrimaryBtn(
            isLoading: c.isLoading.value,
            label: 'Enviar instrucciones',
            onPressed: c.submitEmail,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Step 2 — Sent (revisa tu correo)
// ════════════════════════════════════════════════════════════════════════

class _StepSent extends StatelessWidget {
  final ForgotPasswordController c;
  const _StepSent({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    final email = c.emailController.text.trim();
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HeroIcon(icon: Icons.mark_email_read_rounded),
        const SizedBox(height: 16),
        const _Title('Revisa tu correo'),
        const SizedBox(height: 8),
        _Subtitle.rich([
          const TextSpan(text: 'Enviamos un mensaje a '),
          TextSpan(
            text: email,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const TextSpan(
            text:
                '. Sigue las instrucciones para continuar. Puede tardar unos minutos en llegar.',
          ),
        ]),
        const SizedBox(height: 20),
        const _InfoTip(
          icon: Icons.timer_outlined,
          text: 'El enlace expira en 60 minutos.',
        ),
        const SizedBox(height: 10),
        const _InfoTip(
          icon: Icons.inbox_outlined,
          text: 'Si no lo ves, revisa SPAM o promociones.',
        ),
        const SizedBox(height: 24),
        _PrimaryBtn(
          label: 'Abrir mi correo',
          onPressed: c.openMailApp,
          icon: Icons.open_in_new_rounded,
        ),
        const SizedBox(height: 10),
        _SecondaryBtn(
          label: 'Ya tengo el token',
          onPressed: c.goToTokenStep,
          icon: Icons.vpn_key_rounded,
        ),
        const SizedBox(height: 18),
        // Reenviar + cambiar correo
        Obx(() {
          final cd = c.resendCooldown.value;
          final disabled = cd > 0 || c.isLoading.value;
          return Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '¿No te llegó? ',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13.5,
                  ),
                ),
                TextButton(
                  onPressed: disabled ? null : c.resendEmail,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    cd > 0 ? 'Reenviar en ${cd}s' : 'Reenviar',
                    style: TextStyle(
                      color: disabled
                          ? AppTheme.textDisabled
                          : AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: c.changeEmail,
            child: const Text(
              'Cambiar correo',
              style: TextStyle(
                color: Color(0xFF7B7487),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Step 3 — Token + nueva contraseña
// ════════════════════════════════════════════════════════════════════════

class _StepReset extends StatelessWidget {
  final ForgotPasswordController c;
  const _StepReset({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HeroIcon(icon: Icons.password_rounded),
        const SizedBox(height: 16),
        const _Title('Nueva contraseña'),
        const SizedBox(height: 8),
        const _Subtitle(
          'Pega el token que recibiste por correo y elige una nueva contraseña.',
        ),
        const SizedBox(height: 24),
        const _FieldLabel('Token de recuperación'),
        const SizedBox(height: 4),
        _PlainField(
          controller: c.tokenController,
          hint: 'Pega el token aquí',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        const _FieldLabel('Nueva contraseña'),
        const SizedBox(height: 4),
        Obx(
          () => _PlainField(
            controller: c.newPasswordController,
            hint: 'Mínimo 8 caracteres',
            isPassword: true,
            isPasswordVisible: c.isPasswordVisible.value,
            onTogglePassword: c.togglePassword,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => _PasswordStrength(value: c.newPasswordController.text)),
        const SizedBox(height: 12),
        const _FieldLabel('Confirmar contraseña'),
        const SizedBox(height: 4),
        Obx(
          () => _PlainField(
            controller: c.confirmPasswordController,
            hint: 'Repite la contraseña',
            isPassword: true,
            isPasswordVisible: c.isConfirmVisible.value,
            onTogglePassword: c.toggleConfirm,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => c.submitNewPassword(),
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => _PrimaryBtn(
            isLoading: c.isLoading.value,
            label: 'Cambiar contraseña',
            onPressed: c.submitNewPassword,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () => c.step.value = ForgotStep.sent,
            child: const Text(
              'Volver',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Step 4 — Done
// ════════════════════════════════════════════════════════════════════════

class _StepDone extends StatelessWidget {
  final ForgotPasswordController c;
  const _StepDone({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.accentGreen,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _Title('¡Contraseña actualizada!'),
        const SizedBox(height: 8),
        const _Subtitle(
          'Ya puedes iniciar sesión con tu nueva contraseña.',
        ),
        const SizedBox(height: 28),
        _PrimaryBtn(
          label: 'Iniciar sesión',
          onPressed: c.goToLogin,
          icon: Icons.login_rounded,
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Reusable mini widgets
// ════════════════════════════════════════════════════════════════════════

class _HeroIcon extends StatelessWidget {
  final IconData icon;
  const _HeroIcon({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 38, color: AppTheme.primary),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1C1C),
        ),
      );
}

class _Subtitle extends StatelessWidget {
  final String? text;
  final List<InlineSpan>? spans;
  const _Subtitle(this.text) : spans = null;
  const _Subtitle.rich(this.spans) : text = null;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 14.5,
      color: AppTheme.textSecondary,
      height: 1.45,
    );
    if (spans != null) {
      return Text.rich(
        TextSpan(style: style, children: spans),
        textAlign: TextAlign.center,
      );
    }
    return Text(text!, textAlign: TextAlign.center, style: style);
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
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

class _InfoTip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  const _PrimaryBtn({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
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
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  const _SecondaryBtn({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, size: 20, color: AppTheme.primary)
            : const SizedBox.shrink(),
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
        inputFormatters:
            isPassword ? null : [LengthLimitingTextInputFormatter(200)],
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

class _PasswordStrength extends StatelessWidget {
  final String value;
  const _PasswordStrength({required this.value});

  /// 0..4
  int get _score {
    int s = 0;
    if (value.length >= 8) s++;
    if (value.length >= 12) s++;
    if (RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value)) {
      s++;
    }
    if (RegExp(r'[0-9]').hasMatch(value) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      s++;
    }
    return s;
  }

  String get _label {
    switch (_score) {
      case 0:
      case 1:
        return 'Débil';
      case 2:
        return 'Aceptable';
      case 3:
        return 'Buena';
      default:
        return 'Fuerte';
    }
  }

  Color get _color {
    switch (_score) {
      case 0:
      case 1:
        return AppTheme.accentRed;
      case 2:
        return AppTheme.accentWarning;
      case 3:
        return AppTheme.accentBlue;
      default:
        return AppTheme.accentGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(4, (i) {
                final active = i < _score;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 4,
                    decoration: BoxDecoration(
                      color: active
                          ? _color
                          : const Color(0xFFEDEAF6),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
