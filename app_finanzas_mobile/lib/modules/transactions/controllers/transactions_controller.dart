import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/directus_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class TransactionsController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController = Get.find();

  final transactions = <Transaction>[].obs;
  final categories = <Category>[].obs;
  final isLoading = true.obs;
  final isLoadingCategories = true.obs;
  final isSubmitting = false.obs;

  // Form Controllers
  // Form State
  final editingId = RxnString();
  final amountString = '0'.obs;
  final conceptController = TextEditingController();
  final note = ''.obs;
  final selectedType = 'expense'.obs;
  final selectedDate = DateTime.now().obs;
  final selectedCategoryId = RxnString();
  final selectedImage = Rxn<XFile>();
  final ImagePicker _picker = ImagePicker();

  Category? get selectedCategory {
    if (selectedCategoryId.value == null) return null;
    return categories.firstWhereOrNull((c) => c.id == selectedCategoryId.value);
  }

  // Filter States
  final filterDate = DateTime.now().obs;
  final filterCategoryId = RxnString();
  final selectedPeriod = 'month'.obs; // 'day', 'week', 'month', 'year'
  final filterType = RxnString(); // null = todos, 'income', 'expense'
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  List<Transaction> get filteredTransactions {
    var result = transactions.toList();
    if (filterType.value != null) {
      result = result.where((t) => t.type == filterType.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((t) =>
          t.concept.toLowerCase().contains(q) ||
          (t.category?.name.toLowerCase().contains(q) ?? false)).toList();
    }
    return result;
  }

  double get totalAmount {
    return transactions.fold(0.0, (sum, t) {
      if (t.type == 'income' || t.type == 'opening_balance') return sum + t.amount;
      return sum - t.amount;
    });
  }

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
    loadCategories();

    // Listen to workspace changes
    ever(_workspacesController.activeWorkspaceRx, (_) {
      loadTransactions();
      loadCategories();
    });
    // Listen to cross-module data mutations (e.g. AI agent writes).
    ever(_directusService.dataVersion, (_) => loadTransactions());
  }

  @override
  void onReady() {
    super.onReady();
    if (categories.isEmpty) {
      loadCategories();
    }

    if (Get.arguments != null && Get.arguments is Map) {
      setTransactionFromScan(Get.arguments as Map<String, dynamic>);
    }
  }

  void setTransactionFromScan(Map<String, dynamic> args) {
    if (args['fromScan'] == true) {
      if (args['amount'] != null) {
        // Handle integer or double
        amountString.value = args['amount'].toString();
      }
      if (args['merchant'] != null) {
        note.value = args['merchant'];
        // Append items if available
        if (args['items'] != null && (args['items'] as List).isNotEmpty) {
          note.value += '\nItems: ${(args['items'] as List).join(', ')}';
        }
      }
      if (args['date'] != null) {
        try {
          selectedDate.value = DateTime.parse(args['date']);
        } catch (_) {}
      }
      if (args['imagePath'] != null) {
        selectedImage.value = XFile(args['imagePath']);
      }
      // Auto-select category based on AI suggestion
      if (args['suggestedCategory'] != null && categories.isNotEmpty) {
        final suggestion = args['suggestedCategory'].toString().toLowerCase();
        final match = categories.firstWhereOrNull(
          (c) => c.name.toLowerCase().contains(suggestion) ||
                 suggestion.contains(c.name.toLowerCase()),
        );
        if (match != null) {
          selectedCategoryId.value = match.id;
        }
      }
      SnackbarService.showSuccess(
        'Datos escaneados',
        'Verifica la información extraída.',
      );
    }
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      final workspaceId = _workspacesController.activeWorkspace?.id;
      
      DateTime startDate;
      DateTime endDate;

      switch (selectedPeriod.value) {
        case 'day':
          startDate = DateTime(filterDate.value.year, filterDate.value.month, filterDate.value.day);
          endDate = startDate.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
          break;
        case 'week':
          // Find the first day of the week (Monday)
          startDate = filterDate.value.subtract(Duration(days: filterDate.value.weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          endDate = startDate.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
          break;
        case 'year':
          startDate = DateTime(filterDate.value.year, 1, 1);
          endDate = DateTime(filterDate.value.year, 12, 31, 23, 59, 59);
          break;
        case 'month':
        default:
          startDate = DateTime(filterDate.value.year, filterDate.value.month, 1);
          endDate = DateTime(filterDate.value.year, filterDate.value.month + 1, 0, 23, 59, 59);
          break;
      }

      final results = await Future.wait([
        _directusService.getTransactions(
          limit: 100,
          startDate: startDate,
          endDate: endDate,
          categoryId: filterCategoryId.value,
          workspaceId: workspaceId,
        ),
        if (workspaceId != null && filterCategoryId.value == null)
          _directusService.getAccounts(workspaceId: workspaceId)
        else
          Future.value(<Account>[]),
      ]);

      final data = results[0] as List<Transaction>;
      final accounts = results[1] as List<Account>;
      final openingTransactions = accounts
          .where((account) {
            if (account.initialBalance <= 0) return false;
            final createdAt = account.createdAt;
            if (createdAt == null) return false;
            return createdAt.year == filterDate.value.year &&
                createdAt.month == filterDate.value.month;
          })
          .map(
            (account) => Transaction(
              id: 'opening-${account.id}',
              amount: account.initialBalance,
              concept: 'Saldo inicial: ${account.name}',
              date: account.createdAt!,
              type: 'opening_balance',
              isPersonal: true,
              accountId: account.id,
              currency: account.currency,
            ),
          )
          .toList();

      final merged = [...data, ...openingTransactions]
        ..sort((a, b) => b.date.compareTo(a.date));
      transactions.assignAll(merged);
    } catch (e) {
      Get.log('Error loading transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeDateFilter(DateTime date) {
    filterDate.value = date;
    loadTransactions();
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadTransactions();
  }

  void nextPeriod() {
    switch (selectedPeriod.value) {
      case 'day':
        filterDate.value = filterDate.value.add(const Duration(days: 1));
        break;
      case 'week':
        filterDate.value = filterDate.value.add(const Duration(days: 7));
        break;
      case 'month':
        filterDate.value = DateTime(filterDate.value.year, filterDate.value.month + 1, 1);
        break;
      case 'year':
        filterDate.value = DateTime(filterDate.value.year + 1, 1, 1);
        break;
    }
    loadTransactions();
  }

  void previousPeriod() {
    switch (selectedPeriod.value) {
      case 'day':
        filterDate.value = filterDate.value.subtract(const Duration(days: 1));
        break;
      case 'week':
        filterDate.value = filterDate.value.subtract(const Duration(days: 7));
        break;
      case 'month':
        filterDate.value = DateTime(filterDate.value.year, filterDate.value.month - 1, 1);
        break;
      case 'year':
        filterDate.value = DateTime(filterDate.value.year - 1, 1, 1);
        break;
    }
    loadTransactions();
  }

  void changeCategoryFilter(String? id) {
    filterCategoryId.value = id;
    loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _directusService.deleteTransaction(id);
      SnackbarService.showSuccess("Éxito", "Transacción eliminada");
      _directusService.notifyDataChanged();
      refreshTransactions();
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo eliminar: $e");
    }
  }

  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      final data = await _directusService.getCategories(
        workspaceId: _workspacesController.activeWorkspace?.id,
      );
      categories.assignAll(data);
      if (categories.isNotEmpty && selectedCategoryId.value == null) {
        selectedCategoryId.value = categories[0].id;
      }
    } catch (e) {
      SnackbarService.showError("Error", "Error cargando categorías: $e");
      debugPrint('Error loading categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void appendDigit(String digit) {
    if (digit == '.') {
      if (!amountString.value.contains('.')) {
        amountString.value += '.';
      }
      return;
    }

    if (amountString.value == '0') {
      amountString.value = digit;
    } else {
      // Limit decimals to 2
      if (amountString.value.contains('.')) {
        final parts = amountString.value.split('.');
        if (parts.length > 1 && parts[1].length >= 2) {
          return;
        }
      }
      amountString.value += digit;
    }
  }

  void deleteDigit() {
    if (amountString.value.length > 1) {
      amountString.value = amountString.value.substring(
        0,
        amountString.value.length - 1,
      );
    } else {
      amountString.value = '0';
    }
  }

  void clearAmount() {
    amountString.value = '0';
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = image;
      }
    } catch (e) {
      SnackbarService.showError(
        "Error",
        "No se pudo seleccionar la imagen: $e",
      );
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  Future<void> submitTransaction() async {
    final double amount = double.tryParse(amountString.value) ?? 0.0;
    if (amount <= 0) {
      SnackbarService.showWarning(
        "Monto inválido",
        "El monto debe ser mayor a 0",
      );
      return;
    }
    if (selectedCategoryId.value == null) {
      SnackbarService.showWarning(
        "Categoría requerida",
        "Selecciona una categoría para continuar",
      );
      return;
    }

    try {
      isSubmitting.value = true;

      String? receiptImageId;
      if (selectedImage.value != null) {
        receiptImageId = await _directusService.uploadFile(
          File(selectedImage.value!.path),
        );
      }

      final payload = {
        'amount': amount,
        'concept': note.value.isEmpty
            ? (selectedCategory?.name ?? 'Transacción')
            : note.value,
        'date': selectedDate.value.toIso8601String().split('T')[0],
        'type': selectedType.value,
        'category': selectedCategoryId.value!,
        'receipt_image': receiptImageId,
      };

      if (editingId.value != null) {
        await _directusService.updateTransaction(
          id: editingId.value!,
          amount: amount,
          concept: payload['concept'] as String,
          date: payload['date'] as String,
          type: payload['type'] as String,
          categoryId: payload['category'] as String,
          workspaceId: _workspacesController.activeWorkspace?.id,
          receiptImageId: payload['receipt_image'] as String?,
        );
        SnackbarService.showSuccess("Éxito", "Transacción actualizada");
      } else {
        await _directusService.createTransaction(
          amount: amount,
          concept: payload['concept'] as String,
          date: payload['date'] as String,
          type: payload['type'] as String,
          categoryId: payload['category'] as String,
          workspaceId: _workspacesController.activeWorkspace?.id,
          receiptImageId: payload['receipt_image'] as String?,
        );
        SnackbarService.showSuccess("Éxito", "Transacción guardada");
      }

      _directusService.notifyDataChanged();
      Get.back(); // Close modal
      refreshTransactions();
      clearForm();
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo guardar: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  void setTransactionForEdit(Transaction transaction) {
    editingId.value = transaction.id;
    amountString.value = transaction.amount.toString();
    conceptController.text = transaction.concept;
    note.value = transaction.concept;
    selectedType.value = transaction.type;
    selectedDate.value = transaction.date;
    selectedCategoryId.value = transaction.category?.id;
    selectedImage.value = null; // Reset image on edit for now
  }

  void clearForm() {
    editingId.value = null;
    amountString.value = '0';
    conceptController.clear();
    note.value = '';
    selectedType.value = 'expense';
    selectedDate.value = DateTime.now();
    selectedCategoryId.value = null;
    if (categories.isNotEmpty) {
      selectedCategoryId.value = categories[0].id;
    }
    selectedImage.value = null;
  }

  Future<void> refreshTransactions() => loadTransactions();

  Future<void> exportToCsv() async {
    try {
      final rows = <List<String>>[
        ['Fecha', 'Concepto', 'Monto', 'Tipo', 'Categoría', 'Usuario'],
        ...filteredTransactions.map((t) => [
          t.date.toIso8601String().split('T')[0],
          t.concept,
          t.amount.toStringAsFixed(2),
          t.type == 'income' ? 'Ingreso' : 'Gasto',
          t.category?.name ?? 'Sin categoría',
          t.userCreated?.firstName ?? '',
        ]),
      ];
      final csv = rows.map((row) => row.join(',')).join('\n');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/transacciones.csv');
      await file.writeAsString(csv);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Mis transacciones'),
      );
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo exportar: $e');
    }
  }

  @override
  void onClose() {
    conceptController.dispose();
    super.onClose();
  }
}
