import 'package:app_finanzas_mobile/core/utils/currency_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_VE', null);
  });

  group('CurrencyUtils.symbol', () {
    test('USD dollar sign', () =>
        expect(CurrencyUtils.symbol('USD'), r'$'));
    test('VES bolivar', () => expect(CurrencyUtils.symbol('VES'), 'Bs.'));
    test('EUR euro', () => expect(CurrencyUtils.symbol('EUR'), '€'));
    test('case-insensitive', () =>
        expect(CurrencyUtils.symbol('usd'), r'$'));
    test('unknown returns code', () =>
        expect(CurrencyUtils.symbol('XYZ'), 'XYZ'));
  });

  group('CurrencyUtils.name', () {
    test('known currency', () =>
        expect(CurrencyUtils.name('USD'), 'Dólar Estadounidense'));
    test('unknown returns code', () =>
        expect(CurrencyUtils.name('XYZ'), 'XYZ'));
  });

  group('CurrencyUtils.formatAmount', () {
    test('positive USD', () {
      final out = CurrencyUtils.formatAmount(50, 'USD');
      expect(out, startsWith(r'$'));
      expect(out, contains('50'));
    });
    test('negative shows minus sign before symbol', () {
      final out = CurrencyUtils.formatAmount(-25.5, 'USD');
      expect(out, startsWith(r'-$'));
    });
    test('VES uses Bs.', () {
      final out = CurrencyUtils.formatAmount(1825, 'VES');
      expect(out, contains('Bs.'));
    });
  });

  group('CurrencyUtils.supportedCurrencies', () {
    test('contains USD VES EUR', () {
      final list = CurrencyUtils.supportedCurrencies;
      expect(list, containsAll(['USD', 'VES', 'EUR']));
    });
  });

  group('CurrencyUtils.displayCurrencies', () {
    test('has 3 main currencies', () {
      expect(CurrencyUtils.displayCurrencies, ['USD', 'VES', 'EUR']);
    });
  });
}
