enum ExchangeRateProvider {
  manual,
  bcv, // USD
  bcvEur, // EUR
  binance, // USDT
  parallel, // General
}

class ExchangeRate {
  final ExchangeRateProvider provider;
  final double rate;
  final DateTime lastUpdated;
  final String currencyCode;
  final bool isEstimated;

  ExchangeRate({
    required this.provider,
    required this.rate,
    required this.lastUpdated,
    this.currencyCode = 'VES',
    this.isEstimated = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'rate': rate,
      'last_updated': lastUpdated.toIso8601String(),
      'currency_code': currencyCode,
      'is_estimated': isEstimated,
    };
  }

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      provider: ExchangeRateProvider.values.firstWhere(
        (e) => e.name == json['provider']?.toString(),
        orElse: () => ExchangeRateProvider.manual,
      ),
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: DateTime.tryParse(json['last_updated']?.toString() ?? '') ?? DateTime.now(),
      currencyCode: json['currency_code']?.toString() ?? 'VES',
      isEstimated: json['is_estimated'] == true,
    );
  }
}
