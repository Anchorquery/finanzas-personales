import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_finanzas_mobile/core/utils/currency_utils.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/models/finance/transaction.dart';
import '../../../core/utils/icon_utils.dart';
import '../../profile/views/profile_view.dart';

class DashboardAltView extends GetView<DashboardController> {
  const DashboardAltView({super.key});

  void _openBudgets() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().showBudgets();
      return;
    }
    Get.toNamed(Routes.budgets);
  }

  void _openSavings() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().showSavings();
      return;
    }
    Get.toNamed(Routes.savings);
  }

  void _openIncomes() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().showIncomes();
      return;
    }
    Get.toNamed(Routes.incomes);
  }

  void _openDebts() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().showDebts();
      return;
    }
    Get.toNamed(Routes.debts);
  }

  void _openExpenses() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().showExpenses();
      return;
    }
    Get.toNamed(Routes.expenses);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: 120,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con bienvenida y perfil
                _buildHeader(context, isDark),
                const SizedBox(height: 20),

                // Card principal de saldo
                _buildBalanceCard(context, isDark),
                const SizedBox(height: 20),

                // Consejo del AI Coach
                _buildAICoachCard(context, isDark),
                const SizedBox(height: 20),

                // Botones de acción
                _buildActionButtons(context, isDark),
                const SizedBox(height: 24),

                // Accesos Directos
                _buildShortcutsSection(context, isDark),
                const SizedBox(height: 24),

                // Transacciones
                _buildTransactionsSection(context, isDark),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShortcutsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Accesos Directos",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildSmallShortcut(
                context,
                icon: Icons.receipt_long_rounded,
                label: "Gastos",
                color: AppTheme.accentRed,
                onTap: _openExpenses,
              ),
              const SizedBox(width: 12),
              _buildSmallShortcut(
                context,
                icon: Icons.money_off,
                label: "Deudas",
                color: Colors.redAccent,
                onTap: _openDebts,
              ),
              const SizedBox(width: 12),
              _buildSmallShortcut(
                context,
                icon: Icons.pie_chart,
                label: "Presupuestos",
                color: Colors.blueAccent,
                onTap: _openBudgets,
              ),
              const SizedBox(width: 12),
              _buildSmallShortcut(
                context,
                icon: Icons.savings,
                label: "Ahorros",
                color: Colors.green,
                onTap: _openSavings,
              ),
              const SizedBox(width: 12),
              _buildSmallShortcut(
                context,
                icon: Icons.add_chart_rounded,
                label: "Ingresos",
                color: AppTheme.accentGreen,
                onTap: _openIncomes,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallShortcut(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (!isWide)
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: Color(0xFF3B82F6)),
                onPressed: () => Get.find<HomeController>().scaffoldKey.currentState?.openDrawer(),
              ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido de nuevo,',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Obx(
                      () => Text(
                        controller.userName.value.isEmpty
                            ? 'Usuario'
                            : controller.userName.value,
                        style: const TextStyle(
                          color: Color(0xFF3B82F6), // Azul
                          fontSize: 22, // Un poco más pequeño para acomodar el menú
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Botón para cambiar vista
            GestureDetector(
              onTap: () => controller.toggleDashboardView(),
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.surfaceDark
                      : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.view_carousel_outlined,
                  size: 20,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => const ProfileView()),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.surfaceDark
                      : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 24,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E3A8A), // Navy blue
                  AppTheme.backgroundDark, // Dark slate matching home
                ]
              : [
                  const Color(0xFF2563EB), // Blue
                  const Color(0xFF1E40AF), // Darker blue
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Total',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: AppTheme.accentGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+2.4%',
                      style: TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              CurrencyUtils.formatInDisplayCurrency(controller.totalBalance.value, controller.currency.value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Actualizado hace un momento',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 20),

          // Ingresos y Gastos
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_downward,
                              color: AppTheme.accentGreen,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Ingresos',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Text(
                          '+${CurrencyUtils.formatInDisplayCurrency(controller.totalIncome.value, controller.currency.value)}',
                          style: const TextStyle(
                            color: AppTheme.accentGreen,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '+12% vs ant.',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentRed.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_upward,
                              color: AppTheme.accentRed,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Gastos',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Text(
                          '-${CurrencyUtils.formatInDisplayCurrency(controller.totalExpense.value, controller.currency.value)}',
                          style: const TextStyle(
                            color: AppTheme.accentRed,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '-5% vs ant.',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAICoachCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.aiCoach),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consejo del AI Coach',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Has gastado un 15% menos en com...',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.black26,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            isDark: isDark,
            icon: Icons.sync,
            label: 'Sincronizar\nTelegram',
            color: const Color(0xFF0088CC),
            onTap: () {
              // Acción para sincronizar Telegram
              Get.snackbar(
                'Sincronizando',
                'Conectando con Telegram...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            isDark: isDark,
            icon: Icons.add,
            label: 'Nuevo\nGasto',
            color: const Color(0xFF059669),
            onTap: () {
              Get.toNamed(Routes.transactions);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transacciones',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(Routes.transactions),
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.recentTransactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  "No hay transacciones recientes",
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            );
          }
          return Column(
            children: controller.recentTransactions
                .take(5)
                .map((t) => _buildTransactionItem(context, isDark, t))
                .toList(),
          );
        }),
      ],
    );
  }

  Map<String, dynamic> _getTransactionIconInfo(Transaction transaction) {
    final isOpeningBalance = transaction.type == 'opening_balance';
    final isIncome = transaction.type == 'income' || isOpeningBalance;
    final iconName = transaction.category?.icon;

    if (isOpeningBalance) {
      return {
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppTheme.accentColor,
      };
    }

    if (iconName != null) {
      // Intentar obtener color de la categoría si existe
      Color? catColor;
      if (transaction.category?.color != null) {
        try {
          final colorStr = transaction.category!.color!.replaceAll('#', '');
          catColor = Color(int.parse('FF$colorStr', radix: 16));
        } catch (_) {}
      }

      return {
        'icon': IconUtils.getIconByName(iconName),
        'color': catColor ?? (isIncome ? AppTheme.accentGreen : AppTheme.accentRed),
      };
    }

    return {
      'icon': isIncome ? Icons.arrow_downward : Icons.arrow_upward,
      'color': isIncome ? AppTheme.accentGreen : AppTheme.accentRed,
    };
  }

  Widget _buildTransactionItem(
    BuildContext context,
    bool isDark,
    Transaction transaction,
  ) {
    final iconInfo = _getTransactionIconInfo(transaction);
    final iconData = iconInfo['icon'] as IconData;
    final color = iconInfo['color'] as Color;
    
    final isOpeningBalance = transaction.type == 'opening_balance';
    final isIncome = transaction.type == 'income' || isOpeningBalance;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          _shadow(isDark),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.concept.isEmpty ? 'Sin concepto' : transaction.concept,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isOpeningBalance 
                      ? 'Saldo inicial' 
                      : (transaction.category?.name ?? 'General'),
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${CurrencyUtils.formatInDisplayCurrency(transaction.amount.abs(), transaction.currency)}',
                style: TextStyle(
                  color: isIncome ? AppTheme.accentGreen : AppTheme.accentRed,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (transaction.currency != CurrencyUtils.displayCurrency.value)
                Text(
                  CurrencyUtils.formatInDisplayCurrency(
                    transaction.amount,
                    transaction.currency,
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  BoxShadow _shadow(bool isDark) {
    return BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    );
  }
}
