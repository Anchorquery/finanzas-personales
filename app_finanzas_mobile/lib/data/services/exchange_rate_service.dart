import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/exchange_rate.dart';
import '../../core/config/app_config.dart';

class ExchangeRateService extends GetxService {
  final RxMap<ExchangeRateProvider, ExchangeRate> currentRates =
      <ExchangeRateProvider, ExchangeRate>{}.obs;

  final Rxn<DateTime> lastFetchTime = Rxn<DateTime>();
  final _storage = GetStorage();

  static const _cacheKey = 'cached_exchange_rates';
  static const _lastFetchKey = 'last_exchange_rate_fetch';

  Future<ExchangeRateService> init() async {
    _loadCachedRates();
    return this;
  }

  void _loadCachedRates() {
    try {
      final cached = _storage.read<String>(_cacheKey);
      if (cached != null) {
        final Map<String, dynamic> data = json.decode(cached);
        data.forEach((key, value) {
          final provider = ExchangeRateProvider.values.firstWhere(
            (e) => e.name == key,
            orElse: () => ExchangeRateProvider.manual,
          );
          if (provider != ExchangeRateProvider.manual || key == 'manual') {
            currentRates[provider] = ExchangeRate.fromJson(value);
          }
        });
        Get.log('ExchangeRateService: Loaded ${currentRates.length} cached rates');
      }

      final lastFetch = _storage.read<String>(_lastFetchKey);
      if (lastFetch != null) {
        lastFetchTime.value = DateTime.tryParse(lastFetch);
      }
    } catch (e) {
      Get.log('ExchangeRateService: Error loading cache: $e');
    }
  }

  void _saveToCache() {
    try {
      final Map<String, dynamic> data = {};
      currentRates.forEach((key, value) {
        data[key.name] = value.toJson();
      });
      _storage.write(_cacheKey, json.encode(data));
      lastFetchTime.value = DateTime.now();
      _storage.write(_lastFetchKey, lastFetchTime.value!.toIso8601String());
    } catch (e) {
      Get.log('ExchangeRateService: Error saving cache: $e');
    }
  }

  String get _baseUrl => AppConfig.directusUrl;

  String get _bcvEndpoint => '$_baseUrl/bcv-rates';

  Future<void> fetchAllRates() async {
    await Future.wait([
      fetchBCVRates(),
      fetchBinanceRate(),
      fetchParallelRate(),
    ]);
    _saveToCache();
  }

  Future<void> fetchBCVRates() async {
    try {
      // Try fetching all providers from backend
      final response = await http
          .get(Uri.parse('$_bcvEndpoint/providers'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final providers = data['providers'] as Map<String, dynamic>?;

        if (providers != null && providers.containsKey('bcv')) {
          final bcv = providers['bcv'];
          final now = DateTime.tryParse(bcv['last_updated']?.toString() ?? '') ??
              DateTime.now();

          if (bcv['usd'] != null) {
            final rate = (bcv['usd'] as num).toDouble();
            if (rate > 0) {
              currentRates[ExchangeRateProvider.bcv] = ExchangeRate(
                provider: ExchangeRateProvider.bcv,
                rate: rate,
                lastUpdated: now,
              );
            }
          }

          if (bcv['eur'] != null) {
            final rate = (bcv['eur'] as num).toDouble();
            if (rate > 0) {
              currentRates[ExchangeRateProvider.bcvEur] = ExchangeRate(
                provider: ExchangeRateProvider.bcvEur,
                rate: rate,
                lastUpdated: now,
              );
            }
          }
        }

        // Also load other providers from backend if available
        if (providers != null && providers.containsKey('binance')) {
          final bin = providers['binance'];
          if (bin['usd'] != null) {
            currentRates[ExchangeRateProvider.binance] = ExchangeRate(
              provider: ExchangeRateProvider.binance,
              rate: (bin['usd'] as num).toDouble(),
              lastUpdated: DateTime.tryParse(bin['last_updated']?.toString() ?? '') ??
                  DateTime.now(),
            );
          }
        }

        if (providers != null && providers.containsKey('parallel')) {
          final par = providers['parallel'];
          if (par['usd'] != null) {
            currentRates[ExchangeRateProvider.parallel] = ExchangeRate(
              provider: ExchangeRateProvider.parallel,
              rate: (par['usd'] as num).toDouble(),
              lastUpdated: DateTime.tryParse(par['last_updated']?.toString() ?? '') ??
                  DateTime.now(),
            );
          }
        }

        return; // Success
      }
    } catch (e) {
      Get.log('ExchangeRateService: /providers failed, trying /bcv-rates: $e');
    }

    // Fallback: try the simple BCV endpoint
    try {
      final response = await http
          .get(Uri.parse(_bcvEndpoint))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['usd'] != null) {
          final double rate = (data['usd'] as num).toDouble();
          if (rate > 0) {
            currentRates[ExchangeRateProvider.bcv] = ExchangeRate(
              provider: ExchangeRateProvider.bcv,
              rate: rate,
              lastUpdated: DateTime.tryParse(data['last_updated'] ?? '') ??
                  DateTime.now(),
            );
          }
        }

        if (data['eur'] != null) {
          final double rate = (data['eur'] as num).toDouble();
          if (rate > 0) {
            currentRates[ExchangeRateProvider.bcvEur] = ExchangeRate(
              provider: ExchangeRateProvider.bcvEur,
              rate: rate,
              lastUpdated: DateTime.tryParse(data['last_updated'] ?? '') ??
                  DateTime.now(),
            );
          }
        }
      } else {
        Get.log('ExchangeRateService: BCV endpoint returned ${response.statusCode}');
        _useFallbackRates();
      }
    } catch (e) {
      Get.log('ExchangeRateService: Error fetching BCV rates: $e');
      _useFallbackRates();
    }
  }

  void _useFallbackRates() {
    // Use cached rates if available, otherwise hardcoded last-resort
    if (!currentRates.containsKey(ExchangeRateProvider.bcv)) {
      currentRates[ExchangeRateProvider.bcv] = ExchangeRate(
        provider: ExchangeRateProvider.bcv,
        rate: 474.06, // Last-resort fallback (BCV Apr 2026)
        lastUpdated: DateTime.now(),
        isEstimated: true,
      );
    }

    if (!currentRates.containsKey(ExchangeRateProvider.bcvEur)) {
      currentRates[ExchangeRateProvider.bcvEur] = ExchangeRate(
        provider: ExchangeRateProvider.bcvEur,
        rate: 550.90, // Last-resort fallback (BCV Apr 2026)
        lastUpdated: DateTime.now(),
        isEstimated: true,
      );
    }
  }

  Future<void> fetchBinanceRate() async {
    // If already loaded from backend /providers, skip
    if (currentRates.containsKey(ExchangeRateProvider.binance) &&
        !currentRates[ExchangeRateProvider.binance]!.isEstimated) {
      return;
    }

    try {
      // Try pydolarve API for Binance rate
      final response = await http
          .get(Uri.parse('https://pydolarve.org/api/v1/dollar?page=criptodolar'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // pydolarve returns monitors with price info
        final monitors = data['monitors'] as Map<String, dynamic>?;
        if (monitors != null) {
          // Look for USDT/binance rate
          final binance = monitors['binance'] ?? monitors['usdt'];
          if (binance != null && binance['price'] != null) {
            final rate = (binance['price'] as num).toDouble();
            if (rate > 0) {
              currentRates[ExchangeRateProvider.binance] = ExchangeRate(
                provider: ExchangeRateProvider.binance,
                rate: rate,
                lastUpdated: DateTime.now(),
              );
              return;
            }
          }
        }
      }
    } catch (e) {
      Get.log('ExchangeRateService: Error fetching Binance rate: $e');
    }

    // Fallback: estimate from BCV if available
    if (currentRates.containsKey(ExchangeRateProvider.bcv)) {
      final bcvRate = currentRates[ExchangeRateProvider.bcv]!.rate;
      currentRates[ExchangeRateProvider.binance] = ExchangeRate(
        provider: ExchangeRateProvider.binance,
        rate: double.parse((bcvRate * 1.02).toStringAsFixed(2)),
        lastUpdated: DateTime.now(),
        isEstimated: true,
      );
    }
  }

  Future<void> fetchParallelRate() async {
    // If already loaded from backend /providers, skip
    if (currentRates.containsKey(ExchangeRateProvider.parallel) &&
        !currentRates[ExchangeRateProvider.parallel]!.isEstimated) {
      return;
    }

    try {
      // Try pydolarve API for parallel rate
      final response = await http
          .get(Uri.parse('https://pydolarve.org/api/v1/dollar?page=alcambio'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final monitors = data['monitors'] as Map<String, dynamic>?;
        if (monitors != null) {
          final parallel = monitors['usd'] ?? monitors['enparalelovzla'];
          if (parallel != null && parallel['price'] != null) {
            final rate = (parallel['price'] as num).toDouble();
            if (rate > 0) {
              currentRates[ExchangeRateProvider.parallel] = ExchangeRate(
                provider: ExchangeRateProvider.parallel,
                rate: rate,
                lastUpdated: DateTime.now(),
              );
              return;
            }
          }
        }
      }
    } catch (e) {
      Get.log('ExchangeRateService: Error fetching Parallel rate: $e');
    }

    // Fallback: estimate from BCV
    if (currentRates.containsKey(ExchangeRateProvider.bcv)) {
      final bcvRate = currentRates[ExchangeRateProvider.bcv]!.rate;
      currentRates[ExchangeRateProvider.parallel] = ExchangeRate(
        provider: ExchangeRateProvider.parallel,
        rate: double.parse((bcvRate * 1.05).toStringAsFixed(2)),
        lastUpdated: DateTime.now(),
        isEstimated: true,
      );
    }
  }

  ExchangeRate? getRate(ExchangeRateProvider provider) {
    return currentRates[provider];
  }

  /// Get the active exchange rate for a workspace
  double getEffectiveRate(String mode, double manualRate) {
    if (mode == 'manual') return manualRate;

    final provider = ExchangeRateProvider.values.firstWhere(
      (e) => e.name == mode,
      orElse: () => ExchangeRateProvider.manual,
    );

    if (provider == ExchangeRateProvider.manual) return manualRate;
    return currentRates[provider]?.rate ?? 0.0;
  }

  /// Convierte un monto entre monedas usando las tasas BCV cargadas.
  /// Las tasas BCV expresan cuántos VES vale 1 unidad de la moneda extranjera.
  /// Ej: USD=474.06 significa 1 USD = 474.06 VES
  double convertAmount(double amount, String from, String to) {
    if (from == to || amount == 0) return amount;

    final bcvUsd = currentRates[ExchangeRateProvider.bcv]?.rate ?? 0;
    final bcvEur = currentRates[ExchangeRateProvider.bcvEur]?.rate ?? 0;

    // Convertir todo a VES primero, luego a la moneda destino
    double amountInVes;
    switch (from.toUpperCase()) {
      case 'VES':
        amountInVes = amount;
        break;
      case 'USD':
        amountInVes = bcvUsd > 0 ? amount * bcvUsd : amount;
        break;
      case 'EUR':
        amountInVes = bcvEur > 0 ? amount * bcvEur : amount;
        break;
      default:
        return amount; // Moneda no soportada
    }

    switch (to.toUpperCase()) {
      case 'VES':
        return amountInVes;
      case 'USD':
        return bcvUsd > 0 ? amountInVes / bcvUsd : amount;
      case 'EUR':
        return bcvEur > 0 ? amountInVes / bcvEur : amount;
      default:
        return amount;
    }
  }

  /// Human-readable time since last fetch
  String get lastFetchAgo {
    if (lastFetchTime.value == null) return 'Nunca';
    final diff = DateTime.now().difference(lastFetchTime.value!);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }
}
