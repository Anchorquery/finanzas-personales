import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/dashboard/balance_card.dart';
import '../../../core/widgets/dashboard/stats_grid.dart';
import '../../../core/widgets/dashboard/cash_flow_chart.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../workspaces/controllers/workspaces_controller.dart';
import '../../../data/models/finance/account.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

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

  void _openSubscriptions() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().showSubscriptions();
      return;
    }
    Get.toNamed(Routes.subscriptions);
  }

  void _openExpenses() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().showExpenses();
      return;
    }
    Get.toNamed(Routes.expenses);
  }

  void _openSettings() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().showSettings();
      return;
    }
    Get.toNamed(Routes.settings);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Eliminado Scaffod y Stack de navegación
    // SafeArea para que el contenido no quede detrás del header/status bar
    return SafeArea(
      bottom: false,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Eliminado Stack - Solo el contenido principal
        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 120, // Espacio para NavBar flotante (ahora en MainView)
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = MediaQuery.of(context).size.width >= 800;
                    return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isWide)
                      IconButton(
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: () => Get.find<HomeController>()
                            .scaffoldKey
                            .currentState
                            ?.openDrawer(),
                      ),
                    if (!isWide) const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido de nuevo,',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : AppTheme.textHint,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Obx(
                                  () => Text(
                                    controller.userName.value.isEmpty
                                        ? 'Usuario'
                                        : controller.userName.value,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Selector de Workspace
                          Obx(() {
                            final workspacesController =
                                Get.isRegistered<WorkspacesController>()
                                ? Get.find<WorkspacesController>()
                                : null;
                            final activeWorkspace =
                                workspacesController?.activeWorkspace;
                            final workspaceName =
                                activeWorkspace?.name ?? 'Sin Workspace';
                            final workspaceIcon =
                                activeWorkspace?.icon ?? Icons.work_outline;

                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                              onTap: () {
                                if (workspacesController != null) {
                                  workspacesController.showWorkspaceSelector(
                                    context,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.surfaceDark
                                      : AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : AppTheme.borderLight,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      workspaceIcon,
                                      size: 14,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      workspaceName,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.keyboard_arrow_down, size: 14),
                                  ],
                                ),
                              ),
                            ),
                            ); // Cierre de MouseRegion+GestureDetector
                          }), // Cierre de Obx
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                          onTap: () => controller.toggleDashboardView(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.surfaceDark
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.05),
                              ),
                              // Sombras visibles solo en modo claro
                              boxShadow:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: const Icon(
                              Icons.view_carousel_outlined,
                              size: 20,
                            ),
                          ),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                          onTap: () => Get.to(() => const ProfileView()),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.surfaceDark
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.05),
                              ),
                              // Sombras visibles solo en modo claro
                              boxShadow:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              size: 24,
                            ),
                          ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
                const SizedBox(height: 32),

                // Balance Card
                Obx(
                  () => BalanceCard(
                    balance: controller.totalBalance.value,
                    percentage: controller.balanceChangePercentage.value,
                    currency: controller.currency.value,
                    secondaryCurrency:
                        controller.secondaryCurrency.value.isEmpty
                        ? null
                        : controller.secondaryCurrency.value,
                    exchangeRate: controller.exchangeRate.value > 0
                        ? controller.exchangeRate.value
                        : null,
                    rateSource: controller.openingBalance.value > 0
                        ? 'Incluye saldo inicial de ${CurrencyUtils.formatInDisplayCurrency(controller.openingBalance.value, controller.currency.value)}'
                        : controller.balanceFootnote,
                    breakdown: controller.balanceBreakdown,
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Grid
                Obx(
                  () => StatsGrid(
                    income: controller.totalIncome.value,
                    expenses: controller.totalExpense.value,
                    incomeTrendPercentage:
                        controller.incomeChangePercentage.value,
                    expenseTrendPercentage:
                        controller.expenseChangePercentage.value,
                    currency: controller.currency.value,
                  ),
                ),
                const SizedBox(height: 32),

                // Shortcuts Section (merged from basic view)
                Text(
                  "Accesos Directos",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _DashboardShortcut(
                        icon: Icons.receipt_long_rounded,
                        label: "Gastos",
                        color: AppTheme.accentRed,
                        onTap: _openExpenses,
                      ),
                      const SizedBox(width: 16),
                      _DashboardShortcut(
                        icon: Icons.pie_chart,
                        label: "Presupuestos",
                        color: AppTheme.primaryColor,
                        onTap: _openBudgets,
                      ),
                      const SizedBox(width: 16),
                      _DashboardShortcut(
                        icon: Icons.savings,
                        label: "Ahorros",
                        color: AppTheme.accentGreen,
                        onTap: _openSavings,
                      ),
                      const SizedBox(width: 16),
                      _DashboardShortcut(
                        icon: Icons.add_chart_rounded,
                        label: "Ingresos",
                        color: AppTheme.accentGreen,
                        onTap: _openIncomes,
                      ),
                      const SizedBox(width: 16),
                      _DashboardShortcut(
                        icon: Icons.money_off,
                        label: "Deudas",
                        color: AppTheme.accentRed,
                        onTap: _openDebts,
                      ),
                      const SizedBox(width: 16),
                      _DashboardShortcut(
                        icon: Icons.subscriptions,
                        label: "Suscripciones",
                        color: AppTheme.accentAI,
                        onTap: _openSubscriptions,
                      ),
                      const SizedBox(width: 16),
                      _DashboardShortcut(
                        icon: Icons.event,
                        label: "Eventos",
                        color: AppTheme.accentWarning,
                        onTap: () => Get.toNamed(Routes.events),
                      ),
                      const SizedBox(width: 16),
                      _DashboardShortcut(
                        icon: Icons.smart_toy,
                        label: "Coach AI",
                        color: AppTheme.accentAI,
                        onTap: () => Get.toNamed(Routes.aiCoach),
                      ),
                      const SizedBox(width: 16),
                      _DashboardShortcut(
                        icon: Icons.settings,
                        label: "Ajustes",
                        color: AppTheme.textSecondary,
                        onTap: _openSettings,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Accounts Section
                Obx(() {
                  if (controller.accounts.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mis Cuentas",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed(Routes.settings), // Provisoriamente a ajustes
                            child: const Text('Ver todas'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.accounts.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final account = controller.accounts[index];
                            return _buildAccountCard(account, isDark);
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                }),

                // Premium Cash Flow Chart
                const Text(
                  'Flujo semanal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => CashFlowChart(
                    spots: controller.weeklySpots.toList(),
                    netFlow: controller.weeklyNetFlow.value,
                    currency: controller.currency.value,
                    periodLabel: 'de la semana',
                  ),
                ),
                const SizedBox(height: 32),

                // Insights Financieros
                Obx(() {
                  final tips = controller.insights;
                  if (tips.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.primaryColor.withValues(alpha: 0.08)
                          : AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tips.map((tip) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, color: AppTheme.primaryColor, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(tip, style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ))),
                          ],
                        ),
                      )).toList(),
                    ),
                  );
                }),

                // Comparación Mensual
                Obx(() {
                  if (controller.previousIncome.value == 0 && controller.previousExpense.value == 0) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mes Actual vs Anterior', style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black54,
                        )),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildCompareItem(
                              'Ingresos',
                              controller.totalIncome.value,
                              controller.previousIncome.value,
                              controller.currency.value,
                              isDark,
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _buildCompareItem(
                              'Gastos',
                              controller.totalExpense.value,
                              controller.previousExpense.value,
                              controller.currency.value,
                              isDark,
                            )),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                // Gastos por Categoría (Pie Chart)
                Obx(() {
                  final breakdown = controller.categoryBreakdown;
                  if (breakdown.isEmpty) return const SizedBox.shrink();
                  final total = breakdown.values.fold(0.0, (a, b) => a + b);
                  const colors = AppTheme.chartPalette;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gastos por Categoría', style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        )),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: PieChart(PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 35,
                            sections: breakdown.entries.toList().asMap().entries.map((entry) {
                              final color = colors[entry.key % colors.length];
                              return PieChartSectionData(
                                value: entry.value.value,
                                title: '${(entry.value.value / total * 100).toStringAsFixed(0)}%',
                                color: color,
                                radius: 45,
                                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              );
                            }).toList(),
                          )),
                        ),
                        const SizedBox(height: 12),
                        ...breakdown.entries.toList().asMap().entries.map((entry) {
                          final color = colors[entry.key % colors.length];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(
                                color: color, borderRadius: BorderRadius.circular(3),
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: Text(entry.value.key, style: TextStyle(
                                fontSize: 13, color: isDark ? Colors.white70 : Colors.black87,
                              ))),
                              Text(
                                CurrencyUtils.formatInDisplayCurrency(entry.value.value, controller.currency.value),
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87),
                              ),
                            ]),
                          );
                        }),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),

                // Recent Movements Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Últimos Movimientos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.transactions),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (controller.recentTransactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        "No hay movimientos recientes",
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  ...controller.recentTransactions.map(
                    (t) => TransactionTile(transaction: t),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
  Widget _buildAccountCard(Account account, bool isDark) {
    final color = _getAccountTypeColor(account.type);
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: !isDark ? [
           BoxShadow(
             color: Colors.black.withValues(alpha: 0.03),
             blurRadius: 10,
             offset: const Offset(0, 4),
           )
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                account.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Icon(_getAccountTypeIcon(account.type), size: 14, color: color.withValues(alpha: 0.6)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CurrencyUtils.formatInDisplayCurrency(account.currentBalance, controller.currency.value),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                _getAccountTypeText(account.type),
                style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getAccountTypeIcon(String type) {
    switch(type) {
      case 'cash': return Icons.money;
      case 'bank': return Icons.account_balance;
      case 'credit_card': return Icons.credit_card;
      case 'investment': return Icons.trending_up;
      default: return Icons.account_balance_wallet;
    }
  }

  Color _getAccountTypeColor(String type) {
     switch(type) {
      case 'cash': return AppTheme.accentGreen;
      case 'bank': return AppTheme.accentBlue;
      case 'credit_card': return AppTheme.accentRed;
      case 'investment': return AppTheme.primaryColor;
      default: return AppTheme.textSecondary;
    }
  }

  String _getAccountTypeText(String type) {
    switch(type) {
      case 'cash': return 'Efectivo';
      case 'bank': return 'Banco';
      case 'credit_card': return 'Tarjeta de Crédito';
      case 'investment': return 'Inversión';
      default: return 'Otro';
    }
  }

  Widget _buildCompareItem(String label, double current, double previous, String cur, bool isDark) {
    final change = previous > 0 ? ((current - previous) / previous * 100) : 0.0;
    final isUp = change >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
        const SizedBox(height: 4),
        Text(
          CurrencyUtils.formatInDisplayCurrency(current, cur),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 2),
        Row(children: [
          Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14, color: label == 'Ingresos' ? (isUp ? AppTheme.accentGreen : AppTheme.accentRed) : (isUp ? AppTheme.accentRed : AppTheme.accentGreen)),
          Text('${change.abs().toStringAsFixed(0)}%', style: TextStyle(fontSize: 12,
            color: label == 'Ingresos' ? (isUp ? AppTheme.accentGreen : AppTheme.accentRed) : (isUp ? AppTheme.accentRed : AppTheme.accentGreen))),
        ]),
      ],
    );
  }
}

class _DashboardShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardShortcut({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16), // Más redondeado (era 20)
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
          // Sombras visibles solo en modo claro
          boxShadow: Theme.of(context).brightness == Brightness.light
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15), // Más opaco (era 0.1)
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
    );
  }
}
