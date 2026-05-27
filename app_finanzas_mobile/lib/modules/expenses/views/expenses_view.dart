import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/finance/transaction.dart';
import '../controllers/expenses_controller.dart';
import '../../home/controllers/home_controller.dart';
import 'add_expense_view.dart';
import 'transaction_items_view.dart';

class ExpensesView extends GetView<ExpensesController> {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
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
                  const Expanded(
                    child: Text(
                      "Mis Gastos",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    onPressed: () {
                      Get.to(() => const TransactionItemsView());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadData,
                color: AppTheme.primaryColor,
                backgroundColor: AppTheme.surfaceDark,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildSummaryCard()),
                    SliverToBoxAdapter(child: _buildFilters()),
                    _buildExpensesList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_expense_fab',
        onPressed: () => Get.to(() => const AddExpenseView()),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.2),
              AppTheme.primaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Text(
              'Total este mes',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  controller.formatCurrency(controller.totalExpenses.value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            const SizedBox(height: 16),
            Obx(() {
              final txs = controller.transactions;
              if (txs.isEmpty) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatItem('Top Categoría', '\$0', Icons.local_grocery_store_outlined),
                    const SizedBox(width: 20),
                    _buildStatItem('Otras', '\$0', Icons.category_outlined),
                  ],
                );
              }
              final catTotals = <String, double>{};
              for (final t in txs) {
                final name = t.category?.name ?? 'Otros';
                catTotals[name] = (catTotals[name] ?? 0) + t.amount;
              }
              final sorted = catTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final topName = sorted[0].key;
              final topAmt = sorted[0].value;
              final otherAmt = sorted.length > 1
                  ? sorted.skip(1).fold(0.0, (s, e) => s + e.value)
                  : 0.0;
              final otherLabel = sorted.length > 1 ? '${sorted.length - 1} más' : 'Sin más';
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatItem(topName, controller.formatCurrency(topAmt), Icons.local_grocery_store_outlined),
                  const SizedBox(width: 20),
                  _buildStatItem(otherLabel, controller.formatCurrency(otherAmt), Icons.category_outlined),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SizedBox(
            height: 40,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('Todo', null),
                    ...controller.categories.map((cat) => _buildFilterChip(cat.name, cat.id)),
                  ],
                )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Obx(() {
            final start = controller.startDate.value;
            final end = controller.endDate.value;
            final fmt = DateFormat('dd/MM/yy');
            final hasFilter = start != null || end != null;
            return Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: Get.context!,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDateRange: start != null && end != null
                            ? DateTimeRange(start: start, end: end)
                            : null,
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppTheme.primaryColor,
                              surface: Color(0xFF1E1E1E),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        controller.setDateRange(picked.start, picked.end);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: hasFilter
                            ? AppTheme.primaryColor.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: hasFilter ? AppTheme.primaryColor : Colors.white12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.date_range_rounded,
                            size: 16,
                            color: hasFilter ? AppTheme.primaryColor : Colors.white54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasFilter
                                ? '${fmt.format(start!)} – ${fmt.format(end!)}'
                                : 'Filtrar por fecha',
                            style: TextStyle(
                              color: hasFilter ? AppTheme.primaryColor : Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (hasFilter) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => controller.setDateRange(null, null),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.close_rounded, size: 16, color: Colors.white54),
                    ),
                  ),
                ],
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? id) {
    return Obx(() {
      final isSelected = controller.selectedCategoryId.value == id;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => controller.setCategory(id),
          child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.white12,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
      );
    });
  }

  Widget _buildExpensesList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.transactions.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: Text("No hay gastos registrados", style: TextStyle(color: Colors.white24)),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tx = controller.transactions[index];
            return _buildExpenseItem(tx);
          },
          childCount: controller.transactions.length,
        ),
      );
    });
  }

  Widget _buildExpenseItem(Transaction tx) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_downward,
              color: AppTheme.accentRed,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.concept,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  tx.category?.name ?? 'Sin categoría',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${controller.formatCurrency(tx.amount)}',
                style: const TextStyle(
                  color: AppTheme.accentRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                DateFormat('dd MMM').format(tx.date),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
