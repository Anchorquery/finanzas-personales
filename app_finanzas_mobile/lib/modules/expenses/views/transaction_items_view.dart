import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/transaction_items_controller.dart';
import 'transaction_item_evolution_view.dart';
import 'add_transaction_items_view.dart';

class TransactionItemsView extends GetView<TransactionItemsController> {
  const TransactionItemsView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Artículos Comprados'),
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transactionsWithItems.isEmpty) {
          return const Center(
            child: Text("No hay transacciones con artículos", style: TextStyle(color: Colors.white24)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.transactionsWithItems.length,
          itemBuilder: (context, index) {
            final tx = controller.transactionsWithItems[index];
            return _buildTransactionCard(context, tx, controller);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transaction_items_fab',
        onPressed: () => Get.to(() => const AddTransactionItemsView()),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, dynamic tx, TransactionItemsController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          tx.concept,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${DateFormat('dd MMM yyyy').format(tx.date)} • Total: ${controller.formatCurrency(tx.amount)}',
          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500, fontSize: 12),
        ),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: const Icon(Icons.receipt_long_outlined, color: AppTheme.primaryColor),
        ),
        childrenPadding: const EdgeInsets.all(20),
        collapsedIconColor: Colors.white54,
        iconColor: AppTheme.primaryColor,
        children: [
          ...tx.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => Get.to(() => TransactionItemEvolutionView(itemName: item.name)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        Text('${item.quantity} x ${controller.formatCurrency(item.unitPrice)}', 
                             style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(
                    controller.formatCurrency(item.totalPrice),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
