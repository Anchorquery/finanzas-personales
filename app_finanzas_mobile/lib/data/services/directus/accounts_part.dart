part of '../directus_service.dart';

extension DirectusAccountExtension on DirectusService {
  Future<List<Account>> getAccounts({String? workspaceId}) async {
    final effectiveWorkspaceId =
        workspaceId ?? Get.find<WorkspacesController>().activeWorkspace?.id;
    if (effectiveWorkspaceId == null) return [];

    const String queryStr = r'''
      query GetAccounts($workspaceId: ID!) {
        accounts(filter: { workspace: { id: { _eq: $workspaceId } } }) {
          id
          name
          type
          initial_balance
          currency
          workspace {
            id
          }
        }
      }
    ''';

    final result = await query(
      queryStr,
      variables: {'workspaceId': effectiveWorkspaceId},
    );
    if (result.hasException) throw result.exception!;
    final data = result.data?['accounts'] as List<dynamic>? ?? [];
    return data.map((e) => Account.fromJson(e)).toList();
  }

  Future<void> createAccount(Account account) async {
    const String mutation = r'''
      mutation CreateAccount($data: create_accounts_input!) {
        create_accounts_item(data: $data) {
          id
        }
      }
    ''';

    final Map<String, dynamic> data = account.toJson();
    data.remove('id');
    if (account.workspaceId != null) {
      data['workspace'] = {'id': account.workspaceId};
    }

    final result = await mutate(mutation, variables: {'data': data});
    if (result.hasException) {
      Get.log('[DIRECTUS] Error in createAccount (GQL): ${result.exception}');
      final created = await createItemViaRest('accounts', data);
      if (created == null) {
        throw result.exception!;
      }
    }
  }

  Future<void> updateAccount(String id, Map<String, dynamic> data) async {
    const String mutation = r'''
      mutation UpdateAccount($id: ID!, $data: update_accounts_input!) {
        update_accounts_item(id: $id, data: $data) {
          id
        }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id, 'data': data});
    if (result.hasException) throw result.exception!;
  }

  Future<void> deleteAccount(String id) async {
    const String mutation = r'''
      mutation DeleteAccount($id: ID!) {
        delete_accounts_item(id: $id) {
          id
        }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id});
    if (result.hasException) throw result.exception!;
  }
}
