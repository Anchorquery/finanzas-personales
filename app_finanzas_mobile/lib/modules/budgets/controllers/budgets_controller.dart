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
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Eliminar Presupuesto', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de eliminar el presupuesto "$name"?',
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
      await _directusService.deleteBudget(id);
      SnackbarService.showSuccess('Éxito', 'Presupuesto eliminado');
      loadBudgets();
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo eliminar: $e');
    }
  }

  Future<void> editBudget(String id, double currentLimit, String name) async {
    final controller = TextEditingController(
      text: currentLimit.toStringAsFixed(2),
    );

    try {
    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Editar Presupuesto",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  labelText: "Límite Mensual",
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  prefixText: "\$ ",
                  prefixStyle: const TextStyle(color: Colors.white, fontSize: 18),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final val = double.tryParse(controller.text);
                        if (val != null) {
                          Get.back();
                          try {
                            await _directusService.updateBudget(id, val);
                            _directusService.notifyDataChanged();
                            SnackbarService.showSuccess(
                              "Éxito",
                              "Presupuesto actualizado",
                            );
                            loadBudgets();
                          } catch (e) {
                            SnackbarService.showError(
                              "Error",
                              "Falló la actualización: $e",
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Guardar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    } finally {
      controller.dispose();
    }
  }

  Future<void> showAddBudgetDialog() async {
    final limitController = TextEditingController();
    String? selectedCategoryId;

    try {
    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nuevo Presupuesto",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Asigna un límite a una categoría",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(
                () => DropdownButtonFormField<String>(
                  dropdownColor: AppTheme.surfaceDark,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Categoría",
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (val) => selectedCategoryId = val,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  labelText: "Límite Mensual",
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  prefixText: "\$ ",
                  prefixStyle: const TextStyle(color: Colors.white, fontSize: 18),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final val = double.tryParse(limitController.text);
                        if (val != null && selectedCategoryId != null) {
                          Get.back();
                          try {
                            await _directusService.createBudget(
                              limit: val,
                              categoryId: selectedCategoryId!,
                              workspaceId: _workspacesController.activeWorkspace?.id,
                            );
                            _directusService.notifyDataChanged();
                            SnackbarService.showSuccess("Éxito", "Presupuesto creado");
                            loadBudgets();
                          } catch (e) {
                            SnackbarService.showError("Error", "Falló la creación: $e");
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Crear",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    } finally {
      limitController.dispose();
    }
  }
}
