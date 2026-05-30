import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../data/services/biometric_auth_service.dart';

/// Bottomsheet de onboarding para activar inicio con biometría.
///
/// Se llama tras un login exitoso (password o registro). Devuelve `true` si
/// el usuario activó correctamente, `false` si descartó.
class BiometricEnrollSheet {
  /// Lanza el sheet solo si `shouldOfferEnroll()` es `true`.
  /// `email` se almacena junto con el flag para vincular bio → cuenta.
  static Future<bool> maybeShow(
    BuildContext context, {
    required String email,
  }) async {
    if (!Get.isRegistered<BiometricAuthService>()) return false;
    final bio = Get.find<BiometricAuthService>();
    if (!await bio.shouldOfferEnroll()) return false;
    if (!context.mounted) return false;

    final kind = await bio.getPreferredKind();
    if (!context.mounted) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(kind: kind, email: email, bio: bio),
    );
    return result ?? false;
  }
}

class _Sheet extends StatelessWidget {
  final BiometricKind kind;
  final String email;
  final BiometricAuthService bio;

  const _Sheet({
    required this.kind,
    required this.email,
    required this.bio,
  });

  String get _label {
    switch (kind) {
      case BiometricKind.face:
        return 'Face ID';
      case BiometricKind.fingerprint:
        return 'tu huella';
      case BiometricKind.iris:
        return 'tu iris';
      case BiometricKind.none:
        return 'tu biometría';
    }
  }

  IconData get _icon {
    switch (kind) {
      case BiometricKind.face:
        return Icons.face_rounded;
      case BiometricKind.fingerprint:
      case BiometricKind.iris:
      case BiometricKind.none:
        return Icons.fingerprint_rounded;
    }
  }

  Future<void> _activate(BuildContext context) async {
    final ok = await bio.authenticate(
      reason: 'Confirma con $_label para activar el inicio rápido',
    );
    if (!context.mounted) return;
    if (!ok) {
      SnackbarService.showWarning(
        'No activado',
        'No pudimos verificar tu biometría. Puedes intentarlo otra vez desde Ajustes.',
      );
      return;
    }
    await bio.enableFor(email);
    if (!context.mounted) return;
    SnackbarService.showSuccess(
      '¡Listo!',
      'La próxima vez podrás entrar con $_label.',
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _dismiss(BuildContext context) async {
    await bio.markDismissed();
    if (!context.mounted) return;
    Navigator.of(context).pop(false);
  }

  Future<void> _never(BuildContext context) async {
    await bio.markNever();
    if (!context.mounted) return;
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E0F7),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            // Hero icon
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(_icon, size: 40, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Inicia sesión más rápido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Usa $_label la próxima vez. Tu sesión queda protegida en este dispositivo.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            // Bullets
            const _Bullet(
              icon: Icons.lock_outline_rounded,
              text: 'Token cifrado en Keychain/Keystore',
            ),
            const SizedBox(height: 10),
            const _Bullet(
              icon: Icons.smartphone_rounded,
              text: 'Solo en este dispositivo',
            ),
            const SizedBox(height: 10),
            const _Bullet(
              icon: Icons.settings_outlined,
              text: 'Lo puedes desactivar cuando quieras',
            ),
            const SizedBox(height: 24),
            // CTAs
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _activate(context),
                icon: Icon(_icon, size: 22),
                label: Text(
                  'Activar ${_label[0].toUpperCase()}${_label.substring(1)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _dismiss(context),
              child: const Text(
                'Ahora no',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            TextButton(
              onPressed: () => _never(context),
              child: const Text(
                'No volver a preguntar',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7B7487),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Bullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF1A1C1C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
