import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routes/app_routes.dart';
import '../controllers/recurring_controller.dart';

class RecurringView extends GetView<RecurringController> {
  const RecurringView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.recurringTitle),
        actions: [
          IconButton(
            tooltip: t.recurringManage,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(Routes.subscriptions),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.recurringItems.isEmpty) {
          return PullableEmptyState(
            onRefresh: controller.loadRecurring,
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.surfaceDark,
            icon: Icons.event_repeat,
            message: t.recurringEmpty,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadRecurring,
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.surfaceDark,
          child: ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.recurringItems.length,
          itemBuilder: (context, index) {
            final item = controller.recurringItems[index];
            final day = item.day ?? 1; // Default to 1st if null

            // Calculate days remaining
            final now = DateTime.now();
            final targetDate = DateTime(now.year, now.month, day);
            final nextDate = targetDate.isBefore(now)
                ? DateTime(now.year, now.month + 1, day)
                : targetDate;
            final daysLeft = nextDate.difference(now).inDays;

            Color statusColor = AppTheme.accentColor;
            if (daysLeft < 3) {
              statusColor = AppTheme.errorColor;
            } else if (daysLeft < 7) {
              statusColor = Colors.orange;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "\$${item.amount}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Vence en $daysLeft días (Día $day)",
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: AppTheme.accentColor,
                        size: 32,
                      ),
                      tooltip: "Registrar Pago",
                      onPressed: () =>
                          _confirmPayment(context, item.name, item.amount),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        );
      }),
    );
  }

  void _confirmPayment(BuildContext context, String name, double amount) {
    Get.defaultDialog(
      title: "Confirmar Pago",
      middleText: "¿Registrar pago de $name por \$$amount?",
      textConfirm: "Sí, Pagar",
      textCancel: "Cancelar",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        controller.payItem(name, amount);
      },
      backgroundColor: const Color(0xFF1E1E1E),
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
    );
  }
}
