part of '../directus_service.dart';

extension DirectusBudgetExtension on DirectusService {
  Future<List<Budget>> getBudgetsStatus(String workspaceId) async {
    const String readBudgets = r'''
      query ReadBudgets($workspaceId: ID!) {
        budgets(filter: { workspace: { id: { _eq: $workspaceId } } }) {
          id
          limit
          category {
            id
            name
          }
        }
      }
    ''';

    final budgetsResult = await query(
      readBudgets,
      variables: {'workspaceId': workspaceId},
    );
    if (budgetsResult.hasException) throw budgetsResult.exception!;
    final budgetsData = List<Map<String, dynamic>>.from(
      budgetsResult.data?['budgets'] ?? [],
    );

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      1,
    ).toIso8601String().split('T')[0];
    final end = DateTime(
      now.year,
      now.month + 1,
      0,
    ).toIso8601String().split('T')[0];

    const String readExpenses = r'''
      query MonthlyExpenses($start: GraphQLStringOrFloat, $end: GraphQLStringOrFloat, $workspaceId: ID!) {
        transactions(filter: { 
          date: { _between: [$start, $end] }, 
          type: { _eq: "expense" },
          workspace: { id: { _eq: $workspaceId } }
        }) {
          amount
          category {
            id
          }
        }
      }
    ''';

    final expensesResult = await query(
      readExpenses,
      variables: {'start': start, 'end': end, 'workspaceId': workspaceId},
    );
    if (expensesResult.hasException) throw expensesResult.exception!;
    final expensesData = List<Map<String, dynamic>>.from(
      expensesResult.data?['transactions'] ?? [],
    );

    final Map<String, double> spentByCategory = {};
    for (var tx in expensesData) {
      final catId = tx['category']?['id'];
      final amount = double.tryParse(tx['amount'].toString()) ?? 0.0;
      if (catId != null) {
        spentByCategory[catId] = (spentByCategory[catId] ?? 0.0) + amount;
      }
    }

    return budgetsData.map((b) {
      final catId = b['category']?['id'];
      final limit = double.tryParse(b['limit'].toString()) ?? 0.0;
      final spent = spentByCategory[catId] ?? 0.0;
      final percent = limit > 0 ? (spent / limit) * 100 : 0.0;

      return Budget(
        id: b['id']?.toString() ?? '',
        name: b['category']?['name']?.toString() ?? 'Presupuesto',
        limit: limit,
        spent: spent,
        percent: percent,
      );
    }).toList();
  }

  Future<void> createBudget({
    required double limit,
    required String categoryId,
    String? workspaceId,
  }) async {
    const String mutation = r'''
      mutation CreateBudget($data: create_budgets_input!) {
        create_budgets_item(data: $data) {
          id
        }
      }
    ''';
    final Map<String, dynamic> data = {
      'limit': limit,
      'category': {'id': categoryId},
    };
    if (workspaceId != null) {
      data['workspace'] = {'id': workspaceId};
    }
    final result = await mutate(mutation, variables: {'data': data});
    if (result.hasException) {
      Get.log('[DIRECTUS] Error in createBudget (GQL): ${result.exception}');
      final created = await createItemViaRest('budgets', data);
      if (created == null) {
        throw result.exception!;
      }
    }
  }

  Future<void> updateBudget(String id, double limit) async {
    const String updateMutation = r'''
      mutation UpdateBudget($id: ID!, $limit: Float!) {
        update_budgets_item(id: $id, data: { limit: $limit }) {
          id
          limit
        }
      }
    ''';

    final result = await mutate(
      updateMutation,
      variables: {'id': id, 'limit': limit},
    );

    if (result.hasException) throw result.exception!;
  }

  Future<void> deleteBudget(String id) async {
    const String mutation = r'''
      mutation DeleteBudget($id: ID!) {
        delete_budgets_item(id: $id) { id }
      }
    ''';
    final result = await mutate(mutation, variables: {'id': id});
    if (result.hasException) {
      final deleted = await deleteItemViaRest('budgets', id);
      if (!deleted) throw result.exception!;
    }
  }
}
