part of '../directus_service.dart';

extension DirectusIncomeExtension on DirectusService {
  Future<List<IncomePlan>> getIncomePlans({String? workspaceId}) async {
    final effectiveWorkspaceId =
        workspaceId ?? Get.find<WorkspacesController>().activeWorkspace?.id;
    if (effectiveWorkspaceId == null) return [];

    const String queryStr = r'''
      query GetIncomePlans($workspaceId: ID!) {
        income_plans(filter: { workspace: { id: { _eq: $workspaceId } } }) {
          id
          name
          amount
          workspace { id }
        }
      }
    ''';

    final result = await query(
      queryStr,
      variables: {'workspaceId': effectiveWorkspaceId},
    );
    if (result.hasException) throw result.exception!;
    final data = result.data?['income_plans'] as List<dynamic>? ?? [];
    return data.map((e) => IncomePlan.fromJson(e)).toList();
  }

  Future<void> createIncomePlan(IncomePlan plan) async {
    const String mutation = r'''
      mutation CreateIncomePlan($data: create_income_plans_input!) {
        create_income_plans_item(data: $data) {
          id
        }
      }
    ''';

    final Map<String, dynamic> data = {
      'name': plan.name,
      'amount': plan.amount,
    };
    if (plan.workspaceId != null) {
      data['workspace'] = {'id': plan.workspaceId};
    }

    final result = await mutate(mutation, variables: {'data': data});
    if (result.hasException) {
      Get.log(
        '[DIRECTUS] Error in createIncomePlan (GQL): ${result.exception}',
      );
      final created = await createItemViaRest('income_plans', data);
      if (created == null) {
        throw result.exception!;
      }
    }
  }

  Future<void> updateIncomePlan(String id, {String? name, double? amount}) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (amount != null) data['amount'] = amount;
    if (data.isEmpty) return;

    const String mutation = r'''
      mutation UpdateIncomePlan($id: ID!, $data: update_income_plans_input!) {
        update_income_plans_item(id: $id, data: $data) { id }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id, 'data': data});
    if (result.hasException) {
      final updated = await updateItemViaRest('income_plans', id, data);
      if (updated == null) throw result.exception!;
    }
  }

  Future<void> deleteIncomePlan(String id) async {
    const String mutation = r'''
      mutation DeleteIncomePlan($id: ID!) {
        delete_income_plans_item(id: $id) { id }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id});
    if (result.hasException) {
      final deleted = await deleteItemViaRest('income_plans', id);
      if (!deleted) throw result.exception!;
    }
  }

  Future<void> createIncomeTransaction(Transaction transaction) async {
    final activeWsId = Get.find<WorkspacesController>().activeWorkspace?.id;
    if (transaction.category?.id == null) {
      throw Exception(
        'La transaccion de ingreso requiere una categoria valida',
      );
    }

    await createTransaction(
      amount: transaction.amount,
      concept: transaction.concept,
      date: transaction.date.toIso8601String().split('T')[0],
      type: 'income',
      categoryId: transaction.category!.id,
      workspaceId: activeWsId,
      receiptImageId: transaction.receiptImageId,
      savingGoalId: transaction.savingGoalId,
      debtId: transaction.debtId,
      isPersonal: transaction.isPersonal,
    );
  }

  Future<List<Transaction>> getIncomeTransactions({
    int limit = 10,
    String? workspaceId,
  }) async {
    final effectiveWorkspaceId =
        workspaceId ?? Get.find<WorkspacesController>().activeWorkspace?.id;
    if (effectiveWorkspaceId == null) return [];

    const String readTransactions = r'''
      query ReadIncomeTransactions($filter: transactions_filter, $limit: Int) {
        transactions(
          sort: ["-date"],
          filter: $filter,
          limit: $limit
        ) {
          id
          amount
          concept
          date
          type
          user_created {
            id
            first_name
            email
            avatar {
              id
            }
          }
          receipt_image {
            id
          }
          category {
            id
            name
            icon
            color
          }
        }
      }
    ''';

    final result = await query(
      readTransactions,
      variables: {
        'filter': {
          'type': {'_eq': 'income'},
          'workspace': {
            'id': {'_eq': effectiveWorkspaceId},
          },
        },
        'limit': limit,
      },
    );

    if (result.hasException) return [];
    final data = result.data?['transactions'] as List<dynamic>? ?? [];
    return data.map((e) => Transaction.fromJson(e)).toList();
  }
}
