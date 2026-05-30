import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/directus_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/theme/app_theme.dart';


import '../../workspaces/controllers/workspaces_controller.dart';

class BudgetsController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController = Get.find();

  final budgets = <Budget>[].obs;
  final categories = <Category>[].obs;
  final isLoading = true.obs;

  String get currency => _workspacesController.activeWorkspace?.currency ?? 'USD';

  @override
  void onInit() {
    super.onInit();
    ever(_workspacesController.activeWorkspaceRx, (workspace) {
      if (workspace != null) {
        Future.microtask(() {
          loadBudgets();
          loadCategories();
        });
      } else {
        Future.microtask(() {
          budgets.clear();
          categories.clear();
        });
      }
    });
    ever(_directusService.dataVersion, (_) {
      if (_workspacesController.activeWorkspace != null) {
        Future.microtask(loadBudgets);
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    loadBudgets();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) return;

    try {
      final data = await _directusService.getCategories(workspaceId: workspaceId);
      categories.assignAll(data);
    } catch (e) {
      Get.log("Error loading categories: $e");
    }
  }

  Future<void> loadBudgets({bool showErrors = false}) async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) {
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final data = await _directusService.getBudgetsStatus(workspaceId);
      budgets.assignAll(data);
    } catch (e) {
      Get.log('BudgetsController: Error loading budgets: $e');
      if (showErrors) {
        SnackbarService.showError(
          "Error",
          "No se pudieron cargar los presupuestos: $e",
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBudget(String id, String name) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFF1F0FB)),
        ),
        title: const Text(
          'Eliminar Presupuesto',
          style: TextStyle(
            color: Color(0xFF1A1C1C),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '¿Estás seguro de eliminar el presupuesto "$name"?',
          style: const TextStyle(color: Color(0xFF4A4455)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF7B7487)),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: AppTheme.accentRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _directusService.deleteBudget(id);
      SnackbarService.showSuccess('Éxito', 'Presupuesto eliminado');
      loadBudgets();
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo eliminar: $e');
    }
  }

  Future<void> editBudget(String id, double currentLimit, String name) async {
    final ctrl = TextEditingController(text: currentLimit.toStringAsFixed(2));
    try {
      await Get.dialog(
        _lightDialog(
          icon: Icons.edit_note_rounded,
          title: 'Editar Presupuesto',
          subtitle: name,
          children: [
            _lightAmountInput(ctrl, label: 'Límite Mensual'),
          ],
          submitLabel: 'Guardar',
          onSubmit: () async {
            final val = double.tryParse(ctrl.text);
            if (val == null) return;
            Get.back();
            try {
              await _directusService.updateBudget(id, val);
              _directusService.notifyDataChanged();
              SnackbarService.showSuccess('Éxito', 'Presupuesto actualizado');
              loadBudgets();
            } catch (e) {
              SnackbarService.showError('Error', 'Falló la actualización: $e');
            }
          },
        ),
      );
    } finally {
      ctrl.dispose();
    }
  }

  Future<void> showAddBudgetDialog() async {
    final limitCtrl = TextEditingController();
    String? selectedCategoryId;
    try {
      await Get.dialog(
        _lightDialog(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Nuevo Presupuesto',
          subtitle: 'Asigna un límite a una categoría',
          children: [
            Obx(
              () => DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Color(0xFF1A1C1C),
                  fontSize: 14,
                ),
                decoration: _lightInputDecoration('Categoría'),
                items: categories
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (val) => selectedCategoryId = val,
              ),
            ),
            const SizedBox(height: 16),
            _lightAmountInput(limitCtrl, label: 'Límite Mensual'),
          ],
          submitLabel: 'Crear',
          onSubmit: () async {
            final val = double.tryParse(limitCtrl.text);
            if (val == null || selectedCategoryId == null) return;
            Get.back();
            try {
              await _directusService.createBudget(
                limit: val,
                categoryId: selectedCategoryId!,
                workspaceId: _workspacesController.activeWorkspace?.id,
              );
              _directusService.notifyDataChanged();
              SnackbarService.showSuccess('Éxito', 'Presupuesto creado');
              loadBudgets();
            } catch (e) {
              SnackbarService.showError('Error', 'Falló la creación: $e');
            }
          },
        ),
      );
    } finally {
      limitCtrl.dispose();
    }
  }
}

// ════════════════════════════════════════════════════════════════════════
// Light dialog helpers (LIGHT ONLY per DESIGN.md)
// ════════════════════════════════════════════════════════════════════════

Widget _lightDialog({
  required IconData icon,
  required String title,
  String? subtitle,
  required List<Widget> children,
  required String submitLabel,
  required VoidCallback onSubmit,
}) {
  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F0FB)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEDE9FE),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1A1C1C),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF7B7487),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...children,
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4A4455),
                      side: const BorderSide(color: Color(0xFFE2E0F7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      submitLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _lightAmountInput(TextEditingController c, {required String label}) {
  return TextField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: const TextStyle(color: Color(0xFF1A1C1C), fontSize: 16),
    decoration: _lightInputDecoration(label).copyWith(
      prefixText: '\$ ',
      prefixStyle: const TextStyle(
        color: AppTheme.primary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

InputDecoration _lightInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFF7B7487), fontSize: 13),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E0F7)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E0F7)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
    ),
  );
}
