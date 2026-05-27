import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/directus_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../workspaces/controllers/workspaces_controller.dart';

class DebtsController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController = Get.find();

  final debts = <Debt>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_workspacesController.activeWorkspaceRx, (workspace) {
      if (workspace != null) {
        Future.microtask(() => loadDebts());
      } else {
        Future.microtask(() => debts.clear());
      }
    });
    ever(_directusService.dataVersion, (_) {
      if (_workspacesController.activeWorkspace != null) {
        Future.microtask(() => loadDebts());
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    loadDebts();
  }

  Future<void> loadDebts({bool showErrors = false}) async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) {
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final data = await _directusService.getDebts(workspaceId: workspaceId);
      debts.assignAll(data);
    } catch (e) {
      Get.log('DebtsController: Error loading debts: $e');
      if (showErrors) {
        SnackbarService.showError("Error", "Error cargando deudas: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDebt(String id, String name) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Eliminar Deuda', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar la deuda "$name"?',
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
      await _directusService.deleteDebt(id);
      SnackbarService.showSuccess('Éxito', 'Deuda eliminada');
      loadDebts();
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo eliminar: $e');
    }
  }

  Future<void> createDebt({
    required String name,
    required double totalAmount,
    double? interestRate,
    DateTime? dueDate,
  }) async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) return;

    try {
      final debt = Debt(
        id: '',
        name: name,
        totalAmount: totalAmount,
        remainingAmount: totalAmount,
        interestRate: interestRate,
        dueDate: dueDate,
        status: 'PENDIENTE',
        workspaceId: workspaceId,
      );
      await _directusService.createDebt(debt);
      _directusService.notifyDataChanged();
      SnackbarService.showSuccess('Éxito', 'Deuda registrada');
      loadDebts();
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo crear la deuda: $e');
    }
  }

  Future<void> editDebt(Debt debt) async {
    final nameCtrl = TextEditingController(text: debt.name);
    final remainingCtrl = TextEditingController(text: debt.remainingAmount.toStringAsFixed(2));

    try {
      await Get.dialog(
        AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text('Editar Deuda', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: remainingCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Monto restante',
                  labelStyle: TextStyle(color: Colors.white54),
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final remaining = double.tryParse(remainingCtrl.text) ?? 0;
                Get.back();
                try {
                  await _directusService.updateDebt(debt.id, {
                    'name': nameCtrl.text.trim(),
                    'remaining_amount': remaining,
                  });
                  _directusService.notifyDataChanged();
                  SnackbarService.showSuccess('Éxito', 'Deuda actualizada');
                  loadDebts();
                } catch (e) {
                  SnackbarService.showError('Error', 'No se pudo actualizar: $e');
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      );
    } finally {
      nameCtrl.dispose();
      remainingCtrl.dispose();
    }
  }

  Future<void> markPaid(String id) async {
    final debt = debts.firstWhereOrNull((d) => d.id == id);
    if (debt == null) return;

    try {
      final workspaceId = _workspacesController.activeWorkspace?.id;
      // Crear transacción de gasto por el monto restante
      if (workspaceId != null && debt.remainingAmount > 0) {
        final categories = await _directusService.getCategories(workspaceId: workspaceId);
        final debtCategory = categories.firstWhereOrNull(
          (c) => c.name.toLowerCase().contains('deuda') || c.name.toLowerCase().contains('préstamo'),
        ) ?? (categories.isNotEmpty ? categories.first : null);

        if (debtCategory != null) {
          await _directusService.createTransaction(
            amount: debt.remainingAmount,
            concept: 'Pago total: ${debt.name}',
            date: DateTime.now().toIso8601String().split('T')[0],
            type: 'expense',
            categoryId: debtCategory.id,
            workspaceId: workspaceId,
          );
        }
      }
      await _directusService.updateDebt(id, {
        'status': 'PAGADO',
        'remaining_amount': 0,
      });
      _directusService.notifyDataChanged();
      SnackbarService.showSuccess("Éxito", "Deuda pagada y gasto registrado");
      loadDebts();
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo procesar el pago: $e");
    }
  }

  /// Pago parcial: crea transacción de gasto y reduce remaining_amount
  Future<void> makePayment(Debt debt) async {
    final amountCtrl = TextEditingController();

    try {
      await Get.dialog(
        AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text('Registrar Pago', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Deuda: ${debt.name}\nRestante: \$${debt.remainingAmount.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Monto del pago',
                  labelStyle: TextStyle(color: Colors.white54),
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (amount <= 0) return;
                if (amount > debt.remainingAmount) {
                  SnackbarService.showWarning('Monto inválido',
                      'El pago no puede exceder el monto restante');
                  return;
                }
                Get.back();
                await _processPayment(debt, amount);
              },
              child: const Text('Pagar'),
            ),
          ],
        ),
      );
    } finally {
      amountCtrl.dispose();
    }
  }

  Future<void> _processPayment(Debt debt, double amount) async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) return;

    try {
      // Buscar categoría de deudas
      final categories = await _directusService.getCategories(workspaceId: workspaceId);
      final debtCategory = categories.firstWhereOrNull(
        (c) => c.name.toLowerCase().contains('deuda') || c.name.toLowerCase().contains('préstamo'),
      ) ?? (categories.isNotEmpty ? categories.first : null);

      if (debtCategory != null) {
        await _directusService.createTransaction(
          amount: amount,
          concept: 'Abono a deuda: ${debt.name}',
          date: DateTime.now().toIso8601String().split('T')[0],
          type: 'expense',
          categoryId: debtCategory.id,
          workspaceId: workspaceId,
        );
      }

      final newRemaining = debt.remainingAmount - amount;
      final updates = <String, dynamic>{
        'remaining_amount': newRemaining,
      };
      if (newRemaining <= 0) {
        updates['status'] = 'PAGADO';
      }
      await _directusService.updateDebt(debt.id, updates);

      _directusService.notifyDataChanged();
      SnackbarService.showSuccess(
        'Pago Registrado',
        newRemaining <= 0
            ? 'Deuda saldada completamente'
            : 'Restante: \$${newRemaining.toStringAsFixed(2)}',
      );
      loadDebts();
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo procesar el pago: $e');
    }
  }
}
