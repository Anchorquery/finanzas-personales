import 'package:flutter_test/flutter_test.dart';
import 'package:app_finanzas_mobile/data/services/exchange_rate_service.dart';
import 'package:app_finanzas_mobile/data/models/exchange_rate.dart';

void main() {
  // ExchangeRateService uses GetStorage (requires path_provider platform channel)
  // and makes real HTTP calls to the backend. These can't run in unit test mode.
  // Run against a live device/emulator or use the backend_integration_test.dart instead.
  test(
    'Fetch BCV Rates',
    () async {
      final service = ExchangeRateService();
      await service.fetchBCVRates();

      final bcvRate = service.currentRates[ExchangeRateProvider.bcv];
      final bcvEurRate = service.currentRates[ExchangeRateProvider.bcvEur];

      expect(bcvRate, isNotNull);
      expect(bcvEurRate, isNotNull);
    },
    skip: 'Requires path_provider plugin and live backend — run as integration test',
  );
}
