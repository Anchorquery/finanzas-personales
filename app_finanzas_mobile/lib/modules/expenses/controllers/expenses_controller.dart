import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/services/directus_service.dart';

import '../../../core/utils/snackbar_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';

class ExpensesController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController = Get.find<WorkspacesController>();
  
  final transactions = <Transaction>[].obs;
  final categories = <Category>[].obs;
  final debts = <Debt>[].obs;
  final isLoading = true.obs;
  
  // Filters
  final selectedCategoryId = RxnString();
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  
  // Totals
  final totalExpenses = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    
    // Refresh when workspace changes
    ever(_workspacesController.activeWorkspaceRx, (_) => loadData());
    ever(_directusService.dataVersion, (_) => loadData());
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadExpenses(),
        loadCategories(),
        loadDebts(),
      ]);
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo cargar la información de gastos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadExpenses() async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) {
      transactions.clear();
      totalExpenses.value = 0;
      return;
    }

    try {
      final data = await _directusService.getTransactions(
        type: 'expense',
        categoryId: selectedCategoryId.value,
        workspaceId: workspaceId,
      );

      // Filtrado local por fecha
      var filteredData = data;
      if (startDate.value != null) {
        final start = DateTime(startDate.value!.year, startDate.value!.month, startDate.value!.day);
        filteredData = filteredData.where((t) {
          final tDate = DateTime(t.date.year, t.date.month, t.date.day);
          return tDate.isAfter(start) || tDate.isAtSameMomentAs(start);
        }).toList();
      }
      
      if (endDate.value != null) {
        final end = DateTime(endDate.value!.year, endDate.value!.month, endDate.value!.day);
        filteredData = filteredData.where((t) {
          final tDate = DateTime(t.date.year, t.date.month, t.date.day);
          return tDate.isBefore(end) || tDate.isAtSameMomentAs(end);
        }).toList();
      }

      transactions.assignAll(filteredData);
      _calculateTotals();
    } catch (e) {
      Get.log("Error loading expenses: $e");
    }
  }

  Future<void> loadCategories() async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) {
      categories.clear();
      return;
    }

    try {
      final data = await _directusService.getCategories(workspaceId: workspaceId);
      categories.assignAll(data.where((c) => c.type == 'expense' || c.type == 'both').toList());
    } catch (e) {
      Get.log("Error loading categories: $e");
    }
  }

  Future<void> loadDebts() async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    try {
      final data = await _directusService.getDebts(workspaceId: workspaceId);
      debts.assignAll(data.where((d) => d.status == 'PENDIENTE').toList());
    } catch (e) {
      Get.log("Error loading debts: $e");
    }
  }

  void _calculateTotals() {
    totalExpenses.value = transactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  void setCategory(String? id) {
    selectedCategoryId.value = id;
    loadExpenses();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    loadExpenses();
  }

  String formatCurrency(double amount) {
    return NumberFormat.simpleCurrency(decimalDigits: 2).format(amount);
  }
}
