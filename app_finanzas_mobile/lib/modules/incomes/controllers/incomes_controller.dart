import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/snackbar_service.dart';
import '../../../data/services/directus_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';

enum IncomeRangeFilter { month, threeMonths, year }

class IncomeHistoryGroup {
  final String label;
  final List<Transaction> items;

  const IncomeHistoryGroup({required this.label, required this.items});
}

class IncomesController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController =
      Get.find<WorkspacesController>();

  final incomePlans = <IncomePlan>[].obs;
  final incomeCategories = <Category>[].obs;
  final recentIncomes = <Transaction>[].obs;
  final isLoading = true.obs;

  final totalMonthlyIncome = 0.0.obs;
  final expectedMonthlyIncome = 0.0.obs;
  final lastMonthIncome = 0.0.obs;
  final percentageChange = 0.0.obs;
  final sourceBreakdown = <String, double>{}.obs;
  final registeringPlanIds = <String>{}.obs;
  final selectedRange = IncomeRangeFilter.month.obs;
  final selectedSource = 'Todas'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchIncomes();
    ever(_workspacesController.activeWorkspaceRx, (_) => fetchIncomes());
    ever(_directusService.dataVersion, (_) => fetchIncomes());
  }

  Future<void> fetchIncomes() async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) {
      incomePlans.clear();
      recentIncomes.clear();
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final results = await Future.wait([
        _directusService.getIncomePlans(workspaceId: workspaceId),
        _directusService.getCategories(workspaceId: workspaceId),
        _directusService.getIncomeTransactions(
          workspaceId: workspaceId,
          limit: 100,
        ),
      ]);

      incomePlans.assignAll(results[0] as List<IncomePlan>);
      incomeCategories.assignAll(
        (results[1] as List<Category>)
            .where(
              (category) =>
                  category.type == 'income' || category.type == 'both',
            )
            .toList(),
      );
      recentIncomes.assignAll(results[2] as List<Transaction>);
      _calculateUIData();
      _normalizeSelectedSource();
    } catch (e) {
      SnackbarService.showError('Error', 'Error al cargar ingresos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateUIData() {
    expectedMonthlyIncome.value = pendingIncomePlans.fold(
      0.0,
      (sum, plan) => sum + plan.amount,
    );

    final now = DateTime.now();
    final thisMonthIncomes = recentIncomes
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
    final currentTotal = thisMonthIncomes.fold(0.0, (sum, t) => sum + t.amount);
    totalMonthlyIncome.value = currentTotal;

    final prevMonth = DateTime(now.year, now.month - 1);
    final lastMonthIncomes = recentIncomes
        .where(
          (t) =>
              t.date.year == prevMonth.year && t.date.month == prevMonth.month,
        )
        .toList();
    final prevTotal = lastMonthIncomes.fold(0.0, (sum, t) => sum + t.amount);
    lastMonthIncome.value = prevTotal;

    if (prevTotal > 0) {
      percentageChange.value = ((currentTotal - prevTotal) / prevTotal) * 100;
    } else {
      percentageChange.value = currentTotal > 0 ? 100.0 : 0.0;
    }

    final breakdown = <String, double>{};
    for (final t in thisMonthIncomes) {
      final source = t.category?.name ?? 'Otros';
      breakdown[source] = (breakdown[source] ?? 0) + t.amount;
    }
    sourceBreakdown.assignAll(breakdown);
  }

  void _normalizeSelectedSource() {
    final sources = availableSources;
    if (!sources.contains(selectedSource.value)) {
      selectedSource.value = 'Todas';
    }
  }

  void setRange(IncomeRangeFilter range) {
    if (selectedRange.value == range) return;
    selectedRange.value = range;
  }

  void setSource(String source) {
    if (selectedSource.value == source) return;
    selectedSource.value = source;
  }

  List<IncomePlan> get pendingIncomePlans =>
      incomePlans.where((plan) => !isPlanReceivedThisMonth(plan)).toList();

  bool isPlanReceivedThisMonth(IncomePlan plan) {
    final now = DateTime.now();
    final expectedConcept = 'Ingreso: ${plan.name}'.toLowerCase();

    return recentIncomes.any(
      (t) =>
          t.date.year == now.year &&
          t.date.month == now.month &&
          t.type == 'income' &&
          (t.concept.toLowerCase() == expectedConcept ||
           t.concept.toLowerCase().contains(plan.name.toLowerCase())),
    );
  }

  DateTime get _rangeStart {
    final now = DateTime.now();
    switch (selectedRange.value) {
      case IncomeRangeFilter.month:
        return DateTime(now.year, now.month, 1);
      case IncomeRangeFilter.threeMonths:
        return DateTime(now.year, now.month - 2, 1);
      case IncomeRangeFilter.year:
        return DateTime(now.year, 1, 1);
    }
  }

  List<Transaction> get filteredIncomes {
    final start = _rangeStart;
    final source = selectedSource.value;

    final filtered = recentIncomes.where((t) {
      final matchesDate = !t.date.isBefore(start);
      final matchesSource =
          source == 'Todas' || (t.category?.name ?? 'Otros') == source;
      return matchesDate && matchesSource;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  List<String> get availableSources {
    final sources =
        recentIncomes.map((t) => t.category?.name ?? 'Otros').toSet().toList()
          ..sort();
    return ['Todas', ...sources];
  }

  List<IncomeHistoryGroup> get historyGroups {
    final groups = <String, List<Transaction>>{};
    final formatter = DateFormat('MMMM yyyy', 'es_ES');

    for (final tx in filteredIncomes) {
      final label = _capitalize(formatter.format(tx.date));
      groups.putIfAbsent(label, () => <Transaction>[]).add(tx);
    }

    return groups.entries
        .map(
          (entry) => IncomeHistoryGroup(label: entry.key, items: entry.value),
        )
        .toList();
  }

  double get filteredIncomeTotal =>
      filteredIncomes.fold(0.0, (sum, tx) => sum + tx.amount);

  int get filteredIncomeCount => filteredIncomes.length;

  double get filteredAverageIncome {
    if (filteredIncomeCount == 0) return 0;
    return filteredIncomeTotal / filteredIncomeCount;
  }

  String get topSourceLabel {
    if (filteredIncomes.isEmpty) return 'Sin datos';

    final grouped = <String, double>{};
    for (final tx in filteredIncomes) {
      final key = tx.category?.name ?? 'Otros';
      grouped[key] = (grouped[key] ?? 0) + tx.amount;
    }

    final sorted = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  double get topSourceAmount {
    if (filteredIncomes.isEmpty) return 0;

    final grouped = <String, double>{};
    for (final tx in filteredIncomes) {
      final key = tx.category?.name ?? 'Otros';
      grouped[key] = (grouped[key] ?? 0) + tx.amount;
    }

    return grouped.values.fold(0.0, (max, value) => value > max ? value : max);
  }

  String get selectedRangeLabel {
    switch (selectedRange.value) {
      case IncomeRangeFilter.month:
        return 'Mes';
      case IncomeRangeFilter.threeMonths:
        return '3M';
      case IncomeRangeFilter.year:
        return 'Año';
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  Future<void> markAsReceived(IncomePlan plan) async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) return;
    if (registeringPlanIds.contains(plan.id) || isPlanReceivedThisMonth(plan)) {
      return;
    }

    try {
      registeringPlanIds.add(plan.id);
      isLoading.value = true;

      final incomeCat =
          incomeCategories.firstWhereOrNull(
            (c) =>
                c.name.toLowerCase().contains('ingreso') ||
                c.name.toLowerCase().contains(plan.name.toLowerCase()),
          ) ??
          incomeCategories.firstWhereOrNull((c) => c.type == 'income');

      final transaction = Transaction(
        id: '',
        amount: plan.amount,
        concept: 'Ingreso: ${plan.name}',
        date: DateTime.now(),
        type: 'income',
        category: incomeCat,
        isPersonal: true,
      );

      await _directusService.createIncomeTransaction(transaction);
      _directusService.notifyDataChanged();
      await fetchIncomes();
      SnackbarService.showSuccess(
        'Ingreso Registrado',
        'Se han anadido ${plan.amount} a tu cuenta.',
      );
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo registrar el ingreso: $e');
    } finally {
      registeringPlanIds.remove(plan.id);
      isLoading.value = false;
    }
  }

  Future<void> deleteIncomePlan(String id, String name) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Eliminar Plan', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar el plan de ingreso "$name"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _directusService.deleteIncomePlan(id);
      _directusService.notifyDataChanged();
      SnackbarService.showSuccess('Éxito', 'Plan de ingreso eliminado');
      await fetchIncomes();
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo eliminar el plan: $e');
    }
  }

  Future<void> updateIncome({
    required Transaction transaction,
    required double amount,
    required String concept,
    required DateTime date,
    required String categoryId,
    String? receiptImageId,
  }) async {
    try {
      isLoading.value = true;
      await _directusService.updateTransaction(
        id: transaction.id,
        amount: amount,
        concept: concept,
        date: date.toIso8601String().split('T')[0],
        type: 'income',
        categoryId: categoryId,
        workspaceId: _workspacesController.activeWorkspace?.id,
        accountId: transaction.accountId,
        receiptImageId: receiptImageId,
        isPersonal: transaction.isPersonal,
      );
      await fetchIncomes();
      SnackbarService.showSuccess(
        'Ingreso actualizado',
        'Se guardaron los cambios.',
      );
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo editar el ingreso: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteIncome(Transaction transaction) async {
    try {
      isLoading.value = true;
      await _directusService.deleteTransaction(transaction.id);
      await fetchIncomes();
      SnackbarService.showSuccess(
        'Ingreso anulado',
        'El ingreso fue eliminado.',
      );
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo anular el ingreso: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
