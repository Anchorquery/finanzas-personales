import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/debts_controller.dart';
import 'add_debt_view.dart';
import '../../home/controllers/home_controller.dart';

class DebtsView extends GetView<DebtsController> {
  const DebtsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DebtsController>()) {
      Get.put(DebtsController());
    }

    final isWide = MediaQuery.of(context).size.width >= 800;
    final t = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  if (!isWide)
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                      onPressed: () => Get.find<HomeController>().scaffoldKey.currentState?.openDrawer(),
                    ),
                  Expanded(
                    child: Text(
                      t.debtsTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!isWide) const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                }

                if (controller.debts.isEmpty) {
                  return PullableEmptyState(
                    onRefresh: () => controller.loadDebts(showErrors: true),
                    color: AppTheme.primaryColor,
                    backgroundColor: AppTheme.surfaceDark,
                    icon: Icons.money_off,
                    message: t.debtsEmpty,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadDebts(showErrors: true),
                  color: AppTheme.primaryColor,
                  backgroundColor: AppTheme.surfaceDark,
                  child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.debts.length,
                  itemBuilder: (context, index) {
                    final item = controller.debts[index];
                    final progress = item.totalAmount > 0 
                        ? (item.totalAmount - item.remainingAmount) / item.totalAmount 
                        : 1.0;
                    final bool isPending = item.status == 'PENDIENTE';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                color: isPending ? AppTheme.primaryColor : Colors.white38,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: (isPending ? AppTheme.primaryColor : Colors.white10).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item.status,
                                              style: TextStyle(
                                                color: isPending ? AppTheme.primaryColor : Colors.white54,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "RESTANTE",
                                                style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "\$${item.remainingAmount.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  color: isPending ? AppTheme.accentRed : Colors.white54,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text(
                                                "VENCE",
                                                style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.dueDate?.toIso8601String().split('T')[0] ?? 'Sin fecha',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Stack(
                                        children: [
                                          Container(
                                            height: 6,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.05),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor: progress.clamp(0.0, 1.0),
                                            child: Container(
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: isPending ? AppTheme.primaryColor : Colors.white38,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Pagado: \$${(item.totalAmount - item.remainingAmount).toStringAsFixed(0)}",
                                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                                          ),
                                          Text(
                                            "${(progress * 100).toInt()}%",
                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: 60,
                                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isPending) ...[
                                        IconButton(
                                          onPressed: () => controller.makePayment(item),
                                          icon: const Icon(Icons.payments_outlined, color: AppTheme.primaryColor, size: 24),
                                          tooltip: 'Abonar',
                                        ),
                                        IconButton(
                                          onPressed: () => controller.markPaid(item.id),
                                          icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 22),
                                          tooltip: 'Pagar todo',
                                        ),
                                      ],
                                      IconButton(
                                        onPressed: () => controller.editDebt(item),
                                        icon: const Icon(Icons.edit_outlined, color: Colors.white38, size: 20),
                                        tooltip: 'Editar',
                                      ),
                                      IconButton(
                                        onPressed: () => controller.deleteDebt(item.id, item.name),
                                        icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
                                        tooltip: 'Eliminar',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_debt_fab',
        onPressed: () => Get.to(() => const AddDebtView()),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
