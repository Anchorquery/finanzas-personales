import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/services/directus_service.dart';

class AccountHistoryGroup {
  final String label;
  final List<Transaction> items;

  const AccountHistoryGroup({required this.label, required this.items});
}

class AccountDetailController extends GetxController {
  AccountDetailController({required this.account});

  final DirectusService _directusService = Get.find<DirectusService>();
  final Account account;

  final transactions = <Transaction>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      final data = await _directusService.getTransactions(
        limit: 200,
        workspaceId: account.workspaceId,
        accountId: account.id,
      );

      final merged = <Transaction>[
        if (account.initialBalance > 0)
          Transaction(
            id: 'opening-${account.id}',
            amount: account.initialBalance,
            concept: 'Saldo inicial: ${account.name}',
            date: account.createdAt ?? DateTime.now(),
            type: 'opening_balance',
            isPersonal: true,
            accountId: account.id,
            currency: account.currency,
          ),
        ...data,
      ]..sort((a, b) => b.date.compareTo(a.date));

      transactions.assignAll(merged);
    } catch (e) {
      Get.log('Error loading account transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  double get totalIncome => transactions
      .where((tx) => tx.type == 'income')
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get totalExpense => transactions
      .where((tx) => tx.type == 'expense')
      .fold(0.0, (sum, tx) => sum + tx.amount);

  List<AccountHistoryGroup> get historyGroups {
    final formatter = DateFormat('MMMM yyyy', 'es_ES');
    final groups = <String, List<Transaction>>{};

    for (final tx in transactions) {
      final label = _capitalize(formatter.format(tx.date));
      groups.putIfAbsent(label, () => <Transaction>[]).add(tx);
    }

    return groups.entries
        .map(
          (entry) => AccountHistoryGroup(label: entry.key, items: entry.value),
        )
        .toList();
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
