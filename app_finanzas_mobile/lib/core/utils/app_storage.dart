import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

/// Storage adaptativo:
/// - Web → GetStorage (localStorage del navegador)
/// - Mobile/Desktop → FlutterSecureStorage (keychain/keystore)
class AppStorage {
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static final _web = GetStorage();

  static Future<void> write({required String key, required String? value}) async {
    if (kIsWeb) {
      if (value == null) {
        _web.remove(key);
      } else {
        await _web.write(key, value);
      }
    } else {
      await _secure.write(key: key, value: value);
    }
  }

  static Future<String?> read({required String key}) async {
    if (kIsWeb) {
      return _web.read<String>(key);
    } else {
      return _secure.read(key: key);
    }
  }

  static Future<void> delete({required String key}) async {
    if (kIsWeb) {
      _web.remove(key);
    } else {
      await _secure.delete(key: key);
    }
  }
}
