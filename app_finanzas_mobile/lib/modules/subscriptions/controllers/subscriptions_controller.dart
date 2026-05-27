import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/directus_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/theme/app_theme.dart';
import 'package:app_finanzas_mobile/modules/workspaces/controllers/workspaces_controller.dart';

class SubscriptionsController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController =
      Get.find<WorkspacesController>();

  final subscriptions = <Subscription>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubscriptions();
    ever(_workspacesController.activeWorkspaceRx, (_) => loadSubscriptions());
    ever(_directusService.dataVersion, (_) => loadSubscriptions());
  }

  Future<void> loadSubscriptions() async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) {
      subscriptions.clear();
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      final data =
          await _directusService.getSubscriptions(workspaceId: workspaceId);
      subscriptions.assignAll(data);
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudieron cargar las suscripciones');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSubscription(String name, double amount, int day) async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) return;

    try {
      await _directusService.addSubscription({
        'name': name,
        'amount': amount,
        'billing_day': day,
        'active': true,
        'billing_period': 'monthly',
        'workspace': workspaceId,
      });
      Get.back();
      loadSubscriptions();
      _directusService.notifyDataChanged();
      SnackbarService.showSuccess('Éxito', 'Suscripción agregada');
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo agregar la suscripción: $e');
    }
  }

  Future<void> editSubscription(Subscription sub) async {
    final nameController = TextEditingController(text: sub.name);
    final amountController =
        TextEditingController(text: sub.amount.toStringAsFixed(2));

    try {
      await Get.dialog(
        AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title:
              const Text('Editar Suscripción', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Monto mensual',
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
                final name = nameController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0;
                if (name.isEmpty || amount <= 0) return;

                Get.back();
                try {
                  await _directusService.updateSubscription(sub.id, {
                    'name': name,
                    'amount': amount,
                  });
                  loadSubscriptions();
                  _directusService.notifyDataChanged();
                  SnackbarService.showSuccess('Éxito', 'Suscripción actualizada');
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
      nameController.dispose();
      amountController.dispose();
    }
  }

  Future<void> deleteSubscription(Subscription sub) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Eliminar Suscripción',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar "${sub.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _directusService.deleteSubscription(sub.id);
      loadSubscriptions();
      _directusService.notifyDataChanged();
      SnackbarService.showSuccess('Éxito', 'Suscripción eliminada');
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo eliminar: $e');
    }
  }

  Future<void> registerPayment(Subscription sub) async {
    try {
      await _directusService.payRecurring(sub.name, sub.amount);
      _directusService.notifyDataChanged();
      SnackbarService.showSuccess(
        'Pago Registrado',
        'Gasto de ${sub.name} por \$${sub.amount.toStringAsFixed(2)} creado',
      );
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo registrar el pago: $e');
    }
  }
}
