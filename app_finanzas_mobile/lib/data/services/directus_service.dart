import 'dart:async';
import 'dart:io';

import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:graphql_flutter/graphql_flutter.dart' hide Subscription;
import '../../core/utils/app_storage.dart';
import 'package:dio/dio.dart' as dio;

// Models
import 'package:app_finanzas_mobile/data/models/finance/transaction.dart';
import 'package:app_finanzas_mobile/data/models/user.dart';
import 'package:app_finanzas_mobile/data/models/finance/budget.dart';
import 'package:app_finanzas_mobile/data/models/finance/saving.dart';
import 'package:app_finanzas_mobile/data/models/workspace.dart';
import 'package:app_finanzas_mobile/data/models/organization.dart';
import 'package:app_finanzas_mobile/data/models/finance/category.dart';
import 'package:app_finanzas_mobile/data/models/finance/dashboard_summary.dart';
import 'package:app_finanzas_mobile/data/models/finance/transaction_item.dart';
import 'package:app_finanzas_mobile/data/models/finance/income_plan.dart';
import 'package:app_finanzas_mobile/data/models/finance/account.dart';
import 'package:app_finanzas_mobile/data/models/finance/debt.dart';
import 'package:app_finanzas_mobile/data/models/invitation.dart';
import 'package:app_finanzas_mobile/data/models/finance/event.dart';
import 'package:app_finanzas_mobile/data/models/finance/subscription.dart';

export 'package:app_finanzas_mobile/data/models/finance/transaction.dart';
export 'package:app_finanzas_mobile/data/models/user.dart';
export 'package:app_finanzas_mobile/data/models/finance/budget.dart';
export 'package:app_finanzas_mobile/data/models/finance/saving.dart';
export 'package:app_finanzas_mobile/data/models/workspace.dart';
export 'package:app_finanzas_mobile/data/models/organization.dart';
export 'package:app_finanzas_mobile/data/models/finance/category.dart';
export 'package:app_finanzas_mobile/data/models/finance/dashboard_summary.dart';
export 'package:app_finanzas_mobile/data/models/finance/transaction_item.dart';
export 'package:app_finanzas_mobile/data/models/finance/income_plan.dart';
export 'package:app_finanzas_mobile/data/models/finance/account.dart';
export 'package:app_finanzas_mobile/data/models/finance/debt.dart';
export 'package:app_finanzas_mobile/data/models/invitation.dart';
export 'package:app_finanzas_mobile/data/models/finance/event.dart';
export 'package:app_finanzas_mobile/data/models/finance/subscription.dart';

// Controllers/Services
import 'auth_service.dart';
import 'package:app_finanzas_mobile/modules/workspaces/controllers/workspaces_controller.dart';
import 'package:app_finanzas_mobile/core/config/app_config.dart';

// Parts
part 'directus/transactions_part.dart';
part 'directus/budgets_part.dart';
part 'directus/savings_part.dart';
part 'directus/workspaces_part.dart';
part 'directus/categories_part.dart';
part 'directus/accounts_part.dart';
part 'directus/debts_part.dart';
part 'directus/income_part.dart';
part 'directus/extra_part.dart';
part 'directus/auth_gql_part.dart';
part 'directus/rest_part.dart';

class DirectusService extends GetxService {
  late GraphQLClient _client;
  late GraphQLClient _systemClient;
  late String serverUrl;

  GraphQLClient get client => _client;
  GraphQLClient get systemClient => _systemClient;

  final RxString currentUserId = ''.obs;
  /// Incrementa cada vez que se crea/edita/elimina datos. Los controllers escuchan esto para refrescar.
  final RxInt dataVersion = 0.obs;
  void notifyDataChanged() => dataVersion.value++;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  Future<DirectusService> init() async {
    serverUrl = AppConfig.directusUrl;

    final HttpLink httpLink = HttpLink('$serverUrl/graphql');
    final HttpLink systemHttpLink = HttpLink('$serverUrl/graphql/system');

    final AuthLink authLink = AuthLink(
      getToken: () async {
        final currentToken = await AppStorage.read(key: 'auth_token');
        return currentToken != null ? 'Bearer $currentToken' : null;
      },
    );

    const authErrorCodes = {
      'TOKEN_EXPIRED',
      'INVALID_TOKEN',
      'FORBIDDEN',
    };

    bool isAuthError(GraphQLError e) {
      final code = e.extensions?['code']?.toString();
      return code != null && authErrorCodes.contains(code);
    }

    final ErrorLink errorLink = ErrorLink(
      onGraphQLError: (Request request, NextLink forward, Response response) async* {
        final errors = response.errors;
        if (errors != null && errors.any(isAuthError)) {
          Get.log('[DIRECTUS] Auth error detected in onGraphQLError');
          final success = await refreshToken();
          if (success) {
            final newToken = await AppStorage.read(key: 'auth_token');
            yield* forward(request.updateContextEntry<HttpLinkHeaders>(
              (headers) => HttpLinkHeaders(
                headers: {
                  ...headers?.headers ?? {},
                  'Authorization': 'Bearer $newToken',
                },
              ),
            ));
            return;
          }
        }
        yield response;
      },
      onException: (Request request, NextLink forward, LinkException exception) async* {
        if (exception is ServerException) {
          final code = exception.parsedResponse?.errors?.first.extensions?['code']?.toString();

          if (code != null && authErrorCodes.contains(code)) {
            Get.log('[DIRECTUS] Auth error detected in onException (ServerException)');
            final success = await refreshToken();
            if (success) {
              final newToken = await AppStorage.read(key: 'auth_token');
              yield* forward(request.updateContextEntry<HttpLinkHeaders>(
                (headers) => HttpLinkHeaders(
                  headers: {
                    ...headers?.headers ?? {},
                    'Authorization': 'Bearer $newToken',
                  },
                ),
              ));
              return;
            }
          }
        }
        throw exception;
      },
    );

    final Link link = errorLink.concat(authLink).concat(httpLink);
    final Link systemLink = errorLink.concat(authLink).concat(systemHttpLink);

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );

    _systemClient = GraphQLClient(
      link: systemLink,
      cache: GraphQLCache(),
    );

    return this;
  }

  Future<QueryResult> query(String doc, {Map<String, dynamic>? variables}) async {
    Get.log('[DIRECTUS] Query: $doc');
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(doc),
          variables: variables ?? {},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      ).timeout(const Duration(seconds: 15));
      if (result.hasException) {
        Get.log('[DIRECTUS] Query Exception: ${result.exception}');
      }
      return result;
    } catch (e) {
      Get.log('[DIRECTUS] Query error (Timeout?): $e');
      rethrow;
    }
  }

  Future<QueryResult> mutate(String doc, {Map<String, dynamic>? variables}) async {
    Get.log('[DIRECTUS] Mutation: $doc');
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(doc),
          variables: variables ?? {},
        ),
      ).timeout(const Duration(seconds: 15));
      if (result.hasException) {
        Get.log('[DIRECTUS] Mutation Exception: ${result.exception}');
      }
      return result;
    } catch (e) {
      Get.log('[DIRECTUS] Mutation error (Timeout?): $e');
      rethrow;
    }
  }

  Future<bool> refreshToken() async {
    if (_isRefreshing) {
      Get.log('[DIRECTUS] Refresh already in progress, waiting...');
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      Get.log('[DIRECTUS] Starting synchronized token refresh...');
      final refreshTokenValue = await AppStorage.read(key: 'refresh_token');

      if (refreshTokenValue == null) {
        Get.log('[DIRECTUS] No refresh token found, logout required');
        await _handleLogout();
        _isRefreshing = false;
        _refreshCompleter!.complete(false);
        return false;
      }

      final dio.Dio dioInstance = dio.Dio(dio.BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      final response = await dioInstance.post(
        '$serverUrl/auth/refresh',
        data: {'refresh_token': refreshTokenValue, 'mode': 'json'},
      );

      if (response.statusCode == 200) {
        final responseBody = response.data;
        final data = responseBody is Map ? responseBody['data'] : null;
        if (data == null || data['access_token'] == null) {
          Get.log('[DIRECTUS] Refresh response missing data, logging out');
          await _handleLogout();
          _isRefreshing = false;
          _refreshCompleter!.complete(false);
          return false;
        }
        await AppStorage.write(key: 'auth_token', value: data['access_token'].toString());
        await AppStorage.write(key: 'refresh_token', value: data['refresh_token']?.toString());
        
        // Re-init clients with new token
        await init();

        _isRefreshing = false;
        _refreshCompleter!.complete(true);
        return true;
      }

      await _handleLogout();
      _isRefreshing = false;
      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      Get.log('[DIRECTUS] Error refreshing token: $e');
      await _handleLogout();
      _isRefreshing = false;
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(false);
      }
      return false;
    }
  }

  Future<void> _handleLogout({bool notifyAuthService = true}) async {
    await AppStorage.delete(key: 'auth_token');
    await AppStorage.delete(key: 'refresh_token');

    if (notifyAuthService && Get.isRegistered<AuthService>()) {
      await Get.find<AuthService>().logout(clearServerSession: false);
    }
  }

  Future<void> logout({bool notifyAuthService = true}) async {
    await _handleLogout(notifyAuthService: notifyAuthService);
    await init();
  }
}
