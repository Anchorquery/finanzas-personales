part of '../directus_service.dart';

extension DirectusRestExtension on DirectusService {
  Future<String?> _readRestToken() async {
    return AppStorage.read(key: 'auth_token');
  }

  Future<dio.Dio> _buildRestClient() async {
    return dio.Dio(
      dio.BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );
  }

  Future<List<Map<String, dynamic>>?> readItemsViaRest(
    String collection, {
    Map<String, dynamic>? queryParameters,
  }) async {
    Future<dio.Response<dynamic>> sendRequest(
      String token,
      Map<String, dynamic>? params,
    ) async {
      final dioInstance = await _buildRestClient();

      return dioInstance.get(
        '$serverUrl/items/$collection',
        queryParameters: params,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    }

    try {
      var token = await _readRestToken();
      if (token == null || token.isEmpty) {
        Get.log('[DIRECTUS] REST read $collection aborted: missing auth token');
        return null;
      }

      dio.Response<dynamic> response;
      try {
        response = await sendRequest(token, queryParameters);
      } on dio.DioException catch (e) {
        final statusCode = e.response?.statusCode;
        if (statusCode != 401 && statusCode != 403) {
          rethrow;
        }

        final refreshed = await refreshToken();
        if (!refreshed) {
          return null;
        }

        token = await _readRestToken();
        if (token == null || token.isEmpty) {
          return null;
        }

        response = await sendRequest(token, queryParameters);
      }

      final responseData = response.data?['data'];
      if (responseData is List) {
        return responseData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      return const <Map<String, dynamic>>[];
    } on dio.DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      Get.log(
        '[DIRECTUS] Error reading $collection via REST: '
        'status=$statusCode response=$responseData error=$e',
      );
      return null;
    } catch (e) {
      Get.log('[DIRECTUS] Error reading $collection via REST: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createItemViaRest(
    String collection,
    Map<String, dynamic> data,
  ) async {
    Future<dio.Response<dynamic>> sendRequest(String token) async {
      final dioInstance = await _buildRestClient();

      return dioInstance.post(
        '$serverUrl/items/$collection',
        data: data,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    }

    try {
      var token = await _readRestToken();
      if (token == null || token.isEmpty) {
        Get.log(
          '[DIRECTUS] REST create $collection aborted: missing auth token',
        );
        return null;
      }

      dio.Response<dynamic> response;
      try {
        response = await sendRequest(token);
      } on dio.DioException catch (e) {
        final statusCode = e.response?.statusCode;
        if (statusCode != 401 && statusCode != 403) {
          rethrow;
        }

        final refreshed = await refreshToken();
        if (!refreshed) {
          return null;
        }

        token = await _readRestToken();
        if (token == null || token.isEmpty) {
          return null;
        }

        response = await sendRequest(token);
      }

      final responseData = response.data?['data'];
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }

      if (responseData is Map) {
        return Map<String, dynamic>.from(responseData);
      }

      return <String, dynamic>{};
    } on dio.DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      Get.log(
        '[DIRECTUS] Error creating $collection via REST: '
        'status=$statusCode response=$responseData error=$e',
      );
      return null;
    } catch (e) {
      Get.log('[DIRECTUS] Error creating $collection via REST: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateItemViaRest(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    Future<dio.Response<dynamic>> sendRequest(String token) async {
      final dioInstance = await _buildRestClient();

      return dioInstance.patch(
        '$serverUrl/items/$collection/$id',
        data: data,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    }

    try {
      var token = await _readRestToken();
      if (token == null || token.isEmpty) {
        Get.log(
          '[DIRECTUS] REST update $collection/$id aborted: missing auth token',
        );
        return null;
      }

      dio.Response<dynamic> response;
      try {
        response = await sendRequest(token);
      } on dio.DioException catch (e) {
        final statusCode = e.response?.statusCode;
        if (statusCode != 401 && statusCode != 403) {
          rethrow;
        }

        final refreshed = await refreshToken();
        if (!refreshed) {
          return null;
        }

        token = await _readRestToken();
        if (token == null || token.isEmpty) {
          return null;
        }

        response = await sendRequest(token);
      }

      final responseData = response.data?['data'];
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      if (responseData is Map) {
        return Map<String, dynamic>.from(responseData);
      }
      return <String, dynamic>{};
    } on dio.DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      Get.log(
        '[DIRECTUS] Error updating $collection/$id via REST: '
        'status=$statusCode response=$responseData error=$e',
      );
      return null;
    } catch (e) {
      Get.log('[DIRECTUS] Error updating $collection/$id via REST: $e');
      return null;
    }
  }

  Future<bool> deleteItemViaRest(String collection, String id) async {
    Future<dio.Response<dynamic>> sendRequest(String token) async {
      final dioInstance = await _buildRestClient();

      return dioInstance.delete(
        '$serverUrl/items/$collection/$id',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    }

    try {
      var token = await _readRestToken();
      if (token == null || token.isEmpty) {
        Get.log(
          '[DIRECTUS] REST delete $collection/$id aborted: missing auth token',
        );
        return false;
      }

      try {
        await sendRequest(token);
        return true;
      } on dio.DioException catch (e) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          final refreshed = await refreshToken();
          if (!refreshed) {
            return false;
          }

          token = await _readRestToken();
          if (token == null || token.isEmpty) {
            return false;
          }

          await sendRequest(token);
          return true;
        }

        Get.log(
          '[DIRECTUS] Error deleting $collection/$id via REST: '
          'status=$statusCode response=${e.response?.data} error=$e',
        );
        return false;
      }
    } catch (e) {
      Get.log('[DIRECTUS] Error deleting $collection/$id via REST: $e');
      return false;
    }
  }

  // --- USER REST ---
  Future<bool> updateCurrentUserProfile(Map<String, dynamic> data) async {
    try {
      var token = await _readRestToken();
      if (token == null || token.isEmpty) return false;
      final dioInstance = await _buildRestClient();
      final response = await dioInstance.patch(
        '$serverUrl/users/me',
        data: data,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      Get.log('[DIRECTUS] Error updating user profile: $e');
      return false;
    }
  }

  // --- AUTH REST ---
  Future<bool> login(String email, String password) async {
    try {
      final dio.Dio dioInstance = dio.Dio(
        dio.BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      final response = await dioInstance.post(
        '$serverUrl/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];

        await AppStorage.write(key: 'auth_token', value: accessToken);
        await AppStorage.write(key: 'refresh_token', value: refreshToken);

        await init();
        return true;
      }
      return false;
    } catch (e) {
      Get.log('[DIRECTUS] Login error: $e');
      rethrow;
    }
  }

  Future<bool> createUser(String name, String email, String password) async {
    try {
      final dio.Dio dioInstance = dio.Dio(
        dio.BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final response = await dioInstance.post(
        '$serverUrl/users',
        data: {
          'first_name': name,
          'email': email,
          'password': password,
          'role': AppConfig.defaultUserRole,
          'status': 'active',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      Get.log('[DIRECTUS] Create user error: $e');
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final dio.Dio dioInstance = dio.Dio(
        dio.BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final response = await dioInstance.post(
        '$serverUrl/auth/password/request',
        data: {'email': email},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      Get.log('[DIRECTUS] Password reset request error: $e');
      return false;
    }
  }

  /// Cambia la contraseña usando el token recibido por correo.
  /// Endpoint Directus: `POST /auth/password/reset` con `{token, password}`.
  Future<bool> resetPassword(String token, String password) async {
    try {
      final dio.Dio dioInstance = dio.Dio(
        dio.BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final response = await dioInstance.post(
        '$serverUrl/auth/password/reset',
        data: {'token': token, 'password': password},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      Get.log('[DIRECTUS] Password reset error: $e');
      return false;
    }
  }

  // --- FILES REST ---
  Future<String?> uploadFile(File file) async {
    try {
      final String? token = await AppStorage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        Get.log('[DIRECTUS] uploadFile aborted: missing auth token');
        return null;
      }
      final dio.Dio dioInstance = dio.Dio();
      final String fileName = file.path.split(RegExp(r'[/\\]')).last;

      final dio.FormData formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await dioInstance.post(
        '$serverUrl/files',
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.data['data']['id'];
      }
      return null;
    } catch (e) {
      Get.log('[DIRECTUS] Error uploading file: $e');
      return null;
    }
  }
}
