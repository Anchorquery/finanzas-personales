import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/directus_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';



class SavingsController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController = Get.find();

  final savings = <Saving>[].obs;
  final isLoading = true.obs;
  final goalTransactions = <Transaction>[].obs;

  double get totalSaved =>
      savings.fold(0, (sum, item) => sum + item.currentAmount);

  String get currency => _workspacesController.activeWorkspace?.currency ?? 'USD';

  @override
  void onInit() {
    super.onInit();
    // Escuchar cambios en el workspace activo para recargar los ahorros
    ever(_workspacesController.activeWorkspaceRx, (workspace) {
      if (workspace != null) {
        Future.microtask(() => loadSavings());
      } else {
        Future.microtask(() => savings.clear());
      }
    });
    ever(_directusService.dataVersion, (_) {
      if (_workspacesController.activeWorkspace != null) {
        Future.microtask(loadSavings);
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Carga inicial
    loadSavings();
  }

  Future<void> loadSavings() async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) {
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final data = await _directusService.getSavings(workspaceId);
      savings.assignAll(data);
    } catch (e) {
      SnackbarService.showError(
        "Error",
        "No se pudieron cargar los ahorros: $e",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGoalHistory(String goalId) async {
    try {
      goalTransactions.clear();
      final data = await _directusService.getSavingTransactions(goalId);
      goalTransactions.assignAll(data);
    } catch (e) {
      Get.log("Error loading goal history: $e");
    }
  }

  void createGoal() {
    Get.toNamed('/savings/create');
  }

  Future<void> submitCreateGoal({
    required String name,
    required double amount,
    String? icon,
    DateTime? targetDate,
  }) async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) return;

    try {
      isLoading.value = true;
      await _directusService.createSavingGoal(
        name: name,
        targetAmount: amount,
        workspaceId: workspaceId,
        icon: icon,
        targetDate: targetDate,
      );
      await loadSavings();
      Get.back();
      SnackbarService.showSuccess("Éxito", "Meta creada!");
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo crear: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void addFunds(String id, String name) {
    // Verificar si hay presupuesto disponible antes de permitir el aporte
    final dashboard = Get.find<DashboardController>();
    if (dashboard.totalBalance.value <= 0) {
      SnackbarService.showError(
        "Sin Presupuesto", 
        "No puedes añadir montos al ahorro si no tienes saldo disponible en tu presupuesto. Primero registra un ingreso."
      );
      return;
    }
    
    _showAddFundsBottomSheet(id, name);
  }

  void _showAddFundsBottomSheet(String id, String name) {
    var currentInput = "0".obs;
    
    Get.bottomSheet(
      Obx(() => Container(
            height: Get.height * 0.85,
            decoration: const BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Aportar a $name",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Amount Display with Glow
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (currentInput.value != "0")
                        Container(
                          width: 150,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      Text(
                        "\$${currentInput.value}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Quick add chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [10, 50, 100, 500].map((amount) {
                    return GestureDetector(
                      onTap: () => currentInput.value = amount.toString(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "+ \$$amount",
                          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 40),
                
                // Custom Numeric Keypad
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0'].map((val) {
                        return _buildKey(val, () {
                          if (currentInput.value == "0") {
                            currentInput.value = val;
                          } else {
                            if (val == '.' && currentInput.value.contains('.')) return;
                            if (currentInput.value.length < 9) currentInput.value += val;
                          }
                        });
                      }),
                      _buildKey('backspace', () {
                        if (currentInput.value.length > 1) {
                          currentInput.value = currentInput.value.substring(0, currentInput.value.length - 1);
                        } else {
                          currentInput.value = "0";
                        }
                      }, isIcon: true),
                    ],
                  ),
                ),
                
                // Confirm Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: currentInput.value == "0" ? null : () {
                        Get.back();
                        submitAddFunds(id, double.parse(currentInput.value));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Confirmar Depósito", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildKey(String label, VoidCallback onTap, {bool isIcon = false}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: isIcon 
          ? const Icon(Icons.backspace_outlined, color: Colors.white70, size: 24)
          : Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w500),
            ),
      ),
    );
  }

  Future<void> submitAddFunds(String id, double amount) async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) {
      SnackbarService.showError("Error", "No hay un espacio de trabajo activo");
      return;
    }

    // Validación de presupuesto final
    final dashboard = Get.find<DashboardController>();
    if (amount > dashboard.totalBalance.value) {
      SnackbarService.showError(
        "Saldo Insuficiente", 
        "El monto a ahorrar supera tu presupuesto disponible (\$${dashboard.totalBalance.value.toStringAsFixed(2)})"
      );
      return;
    }

    try {
      isLoading.value = true;
      await _directusService.addSavingFund(id, amount, workspaceId);
      _directusService.notifyDataChanged();
      SnackbarService.showSuccess("Éxito", "Aporte registrado");
      await loadSavings();
      await dashboard.loadDashboard();
      if (id.isNotEmpty) loadGoalHistory(id);
    } catch (e) {
      SnackbarService.showError("Error", "Falló el aporte: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitWithdrawFunds(String id, double amount) async {
    final workspaceId = _workspacesController.activeWorkspace?.id;
    if (workspaceId == null) return;

    // Validar que no exceda el monto disponible
    final goal = savings.firstWhereOrNull((s) => s.id == id);
    if (goal != null && amount > goal.currentAmount) {
      SnackbarService.showWarning(
        'Monto inválido',
        'No puedes retirar más de lo disponible (${goal.currentAmount.toStringAsFixed(2)})',
      );
      return;
    }

    try {
      isLoading.value = true;
      await _directusService.withdrawSavingFund(
        id: id,
        amount: amount,
        workspaceId: workspaceId,
      );
      _directusService.notifyDataChanged();
      SnackbarService.showSuccess("Éxito", "Retiro registrado");
      await loadSavings();
      final dashboard = Get.find<DashboardController>();
      await dashboard.loadDashboard();
      loadGoalHistory(id);
    } catch (e) {
      SnackbarService.showError("Error", "Falló el retiro: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitUpdateGoal({
    required String id,
    String? name,
    double? amount,
    String? icon,
    DateTime? targetDate,
  }) async {
    try {
      isLoading.value = true;
      await _directusService.updateSavingGoal(
        id: id,
        name: name,
        targetAmount: amount,
        icon: icon,
        targetDate: targetDate,
      );
      await loadSavings();
      Get.back();
      SnackbarService.showSuccess("Éxito", "Meta actualizada!");
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo actualizar: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitDeleteGoal(String id) async {
    try {
      isLoading.value = true;
      await _directusService.deleteSavingGoal(id);
      await loadSavings();
      Get.until((route) => Get.currentRoute == '/savings' || Get.currentRoute == '/home');
      SnackbarService.showSuccess("Éxito", "Meta eliminada");
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo eliminar: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String calculateProjection(Saving saving) {
    if (saving.percent >= 100) return "¡Meta alcanzada!";
    if (saving.currentAmount <= 0) return "Añade un aporte para calcular";

    final now = DateTime.now();
    final daysSinceCreation = now.difference(saving.dateCreated).inDays;
    
    // Si se creó hoy, asumimos 1 día para evitar división por cero
    final effectiveDays = daysSinceCreation <= 0 ? 1 : daysSinceCreation;
    final pace = saving.currentAmount / effectiveDays;

    if (pace <= 0) return "Ahorro muy lento para proyectar";

    final remaining = saving.targetAmount - saving.currentAmount;
    final daysRemaining = (remaining / pace).ceil();

    final estimatedDate = now.add(Duration(days: daysRemaining));
    final months = (daysRemaining / 30).floor();
    
    final dateStr = "${estimatedDate.day}/${estimatedDate.month}/${estimatedDate.year}";

    if (months > 0) {
      return "Ahorrando \$${pace.toStringAsFixed(2)}/día. Llegarás en $months meses aprox. ($dateStr)";
    } else {
      return "Ahorrando \$${pace.toStringAsFixed(2)}/día. Llegarás en $daysRemaining días aprox. ($dateStr)";
    }
  }

  Future<void> deleteGoal(String id) async {
    await Get.dialog(
      AlertDialog(
        title: const Text("Eliminar Meta"),
        content: const Text("¿Estás seguro de que quieres eliminar esta meta?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("No")),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _directusService.deleteSavingGoal(id);
                loadSavings();
                SnackbarService.showSuccess("Éxito", "Meta eliminada");
              } catch (e) {
                SnackbarService.showError("Error", "No se pudo eliminar: $e");
              }
            },
            child: const Text("Sí, eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget getGoalIconWidget(Saving goal, {double size = 24}) {
    if (goal.icon != null && goal.icon!.isNotEmpty) {
      if (goal.icon!.length <= 2) {
        // Probablemente un emoji
        return Text(goal.icon!, style: TextStyle(fontSize: size));
      }
    }
    
    final n = goal.name.toLowerCase();
    IconData iconData = Icons.savings;
    if (n.contains('emerg')) iconData = Icons.account_balance_wallet;
    if (n.contains('vaca') || n.contains('trip')) iconData = Icons.flight;
    if (n.contains('car') || n.contains('auto')) iconData = Icons.directions_car;
    if (n.contains('invest')) iconData = Icons.show_chart;
    if (n.contains('home') || n.contains('casa')) iconData = Icons.home;
    
    return Icon(iconData, color: AppTheme.primaryColor, size: size);
  }
}
