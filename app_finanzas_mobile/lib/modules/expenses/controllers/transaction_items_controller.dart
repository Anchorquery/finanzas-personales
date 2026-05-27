import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/services/directus_service.dart';

import '../../../core/utils/snackbar_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';

class TransactionItemsController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController = Get.find<WorkspacesController>();
  
  final transactionsWithItems = <Transaction>[].obs;
  final isLoading = true.obs;
  
  // For evolution tracking
  final selectedItemEvolution = <TransactionItem>[].obs;
  final isLoadingEvolution = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactionsWithItems();
  }

  Future<void> loadTransactionsWithItems() async {
    try {
      isLoading.value = true;
      // We explicitly want transactions that have line items
      final data = await _directusService.getTransactions(
        workspaceId: _workspacesController.activeWorkspace?.id,
      );
      // Filter those with items locally or we could have a specific method
      transactionsWithItems.assignAll(data.where((t) => t.items.isNotEmpty).toList());
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo cargar los artículos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadItemEvolution(String itemName) async {
    try {
      isLoadingEvolution.value = true;
      final data = await _directusService.getTransactionItemEvolution(itemName);
      selectedItemEvolution.assignAll(data);
    } catch (e) {
      Get.log("Error loading item evolution: $e");
    } finally {
      isLoadingEvolution.value = false;
    }
  }

  String formatCurrency(double amount) {
    return NumberFormat.simpleCurrency(decimalDigits: 2).format(amount);
  }
}
