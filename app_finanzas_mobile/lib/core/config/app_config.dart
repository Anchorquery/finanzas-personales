import 'package:get/get.dart';

class AppConfig {
  static String get directusUrl {
    const envUrl = String.fromEnvironment('DIRECTUS_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (GetPlatform.isWeb) return 'https://bs943xvxnxhhus0pnhe404kb.213.130.147.89.sslip.io';
    return 'https://bs943xvxnxhhus0pnhe404kb.213.130.147.89.sslip.io';
  }

  static String get exchangeRateApiUrl {
    const envUrl = String.fromEnvironment('EXCHANGE_RATE_API_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return directusUrl; // Default: same as Directus
  }

  static String get defaultUserRole {
    const envRole = String.fromEnvironment('DIRECTUS_USER_ROLE');
    if (envRole.isNotEmpty) return envRole;
    return 'ad2e4239-1849-481b-a224-eab79d0f8481';
  }

  /// Sentry DSN. If empty, Sentry is disabled (no-op).
  /// Set via --dart-define=SENTRY_DSN=...
  static String get sentryDsn =>
      const String.fromEnvironment('SENTRY_DSN');

  /// Environment label for Sentry (production / staging / dev).
  static String get sentryEnvironment =>
      const String.fromEnvironment('SENTRY_ENV', defaultValue: 'dev');

  static bool get sentryEnabled => sentryDsn.isNotEmpty;
}
