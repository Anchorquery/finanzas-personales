import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../data/models/exchange_rate.dart';
import '../../data/services/exchange_rate_service.dart';

class CurrencyUtils {
  static const Map<String, String> _symbols = {
    'USD': '\$',
    'VES': 'Bs.',
    'EUR': '€',
    'COP': 'COL\$',
    'ARS': 'AR\$',
    'BRL': 'R\$',
  };

  static const Map<String, String> _names = {
    'USD': 'Dólar Estadounidense',
    'VES': 'Bolívar Venezolano',
    'EUR': 'Euro',
    'COP': 'Peso Colombiano',
    'ARS': 'Peso Argentino',
    'BRL': 'Real Brasileño',
  };

  /// Moneda de visualización global (reactiva)
  static final displayCurrency = 'USD'.obs;

  /// Inicializa la preferencia de moneda desde storage
  static void init() {
    final stored = GetStorage().read<String>('display_currency');
    if (stored != null && _symbols.containsKey(stored)) {
      displayCurrency.value = stored;
    }
  }

  /// Cambia la moneda de visualización y persiste
  static void setDisplayCurrency(String currency) {
    if (_symbols.containsKey(currency)) {
      displayCurrency.value = currency;
      GetStorage().write('display_currency', currency);
    }
  }

  static String symbol(String currencyCode) {
    return _symbols[currencyCode.toUpperCase()] ?? currencyCode;
  }

  static String name(String currencyCode) {
    return _names[currencyCode.toUpperCase()] ?? currencyCode;
  }

  static List<String> get supportedCurrencies => _symbols.keys.toList();

  /// Monedas principales para el toggle de visualización
  static const List<String> displayCurrencies = ['USD', 'VES', 'EUR'];

  /// Format amount with currency symbol: "$50.00" or "Bs. 1,825.00"
  static String formatAmount(double amount, String currencyCode) {
    final sym = symbol(currencyCode);
    final formatter = NumberFormat('#,##0.00', 'es_VE');
    final formatted = formatter.format(amount.abs());
    final sign = amount < 0 ? '-' : '';
    return '$sign$sym$formatted';
  }

  /// Formatea un monto convirtiéndolo a la moneda de visualización actual.
  /// [amount] es el monto en [baseCurrency] (la moneda del workspace).
  /// Retorna el monto formateado en displayCurrency.
  static String formatInDisplayCurrency(double amount, String baseCurrency) {
    final target = displayCurrency.value;
    if (target == baseCurrency) {
      return formatAmount(amount, baseCurrency);
    }

    if (!Get.isRegistered<ExchangeRateService>()) {
      return formatAmount(amount, baseCurrency);
    }

    final service = Get.find<ExchangeRateService>();
    final converted = service.convertAmount(amount, baseCurrency, target);
    return formatAmount(converted, target);
  }

  /// Formatea mostrando monto en displayCurrency + equivalencia en baseCurrency.
  /// Ej: "Bs. 47.406,00 ($100,00)"
  static String formatWithEquivalence(double amount, String baseCurrency) {
    final target = displayCurrency.value;
    if (target == baseCurrency) {
      return formatAmount(amount, baseCurrency);
    }

    if (!Get.isRegistered<ExchangeRateService>()) {
      return formatAmount(amount, baseCurrency);
    }

    final service = Get.find<ExchangeRateService>();
    final converted = service.convertAmount(amount, baseCurrency, target);
    final primary = formatAmount(converted, target);
    final secondary = formatAmount(amount, baseCurrency);
    return '$primary ($secondary)';
  }

  /// Format amount compactly for small spaces: "$50" or "Bs.1.8K"
  static String formatCompact(double amount, String currencyCode) {
    final sym = symbol(currencyCode);
    final formatter = NumberFormat.compact(locale: 'es');
    return '$sym${formatter.format(amount.abs())}';
  }

  /// Convert amount using exchange rate
  static double convert({
    required double amount,
    required double rate,
    bool fromBase = true,
  }) {
    if (rate <= 0) return 0.0;
    return fromBase ? amount * rate : amount / rate;
  }

  /// Format with dual currency: "$50.00 (Bs. 1,825.00)"
  static String formatDual({
    required double amount,
    required String primaryCurrency,
    required String secondaryCurrency,
    required double exchangeRate,
  }) {
    final primary = formatAmount(amount, primaryCurrency);
    if (exchangeRate <= 0) return primary;

    final converted = convert(amount: amount, rate: exchangeRate);
    final secondary = formatAmount(converted, secondaryCurrency);
    return '$primary ($secondary)';
  }

  /// Get the appropriate ExchangeRateProvider for converting to a target currency
  static ExchangeRateProvider? providerForCurrency(String targetCurrency) {
    switch (targetCurrency.toUpperCase()) {
      case 'VES':
        return ExchangeRateProvider.bcv;
      case 'EUR':
        return ExchangeRateProvider.bcvEur;
      default:
        return null;
    }
  }
}
