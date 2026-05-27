import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/finance/subscription.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/subscriptions_controller.dart';
import '../../home/controllers/home_controller.dart';

class SubscriptionsView extends GetView<SubscriptionsController> {
  const SubscriptionsView({super.key});

  @override
  Widget build(BuildContext context) {
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
                      t.subscriptionsTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!isWide) const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                }
                if (controller.subscriptions.isEmpty) {
                  return PullableEmptyState(
                    onRefresh: controller.loadSubscriptions,
                    color: AppTheme.primaryColor,
                    backgroundColor: AppTheme.surfaceDark,
                    icon: Icons.search_off,
                    message: t.subscriptionsEmpty,
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.loadSubscriptions,
                  color: AppTheme.primaryColor,
                  backgroundColor: AppTheme.surfaceDark,
                  child: ListView.separated(
                    itemCount: controller.subscriptions.length,
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sub = controller.subscriptions[index];
                      final inactive = !sub.isActive;
                      return Card(
                        color: AppTheme.surfaceDark.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor
                                .withValues(alpha: 0.1),
                            child: Icon(
                              inactive
                                  ? Icons.pause_circle_outline
                                  : Icons.loop,
                              color: inactive
                                  ? Colors.white38
                                  : AppTheme.primaryColor,
                            ),
                          ),
                          title: Text(
                            sub.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: inactive ? Colors.white54 : Colors.white,
                              decoration: inactive
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            'Facturación: Día ${sub.day ?? '?'}${inactive ? ' • Cancelada' : ''}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${sub.amount}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              PopupMenuButton<String>(
                                color: AppTheme.surfaceDark,
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.white54),
                                onSelected: (v) => _handleAction(v, sub),
                                itemBuilder: (_) => [
                                  if (sub.isActive)
                                    const PopupMenuItem(
                                      value: 'pay',
                                      child: Text('Registrar pago',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Editar',
                                        style:
                                            TextStyle(color: Colors.white)),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Eliminar',
                                        style: TextStyle(
                                            color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            ],
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
        heroTag: 'subscriptions_fab',
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dayCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Agregar Suscripción',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextField(
              controller: amountCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Monto Mensual',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            TextField(
              controller: dayCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Día de cobro (1-31)',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final amount = double.tryParse(amountCtrl.text) ?? 0.0;
              final day = int.tryParse(dayCtrl.text) ?? 1;
              if (name.isEmpty) {
                SnackbarService.showError('Error', 'Nombre requerido.');
                return;
              }
              if (amount <= 0) {
                SnackbarService.showError(
                    'Error', 'Monto debe ser mayor que cero.');
                return;
              }
              if (day < 1 || day > 31) {
                SnackbarService.showError(
                    'Error', 'Día de cobro debe estar entre 1 y 31.');
                return;
              }
              controller.addSubscription(name, amount, day);
              Get.back();
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action, Subscription sub) {
    switch (action) {
      case 'edit':
        controller.editSubscription(sub);
        break;
      case 'delete':
        controller.deleteSubscription(sub);
        break;
      case 'pay':
        controller.registerPayment(sub);
        break;
    }
  }
}
