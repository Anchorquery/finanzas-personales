part of '../directus_service.dart';

extension DirectusDebtExtension on DirectusService {
  Future<List<Debt>> getDebts({String? workspaceId}) async {
    final activeWorkspaceId = workspaceId ?? Get.find<WorkspacesController>().activeWorkspace?.id;
    if (activeWorkspaceId == null) return [];

    const String readDebts = r'''
      query ReadDebts($workspaceId: ID!) {
        debts(
          filter: { workspace: { id: { _eq: $workspaceId } } }
          sort: ["-due_date"]
        ) {
          id
          name
          total_amount
          remaining_amount
          interest_rate
          due_date
          status
          user_created {
            id
            first_name
          }
        }
      }
    ''';
    final result = await query(
      readDebts,
      variables: {'workspaceId': activeWorkspaceId},
    );
    if (result.hasException) throw result.exception!;
    final data = result.data?['debts'] as List<dynamic>? ?? [];
    return data.map((e) => Debt.fromJson(e)).toList();
  }

  Future<void> createDebt(Debt debt) async {
    const String mutation = r'''
      mutation CreateDebt($data: create_debts_input!) {
        create_debts_item(data: $data) {
          id
        }
      }
    ''';

    final Map<String, dynamic> data = {
      'name': debt.name,
      'total_amount': debt.totalAmount,
      'remaining_amount': debt.remainingAmount,
      'interest_rate': debt.interestRate,
      'due_date': debt.dueDate?.toIso8601String(),
      'status': debt.status,
    };
    if (debt.workspaceId != null) {
      data['workspace'] = {'id': debt.workspaceId};
    }

    final result = await mutate(mutation, variables: {'data': data});
    if (result.hasException) {
      Get.log('[DIRECTUS] Error in createDebt (GQL): ${result.exception}');
      throw result.exception!;
    }
  }

  Future<void> updateDebt(String id, Map<String, dynamic> data) async {
    const String mutation = r'''
      mutation UpdateDebt($id: ID!, $data: update_debts_input!) {
        update_debts_item(id: $id, data: $data) {
          id
        }
      }
    ''';
    
    // No mapping needed, IDs should be direct
    final result = await mutate(mutation, variables: {'id': id, 'data': data});
    if (result.hasException) throw result.exception!;
  }

  Future<void> deleteDebt(String id) async {
    const String mutation = r'''
      mutation DeleteDebt($id: ID!) {
        delete_debts_item(id: $id) { id }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id});
    if (result.hasException) {
      final deleted = await deleteItemViaRest('debts', id);
      if (!deleted) throw result.exception!;
    }
  }
}
