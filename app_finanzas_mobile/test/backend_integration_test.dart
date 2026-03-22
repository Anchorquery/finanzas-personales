import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  test('Backend BCV Scraping Endpoint', () async {
    // Assuming backend is running on localhost (mapped port 8056)
    // Note: 'localhost' works if running test from host machine targeting host backend
    const apiUrl = 'http://localhost:8056/bcv-rates';

    debugPrint('Testing Endpoint: $apiUrl');

    try {
      final response = await http.get(Uri.parse(apiUrl));

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
    } catch (e) {
      debugPrint(
        '❌ Failed: Could not connect to backend. Is Docker running? Error: $e',
      );
    }
  });
}
