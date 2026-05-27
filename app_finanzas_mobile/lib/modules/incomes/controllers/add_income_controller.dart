import 'dart:io';
import 'package:get/get.dart';

import '../../../data/services/directus_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';
import 'incomes_controller.dart';

class AddIncomeController extends GetxController {
  final DirectusService _directusService = Get.find<DirectusService>();
  final WorkspacesController _workspacesController =
      Get.find<WorkspacesController>();

  final RxString amountString = '0'.obs;
  final RxString note = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxnString selectedCategoryId = RxnString();
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<File> selectedImage = Rxn<File>();
  final RxBool isPersonal = true.obs;
  final RxBool isKeyboardVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    // Re-cargar cuando el workspace cambie
    ever(_workspacesController.activeWorkspaceRx, (_) => fetchCategories());
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final activeWorkspaceId = _workspacesController.activeWorkspace?.id;
      final allCategories = await _directusService.getCategories(
        workspaceId: activeWorkspaceId,
      );
      // Filter only income categories
      categories.assignAll(
        allCategories
            .where((c) => c.type == 'income' || c.type == 'both')
            .toList(),
      );

      if (categories.isNotEmpty) {
        // Solo resetear si la categoría actual ya no está en la lista
        if (selectedCategoryId.value == null ||
            !categories.any((c) => c.id == selectedCategoryId.value)) {
          selectedCategoryId.value = categories.first.id;
        }
      } else {
        selectedCategoryId.value = null;
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      SnackbarService.showError('Error', 'Error al cargar categorías: $e');
    }
  }

  void updateAmount(String value) {
    if (value == '0' && amountString.value == '0') return;
    if (amountString.value == '0') {
      amountString.value = value;
    } else {
      amountString.value += value;
    }
  }

  void deleteLastDigit() {
    if (amountString.value.length <= 1) {
      amountString.value = '0';
    } else {
      amountString.value = amountString.value.substring(
        0,
        amountString.value.length - 1,
      );
    }
  }

  Future<void> submitIncome() async {
    final double amount = double.tryParse(amountString.value) ?? 0.0;
    if (amount <= 0) {
      SnackbarService.showWarning(
        'Atención',
        'Por favor ingresa un monto válido',
      );
      return;
    }

    if (selectedCategoryId.value == null) {
      SnackbarService.showWarning(
        'Atención',
        'Por favor selecciona una categoría',
      );
      return;
    }

    try {
      isLoading.value = true;

      String? receiptImageId;
      if (selectedImage.value != null) {
        receiptImageId = await _directusService.uploadFile(
          selectedImage.value!,
        );
      }

      await _directusService.createTransaction(
        amount: amount,
        concept: note.value.isEmpty ? 'Ingreso' : note.value,
        date: selectedDate.value.toIso8601String().split('T')[0],
        type: 'income',
        categoryId: selectedCategoryId.value!,
        workspaceId: _workspacesController.activeWorkspace?.id,
        receiptImageId: receiptImageId,
        isPersonal: isPersonal.value,
      );

      _directusService.notifyDataChanged();

      // Refresh incomes list if the controller exists
      if (Get.isRegistered<IncomesController>()) {
        Get.find<IncomesController>().fetchIncomes();
      }

      isLoading.value = false;
      Get.back();
      SnackbarService.showSuccess('Éxito', 'Ingreso registrado correctamente');
    } catch (e) {
      isLoading.value = false;
      SnackbarService.showError('Error', 'No se pudo registrar el ingreso: $e');
    }
  }
}
