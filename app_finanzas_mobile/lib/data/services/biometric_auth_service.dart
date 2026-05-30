import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

import '../../core/utils/app_storage.dart';

/// `true` solo en plataformas donde tiene sentido (Android + iOS).
/// Web y desktop (Windows/macOS/Linux) quedan excluidos.
bool _isMobilePlatform() {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

/// Tipo de biometría disponible, simplificado para UI.
enum BiometricKind { face, fingerprint, iris, none }

/// Estado del prompt de onboarding.
enum BioPromptStatus { unset, dismissed, never, enabled }

class BiometricAuthService extends GetxService {
  static const _kEnabledKey = 'bio_enabled';
  static const _kEmailKey = 'bio_email';
  static const _kPromptStatusKey = 'bio_prompt_status';
  static const _kPromptDismissedAtKey = 'bio_prompt_dismissed_at';

  final LocalAuthentication _auth = LocalAuthentication();

  /// `true` si el dispositivo soporta biometría y tiene al menos un sensor.
  /// Solo Android / iOS. Web y desktop devuelven `false`.
  Future<bool> isAvailable() async {
    if (!_isMobilePlatform()) return false;
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      return canCheck;
    } on PlatformException {
      return false;
    }
  }

  /// `true` si el usuario tiene huellas/face enroladas en el SO.
  Future<bool> hasEnrolledBiometrics() async {
    if (!_isMobilePlatform()) return false;
    try {
      final list = await _auth.getAvailableBiometrics();
      return list.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Tipo predominante para mostrar icono/label correctos.
  Future<BiometricKind> getPreferredKind() async {
    if (!_isMobilePlatform()) return BiometricKind.none;
    try {
      final list = await _auth.getAvailableBiometrics();
      if (list.contains(BiometricType.face)) return BiometricKind.face;
      if (list.contains(BiometricType.fingerprint)) {
        return BiometricKind.fingerprint;
      }
      if (list.contains(BiometricType.iris)) return BiometricKind.iris;
      if (list.contains(BiometricType.strong) ||
          list.contains(BiometricType.weak)) {
        return BiometricKind.fingerprint;
      }
      return BiometricKind.none;
    } on PlatformException {
      return BiometricKind.none;
    }
  }

  /// Lanza el prompt biométrico nativo. Devuelve `true` si autenticó.
  Future<bool> authenticate({String? reason}) async {
    if (!_isMobilePlatform()) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason ?? 'Confirma tu identidad para continuar',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      // Errores conocidos: notAvailable, notEnrolled, lockedOut, etc.
      // Tratamos cualquiera como fallo silencioso a nivel servicio.
      Get.log('[BIO] authenticate error: ${e.code} - ${e.message}');
      if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        // Bloqueado por demasiados intentos.
      }
      return false;
    }
  }

  // ── Flags ────────────────────────────────────────────────────────────────

  Future<bool> isEnabled() async {
    final v = await AppStorage.read(key: _kEnabledKey);
    return v == '1';
  }

  Future<String?> getBoundEmail() async {
    return AppStorage.read(key: _kEmailKey);
  }

  Future<void> enableFor(String email) async {
    await AppStorage.write(key: _kEnabledKey, value: '1');
    await AppStorage.write(key: _kEmailKey, value: email);
    await AppStorage.write(
      key: _kPromptStatusKey,
      value: BioPromptStatus.enabled.name,
    );
  }

  /// Desactiva bio.
  ///
  /// - `resetPrompt: true` → marca el prompt como `unset` para que se vuelva a
  ///   ofrecer en el próximo login (uso interno: sesión expirada, mismatch de
  ///   usuario, refresh token inválido).
  /// - `resetPrompt: false` (default) → marca `dismissed`, pensado para cuando
  ///   el propio usuario lo apaga desde Ajustes.
  Future<void> disable({bool resetPrompt = false}) async {
    await AppStorage.delete(key: _kEnabledKey);
    await AppStorage.delete(key: _kEmailKey);
    if (resetPrompt) {
      await AppStorage.delete(key: _kPromptStatusKey);
      await AppStorage.delete(key: _kPromptDismissedAtKey);
    } else {
      await AppStorage.write(
        key: _kPromptStatusKey,
        value: BioPromptStatus.dismissed.name,
      );
    }
  }

  Future<BioPromptStatus> getPromptStatus() async {
    final v = await AppStorage.read(key: _kPromptStatusKey);
    return BioPromptStatus.values.firstWhere(
      (s) => s.name == v,
      orElse: () => BioPromptStatus.unset,
    );
  }

  Future<void> markDismissed() async {
    await AppStorage.write(
      key: _kPromptStatusKey,
      value: BioPromptStatus.dismissed.name,
    );
    await AppStorage.write(
      key: _kPromptDismissedAtKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<void> markNever() async {
    await AppStorage.write(
      key: _kPromptStatusKey,
      value: BioPromptStatus.never.name,
    );
  }

  /// `true` si debemos sugerir activar bio tras un login exitoso.
  /// Reglas:
  /// - dispositivo soporta + tiene enrolamiento en SO.
  /// - bio aún no activada.
  /// - usuario nunca marcó "never".
  /// - status `unset` o `dismissed` (cualquiera vale; no re-preguntamos por
  ///   tiempo, decisión de producto: una sola oferta inicial).
  Future<bool> shouldOfferEnroll() async {
    if (!_isMobilePlatform()) return false;
    if (await isEnabled()) return false;
    if (!await isAvailable()) return false;
    if (!await hasEnrolledBiometrics()) return false;
    final status = await getPromptStatus();
    return status == BioPromptStatus.unset;
  }
}
