part of '../directus_service.dart';

extension DirectusTransactionExtension on DirectusService {
  Future<List<Transaction>> getTransactions({
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? workspaceId,
    String? accountId,
    String? type,
  }) async {
    const String readTransactions = r'''
      query ReadTransactions($limit: Int, $offset: Int, $filter: transactions_filter) {
        transactions(limit: $limit, offset: $offset, sort: ["-date"], filter: $filter) {
          id
          amount
          concept
          date
          type
          receipt_image {
            id
          }
          category {
            id
            name
            icon
            color
            type
          }
          workspace {
            id
          }
          account {
            id
          }
          debt {
            id
            name
          }
          user_created {
            id
            first_name
            email
            avatar {
              id
            }
          }
          items {
            id
            name
            quantity
            unit_price
            total_price
            category_name
          }
        }
      }
    ''';

    Map<String, dynamic> filter = {};
    if (startDate != null && endDate != null) {
      final start = startDate.toIso8601String().split('T')[0];
      final end = endDate.toIso8601String().split('T')[0];
      filter['date'] = {
        '_between': [start, end],
      };
    }

    if (categoryId != null) {
      filter['category'] = {
        'id': {'_eq': categoryId},
      };
    }

    if (workspaceId != null) {
      filter['workspace'] = {
        'id': {'_eq': workspaceId},
      };
    }

    if (accountId != null) {
      filter['account'] = {
        'id': {'_eq': accountId},
      };
    }

    if (type != null) {
      filter['type'] = {'_eq': type};
    }

    final result = await query(
      readTransactions,
      variables: {
        'limit': limit,
        'offset': offset,
        'filter': filter.isNotEmpty ? filter : null,
      },
    );
    if (result.hasException) {
      throw result.exception!;
    }
    final data = result.data?['transactions'] as List<dynamic>? ?? [];
    return data.map((e) => Transaction.fromJson(e)).toList();
  }

  Future<DashboardSummary> getDashboardSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? workspaceId,
  }) async {
    try {
      final startIso = startDate.toIso8601String().split('T')[0];
      final endIso = endDate.toIso8601String().split('T')[0];

      // Using variables instead of string injection for better type handling
      const queryStr = r'''
        query GetDashboardSummary($start: GraphQLStringOrFloat, $end: GraphQLStringOrFloat, $workspaceId: ID) {
          income: transactions(
            filter: {
              date: { _between: [$start, $end] }
              type: { _eq: "income" }
              workspace: { id: { _eq: $workspaceId } }
            }
          ) {
            amount
          }
          expense: transactions(
            filter: {
              date: { _between: [$start, $end] }
              type: { _eq: "expense" }
              workspace: { id: { _eq: $workspaceId } }
            }
          ) {
            amount
          }
          lifetimeFlow: transactions(
            filter: {
              workspace: { id: { _eq: $workspaceId } }
            }
          ) {
            amount
            type
          }
          accounts(filter: { workspace: { id: { _eq: $workspaceId } } }) {
            initial_balance
          }
        }
      ''';

      final result = await _client.query(
        QueryOptions(
          document: gql(queryStr),
          variables: {
            'start': startIso,
            'end': endIso,
            'workspaceId': workspaceId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final data = result.data!;

      final incomeList = List<Map<String, dynamic>>.from(data['income']);
      final expenseList = List<Map<String, dynamic>>.from(data['expense']);
      final lifetimeFlow = List<Map<String, dynamic>>.from(
        data['lifetimeFlow'] ?? const [],
      );
      final accounts = List<Map<String, dynamic>>.from(
        data['accounts'] ?? const [],
      );
      final double totalIncome = incomeList.fold(
        0.0,
        (sum, item) =>
            sum + (double.tryParse(item['amount'].toString()) ?? 0.0),
      );
      final double totalExpense = expenseList.fold(
        0.0,
        (sum, item) =>
            sum + (double.tryParse(item['amount'].toString()) ?? 0.0),
      );
      final double openingBalance = accounts.fold(0.0, (sum, account) {
        return sum +
            (double.tryParse(account['initial_balance']?.toString() ?? '0') ??
                0.0);
      });
      final double lifetimeNet = lifetimeFlow.fold(0.0, (sum, item) {
        final amount = double.tryParse(item['amount'].toString()) ?? 0.0;
        return item['type'] == 'income' ? sum + amount : sum - amount;
      });
      final double balance = openingBalance + lifetimeNet;

      return DashboardSummary(
        currentBalance: balance,
        monthlyIncome: totalIncome,
        monthlyExpenses: totalExpense,
        openingBalance: openingBalance,
      );
    } catch (e) {
      Get.log('Error getting dashboard summary: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDailyCashFlow({
    required DateTime startDate,
    required DateTime endDate,
    String? workspaceId,
  }) async {
    try {
      final startIso = startDate.toIso8601String().split('T')[0];
      final endIso = endDate.toIso8601String().split('T')[0];

      const queryStr = r'''
        query GetDailyCashFlow($start: GraphQLStringOrFloat, $end: GraphQLStringOrFloat, $workspaceId: ID) {
          transactions(
            filter: {
              date: { _between: [$start, $end] }
              workspace: { id: { _eq: $workspaceId } }
            }
          ) {
            date
            amount
            type
          }
        }
      ''';

      final result = await _client.query(
        QueryOptions(
          document: gql(queryStr),
          variables: {
            'start': startIso,
            'end': endIso,
            'workspaceId': workspaceId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final data = result.data!;
      return List<Map<String, dynamic>>.from(data['transactions']);
    } catch (e) {
      Get.log('Error getting daily cash flow: $e');
      rethrow;
    }
  }

  Future<void> createTransaction({
    required double amount,
    required String concept,
    required String date,
    required String type,
    required String categoryId,
    String? workspaceId,
    String? accountId,
    String? receiptImageId,
    String? savingGoalId,
    String? debtId,
    bool isPersonal = true,
    List<Map<String, dynamic>>? items,
  }) async {
    String? effectiveAccountId = accountId;
    if (effectiveAccountId == null && workspaceId != null) {
      final accounts = await getAccounts(workspaceId: workspaceId);
      effectiveAccountId = accounts.firstOrNull?.id;
    }

    final Map<String, dynamic> data = {
      'amount': amount,
      'concept': concept,
      'date': date,
      'type': type,
      'is_personal': isPersonal,
      'category': categoryId,
    };

    if (workspaceId != null) data['workspace'] = workspaceId;
    if (effectiveAccountId != null) data['account'] = effectiveAccountId;
    if (receiptImageId != null) data['receipt_image'] = receiptImageId;
    if (savingGoalId != null) data['saving_goal'] = savingGoalId;
    if (debtId != null) data['debt'] = debtId;
    if (items != null && items.isNotEmpty) data['items'] = items;

    final created = await createItemViaRest('transactions', data);
    if (created == null) {
      throw Exception('No se pudo crear la transaccion via REST');
    }
  }

  Future<void> updateTransaction({
    required String id,
    double? amount,
    String? concept,
    String? date,
    String? type,
    String? categoryId,
    String? workspaceId,
    String? accountId,
    String? receiptImageId,
    bool? isPersonal,
  }) async {
    final Map<String, dynamic> data = {};
    if (amount != null) data['amount'] = amount;
    if (concept != null) data['concept'] = concept;
    if (date != null) data['date'] = date;
    if (type != null) data['type'] = type;
    if (categoryId != null) data['category'] = categoryId;
    if (workspaceId != null) data['workspace'] = workspaceId;
    // Solo actualizar account si se proporcionó explícitamente
    if (accountId != null) data['account'] = accountId;
    if (receiptImageId != null) data['receipt_image'] = receiptImageId;
    if (isPersonal != null) data['is_personal'] = isPersonal;

    Get.log(
      '[DIRECTUS] Updating transaction via REST: '
      'id=$id payload=$data',
    );
    final updated = await updateItemViaRest('transactions', id, data);
    if (updated == null) {
      throw Exception('No se pudo actualizar la transaccion via REST');
    }
  }

  Future<void> deleteTransaction(String id) async {
    final deleted = await deleteItemViaRest('transactions', id);
    if (deleted) {
      return;
    }

    const String deleteMutation = r'''
      mutation DeleteTransaction($id: ID!) {
        delete_transactions_item(id: $id) {
          id
        }
      }
    ''';

    final result = await mutate(deleteMutation, variables: {'id': id});
    if (result.hasException) throw result.exception!;
  }

  Future<List<TransactionItem>> getTransactionItemEvolution(
    String itemName,
  ) async {
    final activeWorkspaceId =
        Get.find<WorkspacesController>().activeWorkspace?.id;
    if (activeWorkspaceId == null) return [];

    const String readEvolution = r'''
      query ReadTransactionItemEvolution($itemName: String!, $workspaceId: ID!) {
        transaction_items(
          filter: { 
            name: { _icontains: $itemName },
            transaction: { workspace: { id: { _eq: $workspaceId } } }
          }
          sort: ["transaction.date"]
        ) {
          id
          name
          quantity
          unit_price
          total_price
          transaction {
            id
            date
          }
        }
      }
    ''';
    final result = await query(
      readEvolution,
      variables: {'itemName': itemName, 'workspaceId': activeWorkspaceId},
    );
    if (result.hasException) throw result.exception!;
    final data = result.data?['transaction_items'] as List<dynamic>? ?? [];
    return data.map((e) => TransactionItem.fromJson(e)).toList();
  }

  Future<void> createTransactionWithItems(
    Transaction transaction,
    List<TransactionItem> items,
  ) async {
    final activeWorkspaceId =
        Get.find<WorkspacesController>().activeWorkspace?.id;
    final Map<String, dynamic> data = {
      'amount': transaction.amount,
      'concept': transaction.concept,
      'date': transaction.date.toIso8601String().split('T')[0],
      'type': transaction.type,
      'is_personal': transaction.isPersonal,
    };

    if (transaction.category?.id != null) {
      data['category'] = transaction.category!.id;
    }

    if (activeWorkspaceId != null) {
      data['workspace'] = activeWorkspaceId;
    }

    if (transaction.receiptImageId != null) {
      data['receipt_image'] = transaction.receiptImageId;
    }

    if (items.isNotEmpty) {
      data['items'] = items
          .map(
            (i) => {
              'name': i.name,
              'quantity': i.quantity,
              'unit_price': i.unitPrice,
              'total_price': i.totalPrice,
              'category_name': i.categoryName,
            },
          )
          .toList();
    }

    final created = await createItemViaRest('transactions', data);
    if (created == null) {
      throw Exception('No se pudo crear la transaccion con items via REST');
    }
  }
}
