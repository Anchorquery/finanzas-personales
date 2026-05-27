import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/widgets/transactions/transaction_list_item.dart';
import '../../../core/widgets/navigation/custom_bottom_navigation_bar.dart';
import '../../../core/widgets/navigation/custom_bottom_nav_bar_item.dart';
import '../../../core/widgets/transactions/templates_grid.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/transactions_controller.dart';
import '../../home/controllers/home_controller.dart';
import 'add_transaction_view.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TransactionsController>()) {
      Get.put(TransactionsController());
    }
    final homeController = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = [
      const CustomBottomNavBarItem(
        icon: Icons.grid_view_rounded,
        label: 'Dashboard',
      ),
      const CustomBottomNavBarItem(
        icon: Icons.analytics_outlined,
        label: 'Stats',
      ),
      const CustomBottomNavBarItem(icon: Icons.add, isAddButton: true),
      const CustomBottomNavBarItem(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Coach',
      ),
      const CustomBottomNavBarItem(
        icon: Icons.settings_outlined,
        label: 'Ajustes',
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF6F6F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isDark),
            // Search bar
            Obx(() => controller.isSearching.value
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: TextField(
                      onChanged: (v) => controller.searchQuery.value = v,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Buscar transacción...',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.black38),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            controller.searchQuery.value = '';
                            controller.isSearching.value = false;
                          },
                        ),
                        filled: true,
                        fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
            _buildPeriodSelector(isDark),
            // Type filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Obx(() => Row(
                children: [
                  _buildTypeChip(null, 'Todos', isDark),
                  const SizedBox(width: 8),
                  _buildTypeChip('income', 'Ingresos', isDark),
                  const SizedBox(width: 8),
                  _buildTypeChip('expense', 'Gastos', isDark),
                ],
              )),
            ),
            _buildSummary(isDark),
            const TemplatesGrid(),
            Expanded(child: _buildTransactionList(context, isDark)),
          ],
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width >= 800
          ? null
          : CustomBottomNavigationBar(
              currentIndex: 1,
              onTap: (index) {
                if (index == 2) {
                  homeController.changeIndex(2);
                } else {
                  Get.offAllNamed('/home', arguments: {'index': index});
                }
              },
              items: navItems,
            ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : AppTheme.backgroundDark,
              size: 20,
            ),
          ),
          Text(
            AppL10n.of(context).transactionsTitle,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.backgroundDark,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.search,
                    color: isDark ? Colors.white54 : Colors.black54, size: 22),
                onPressed: () => controller.isSearching.toggle(),
              ),
              IconButton(
                icon: Icon(Icons.file_download_outlined,
                    color: isDark ? Colors.white54 : Colors.black54, size: 22),
                onPressed: controller.exportToCsv,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String? type, String label, bool isDark) {
    final isSelected = controller.filterType.value == type;
    return GestureDetector(
      onTap: () => controller.filterType.value = type,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : (isDark ? AppTheme.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white54 : Colors.black54),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark 
          ? [] 
          : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Obx(() => Row(
        children: [
          _buildPeriodTab('day', 'Día', isDark),
          _buildPeriodTab('week', 'Semana', isDark),
          _buildPeriodTab('month', 'Mes', isDark),
          _buildPeriodTab('year', 'Año', isDark),
        ],
      )),
    );
  }

  Widget _buildPeriodTab(String value, String label, bool isDark) {
    final isSelected = controller.selectedPeriod.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changePeriod(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected 
                ? Colors.white 
                : (isDark ? AppTheme.textSecondary : Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(bool isDark) {
    return Obx(() {
      final date = controller.filterDate.value;
      String dateText;
      switch (controller.selectedPeriod.value) {
        case 'day':
          dateText = DateFormat('dd MMMM yyyy', 'es').format(date);
          break;
        case 'week':
          final start = date.subtract(Duration(days: date.weekday - 1));
          final end = start.add(const Duration(days: 6));
          dateText = "${DateFormat('dd').format(start)} - ${DateFormat('dd MMM').format(end)}";
          break;
        case 'year':
          dateText = DateFormat('yyyy').format(date);
          break;
        case 'month':
        default:
          dateText = DateFormat('MMMM yyyy', 'es').format(date).toUpperCase();
          break;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: controller.previousPeriod,
                  icon: Icon(Icons.chevron_left_rounded, color: isDark ? AppTheme.textSecondary : Colors.grey),
                ),
                Text(
                  dateText,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark ? AppTheme.textSecondary : Colors.grey[600],
                  ),
                ),
                IconButton(
                  onPressed: controller.nextPeriod,
                  icon: Icon(Icons.chevron_right_rounded, color: isDark ? AppTheme.textSecondary : Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyUtils.formatInDisplayCurrency(controller.totalAmount, 'USD'),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.backgroundDark,
              ),
            ),
            Text(
              'Balance Total',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: isDark ? AppTheme.textSecondary : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTransactionList(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredTransactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: isDark ? AppTheme.surfaceDark : Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                AppL10n.of(context).transactionsEmpty,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  color: isDark ? AppTheme.textSecondary : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      // Grouping by date
      final groups = <String, List<dynamic>>{};
      for (var t in controller.filteredTransactions) {
        final dateKey = DateFormat('yyyy-MM-dd').format(t.date);
        groups.putIfAbsent(dateKey, () => []).add(t);
      }

      final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

      return RefreshIndicator(
        onRefresh: controller.refreshTransactions,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final dateStr = dates[index];
            final items = groups[dateStr]!;
            final date = DateTime.parse(dateStr);
            
            String groupTitle;
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final yesterday = today.subtract(const Duration(days: 1));
            
            if (date == today) {
              groupTitle = 'Hoy';
            } else if (date == yesterday) {
              groupTitle = 'Ayer';
            } else {
              groupTitle = DateFormat('dd MMMM', 'es').format(date);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    groupTitle.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: isDark ? AppTheme.textSecondary : Colors.grey[500],
                    ),
                  ),
                ),
                ...items.map((t) {
                  return Slidable(
                    key: ValueKey(t.id),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) {
                            controller.setTransactionForEdit(t);
                            Get.to(() => const AddTransactionView());
                          },
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                        ),
                        SlidableAction(
                          onPressed: (_) {
                            Get.defaultDialog(
                              title: "Eliminar",
                              middleText: "¿Estás seguro de eliminar esta transacción?",
                              textConfirm: "Sí",
                              textCancel: "No",
                              onConfirm: () {
                                Get.back();
                                controller.deleteTransaction(t.id);
                              },
                            );
                          },
                          backgroundColor: AppTheme.accentRed,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                        ),
                      ],
                    ),
                    child: TransactionListItem(transaction: t),
                  );
                }),
              ],
            );
          },
        ),
      );
    });
  }
}
