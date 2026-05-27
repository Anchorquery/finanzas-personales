import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'data/services/directus_service.dart';
import 'routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'data/services/auth_service.dart';

import 'data/services/notification_service.dart';
import 'data/services/exchange_rate_service.dart';
import 'data/services/quick_actions_service.dart';
import 'data/services/voice_input_service.dart';
import 'core/utils/currency_utils.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/gen/app_localizations.dart';

/// Habilita scroll con mouse/trackpad en Flutter Web.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.log('--- [MAIN] INICIANDO APP ---');

  await initializeDateFormatting('es_ES', null);
  await initHiveForFlutter();
  await GetStorage.init();
  CurrencyUtils.init();

  Get.log('--- [MAIN] Inicializando DirectusService...');
  await Get.putAsync(() => DirectusService().init());

  Get.log('--- [MAIN] Inicializando NotificationService...');
  final notifSvc = await Get.putAsync(() => NotificationService().init());
  // Auto-schedule nightly Coach reminder when enabled (default true).
  final notifEnabled =
      GetStorage().read<bool>('notifications_enabled') ?? true;
  if (notifEnabled) {
    unawaited(notifSvc.scheduleCoachNightly());
  }

  Get.log('--- [MAIN] Inicializando ExchangeRateService...');
  await Get.putAsync(() => ExchangeRateService().init());

  Get.put<VoiceInputService>(VoiceInputService(), permanent: true);
  unawaited(Get.putAsync(() => QuickActionsService().init()));

  Get.log('--- [MAIN] Inicializando AuthService...');
  final authService = Get.put(AuthService());

  Get.log('--- [MAIN] Comprobando estado de login...');
  await authService.checkLoginStatus();

  Get.log('--- [MAIN] Obteniendo ruta inicial...');
  final initialRoute = await authService.getInitialRoute();

  Get.log('--- [MAIN] Ruta determinada: $initialRoute. Ejecutando runApp...');
  runApp(MyApp(initialRoute: initialRoute));
}

void main() async {
  if (!AppConfig.sentryEnabled) {
    await _bootstrap();
    return;
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.environment = AppConfig.sentryEnvironment;
      options.tracesSampleRate = 0.2;
      options.attachScreenshot = false;
      options.attachViewHierarchy = false;
    },
    appRunner: _bootstrap,
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeIndex = GetStorage().read<int>('theme_mode') ?? 2;
    final initialThemeMode = ThemeMode.values[themeIndex.clamp(0, 2)];

    return GetMaterialApp(
      title: 'Finanzas Personales',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      scrollBehavior: AppScrollBehavior(),
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppL10n.supportedLocales,
      locale: const Locale('es'),
    );
  }
}
