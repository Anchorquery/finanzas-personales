import 'package:flutter_test/flutter_test.dart';
import 'package:app_finanzas_mobile/data/services/exchange_rate_service.dart';
import 'package:app_finanzas_mobile/data/models/exchange_rate.dart';

void main() {
  test('Fetch BCV Rates', () async {
    final service = ExchangeRateService();

    // We can't easily mock http here without more setup,
    // but we can try to run the actual fetch if environment allows
    // or just check the logic if we mocked the html response.
    // For this environment, let's try to run it.
    // Note: This might fail if network is restricted in the test environment.

    // print('Starting fetch...');
    await service.fetchBCVRates();

    final bcvRate = service.currentRates[ExchangeRateProvider.bcv];
    final bcvEurRate = service.currentRates[ExchangeRateProvider.bcvEur];

    expect(bcvRate, isNotNull);
    expect(bcvEurRate, isNotNull);

    // print('BCV USD: ${bcvRate?.rate}');
    // print('BCV EUR: ${bcvEurRate?.rate}');

    // We expect some value if network works, or null/error logs if not.
    // This is just a sanity check for the code structure not crashing.
  });
}
