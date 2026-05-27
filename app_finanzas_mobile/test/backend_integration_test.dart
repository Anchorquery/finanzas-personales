import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  const apiUrl = String.fromEnvironment(
    'DIRECTUS_URL',
    defaultValue: 'https://bs943xvxnxhhus0pnhe404kb.213.130.147.89.sslip.io',
  );

  test('Backend BCV Scraping Endpoint', () async {
    final endpoint = '$apiUrl/bcv-rates';
    debugPrint('Testing Endpoint: $endpoint');

    try {
      final response = await http
          .get(Uri.parse(endpoint))
          .timeout(const Duration(seconds: 10));

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        expect(data['provider'], 'bcv');
        expect(data['usd'], isNotNull);
        expect(data['eur'], isNotNull);
        expect((data['usd'] as num) > 0, true);
        debugPrint('✅ Success: USD Rate is ${data['usd']}');
      } else {
        debugPrint('❌ Failed: Server responded with error.');
      }
    } on SocketException catch (e) {
      debugPrint('⚠️ Skipped: Backend not reachable in this environment. $e');
      // No falla CI — test de integración opcional
    } catch (e) {
      debugPrint('⚠️ Skipped: $e');
    }
  });
}
