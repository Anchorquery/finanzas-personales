import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/widgets/transactions/add_transaction_modal.dart';
import '../../../data/models/finance/account.dart';
import '../../../data/models/finance/transaction.dart';
import '../../../data/models/workspace.dart';
import '../../../data/services/exchange_rate_service.dart';
import '../../../routes/app_routes.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../workspaces/controllers/workspaces_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  // ── Brand palette tuned to the fintech mockup ─────────────────────────────
  static const Color _bgStart = Color(0xFFF5F3FF); // top-right violet glow
  static const Color _bgMid = Color(0xFFFFFFFF);
  static const Color _bgEnd = Color(0xFFF8FAFC);
  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate700 = Color(0xFF334155);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate400 = Color(0xFF94A3B8);
  static const Color _slate200 = Color(0xFFE2E8F0);
  static const Color _slate100 = Color(0xFFF1F5F9);

  // ── Wide layout extras ────────────────────────────────────────────────────
  static const Color _wideBg = Color(0xFFF9F9F9);
  static const Color _wideOutline = Color(0xFFE7E3EE);
  static const Color _wideTipBg = Color(0xFF1E1B4B); // indigo-900
  static const Color _emerald600 = Color(0xFF059669);
  static const Color _emerald50 = Color(0xFFECFDF5);
  static const Color _rose600 = Color(0xFFDC2626);
  static const Color _rose50 = Color(0xFFFFF1F2);

  // ── Navigation helpers (reuse HomeController if mounted) ──────────────────
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

  void _openExpenses() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().showExpenses();
      return;
    }
    Get.toNamed(Routes.expenses);
  }

  void _openTransactions() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().currentIndex.value =
          HomeController.transactionsIndex;
      return;
    }
    Get.toNamed(Routes.transactions);
  }

  void _openAccounts() {
    Get.toNamed(Routes.settings);
  }

  void _openDrawer() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().scaffoldKey.currentState?.openDrawer();
    }
  }

  void _openWorkspaceSelector(BuildContext context) {
    if (Get.isRegistered<WorkspacesController>()) {
      Get.find<WorkspacesController>().showWorkspaceSelector(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return _buildWideLayout(context);
        }
        return _buildNarrowLayout(context);
      },
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.2,
          colors: [_bgStart, _bgMid, _bgEnd],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: controller.loadDashboard,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _TopBar(
                  onMenu: _openDrawer,
                  onAvatar: () => Get.to(() => const ProfileView()),
                  onWorkspaceTap: () => _openWorkspaceSelector(context),
                )),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
                  sliver: SliverList.list(
                    children: [
                      _BalanceCard(controller: controller),
                      const SizedBox(height: 28),
                      _KpiRow(controller: controller),
                      const SizedBox(height: 32),
                      _QuickActions(
                        onExpenses: _openExpenses,
                        onBudgets: _openBudgets,
                        onSavings: _openSavings,
                      ),
                      const SizedBox(height: 32),
                      _AccountsSection(
                        controller: controller,
                        onSeeAll: _openAccounts,
                      ),
                      const SizedBox(height: 32),
                      _WeeklyFlow(controller: controller),
                      const SizedBox(height: 32),
                      _RecentTransactions(
                        controller: controller,
                        onViewAll: _openTransactions,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return ColoredBox(
      color: _wideBg,
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: controller.loadDashboard,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _WideTopBar(
                    onAvatar: () => Get.to(() => const ProfileView()),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _WideHeroBalance(controller: controller),
                            const SizedBox(height: 24),
                            _WideKpiRow(controller: controller),
                            const SizedBox(height: 24),
                            _WideGrid(
                              controller: controller,
                              onAddExpense: () => _openAddTransaction(context),
                              onTransferFunds: _openTransactions,
                              onAdjustBudget: _openBudgets,
                              onAnalyzeTrends: () =>
                                  Get.toNamed(Routes.aiCoach),
                              onViewAllTx: _openTransactions,
                              onAddAccount: _openAccounts,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    Get.bottomSheet(
      const AddTransactionModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ── Top Bar ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onMenu;
  final VoidCallback onAvatar;
  final VoidCallback onWorkspaceTap;

  const _TopBar({
    required this.onMenu,
    required this.onAvatar,
    required this.onWorkspaceTap,
  });

  @override
  Widget build(BuildContext context) {
    final dashController = Get.find<DashboardController>();
    final workspacesController = Get.isRegistered<WorkspacesController>()
        ? Get.find<WorkspacesController>()
        : null;
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        border: Border(
          bottom: BorderSide(
            color: DashboardView._slate200.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isWide)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: DashboardView._slate700),
              onPressed: onMenu,
              tooltip: 'Menú',
            ),
          if (!isWide) const SizedBox(width: 4),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onWorkspaceTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final ws = workspacesController?.activeWorkspace;
                      final typeLabel = _workspaceTypeLabel(ws?.type);
                      return Text(
                        typeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DashboardView._slate500,
                          letterSpacing: 0.8,
                        ),
                      );
                    }),
                    const SizedBox(height: 2),
                    Obx(() {
                      final ws = workspacesController?.activeWorkspace;
                      final name = ws?.name ?? 'Sin Workspace';
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: DashboardView._slate900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.expand_more_rounded,
                            size: 18,
                            color: DashboardView._slate400,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          _CircleIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          Obx(() {
            final initial = dashController.userName.value.isNotEmpty
                ? dashController.userName.value[0].toUpperCase()
                : 'U';
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onAvatar,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

String _workspaceTypeLabel(WorkspaceType? type) {
  switch (type) {
    case WorkspaceType.family:
      return 'WORKSPACE FAMILIAR';
    case WorkspaceType.business:
      return 'WORKSPACE EMPRESARIAL';
    case WorkspaceType.personal:
    default:
      return 'WORKSPACE PERSONAL';
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: DashboardView._slate200),
          ),
          child: Icon(icon, size: 20, color: DashboardView._slate500),
        ),
      ),
    );
  }
}

// ── Balance Card ────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final DashboardController controller;
  const _BalanceCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BALANCE TOTAL',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _CurrencyToggle(),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Obx(() {
                          final formatted = CurrencyUtils.formatInDisplayCurrency(
                            controller.totalBalance.value,
                            controller.currency.value,
                          );
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              formatted,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.5,
                                height: 1.0,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Obx(() {
                        final pct = controller.balanceChangePercentage.value;
                        final isUp = pct >= 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUp
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${isUp ? '+' : ''}${pct.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Obx(() {
                    final hasOpening = controller.openingBalance.value > 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasOpening)
                          Text(
                            controller.balanceFootnote,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        if (hasOpening) const SizedBox(height: 4),
                        Text(
                          controller.balanceBreakdown,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyToggle extends StatelessWidget {
  const _CurrencyToggle();

  @override
  Widget build(BuildContext context) {
    final options = CurrencyUtils.displayCurrencies;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Obx(() {
        final active = CurrencyUtils.displayCurrency.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: options.map((code) {
            final selected = active == code;
            return GestureDetector(
              onTap: () => CurrencyUtils.setDisplayCurrency(code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    color: selected
                        ? AppTheme.primary
                        : Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}

// ── KPI Row (Income / Expenses) ─────────────────────────────────────────────
class _KpiRow extends StatelessWidget {
  final DashboardController controller;
  const _KpiRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            title: 'INGRESOS',
            icon: Icons.south_west_rounded,
            iconColor: AppTheme.accentGreen,
            iconBg: AppTheme.accentGreen.withValues(alpha: 0.12),
            amountObs: () => CurrencyUtils.formatInDisplayCurrency(
              controller.totalIncome.value,
              controller.currency.value,
            ),
            percentObs: () => controller.incomeChangePercentage.value,
            comparisonLabel: 'vs último mes',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _KpiCard(
            title: 'GASTOS',
            icon: Icons.north_east_rounded,
            iconColor: AppTheme.accentRed,
            iconBg: AppTheme.accentRed.withValues(alpha: 0.12),
            amountObs: () => CurrencyUtils.formatInDisplayCurrency(
              controller.totalExpense.value,
              controller.currency.value,
            ),
            percentObs: () => controller.expenseChangePercentage.value,
            comparisonLabel: 'vs último mes',
            invertChangeColor: true,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String Function() amountObs;
  final double Function() percentObs;
  final String comparisonLabel;
  final bool invertChangeColor;

  const _KpiCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.amountObs,
    required this.percentObs,
    required this.comparisonLabel,
    this.invertChangeColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: DashboardView._slate200.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DashboardView._slate500,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Obx(() => FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amountObs(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: DashboardView._slate900,
                  ),
                ),
              )),
          const SizedBox(height: 6),
          Obx(() {
            final pct = percentObs();
            final isUp = pct >= 0;
            final positive = invertChangeColor ? !isUp : isUp;
            final color = positive ? AppTheme.accentGreen : AppTheme.accentRed;
            return Row(
              children: [
                Icon(
                  isUp
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${isUp ? '+' : ''}${pct.toStringAsFixed(1)}% $comparisonLabel',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Quick Actions ───────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final VoidCallback onExpenses;
  final VoidCallback onBudgets;
  final VoidCallback onSavings;

  const _QuickActions({
    required this.onExpenses,
    required this.onBudgets,
    required this.onSavings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('ACCIONES RÁPIDAS'),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              _QuickActionItem(
                icon: Icons.receipt_long_rounded,
                label: 'Gastos',
                color: AppTheme.accentRed,
                onTap: onExpenses,
              ),
              const SizedBox(width: 20),
              _QuickActionItem(
                icon: Icons.pie_chart_outline_rounded,
                label: 'Presupuestos',
                color: AppTheme.primary,
                onTap: onBudgets,
              ),
              const SizedBox(width: 20),
              _QuickActionItem(
                icon: Icons.savings_outlined,
                label: 'Ahorros',
                color: AppTheme.accentGreen,
                onTap: onSavings,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: DashboardView._slate200.withValues(alpha: 0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: DashboardView._slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Accounts Section ────────────────────────────────────────────────────────
class _AccountsSection extends StatelessWidget {
  final DashboardController controller;
  final VoidCallback onSeeAll;

  const _AccountsSection({
    required this.controller,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionLabel('MIS CUENTAS'),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onSeeAll,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Ver todas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Obx(() {
          final accounts = controller.accounts;
          if (accounts.isEmpty) {
            return _EmptyHint(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Aún no tienes cuentas',
            );
          }
          if (accounts.length == 1) {
            return _AccountCard(account: accounts.first, isPrimary: true);
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < accounts.length; i++) ...[
                  SizedBox(
                    width: 280,
                    child: _AccountCard(
                      account: accounts[i],
                      isPrimary: i == 0,
                    ),
                  ),
                  if (i < accounts.length - 1) const SizedBox(width: 14),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final bool isPrimary;

  const _AccountCard({required this.account, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: DashboardView._slate200.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPrimary ? 'CUENTA PRINCIPAL' : _accountTypeLabel(account.type),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: DashboardView._slate400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      account.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: DashboardView._slate900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accountColor(account.type).withValues(alpha: 0.12),
                ),
                child: Icon(
                  _accountIcon(account.type),
                  size: 20,
                  color: _accountColor(account.type),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Obx(() {
            final controller = Get.find<DashboardController>();
            return Text(
              CurrencyUtils.formatInDisplayCurrency(
                account.currentBalance,
                controller.currency.value,
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: DashboardView._slate900,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _accountTypeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'EFECTIVO';
      case 'bank':
        return 'BANCO';
      case 'credit_card':
        return 'TARJETA DE CRÉDITO';
      case 'investment':
        return 'INVERSIÓN';
      default:
        return 'OTRA CUENTA';
    }
  }

  IconData _accountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.payments_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'credit_card':
        return Icons.credit_card_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _accountColor(String type) {
    switch (type) {
      case 'cash':
        return AppTheme.accentGreen;
      case 'bank':
        return AppTheme.accentBlue;
      case 'credit_card':
        return AppTheme.accentRed;
      case 'investment':
        return AppTheme.primary;
      default:
        return DashboardView._slate500;
    }
  }
}

// ── Weekly Flow ─────────────────────────────────────────────────────────────
class _WeeklyFlow extends StatelessWidget {
  final DashboardController controller;
  const _WeeklyFlow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('FLUJO SEMANAL'),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: DashboardView._slate200.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Obx(() => Text(
                        CurrencyUtils.formatInDisplayCurrency(
                          controller.weeklyNetFlow.value,
                          controller.currency.value,
                        ),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: DashboardView._slate900,
                        ),
                      )),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      'FLUJO NETO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: DashboardView._slate400,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 140,
                child: Obx(() {
                  final spots = controller.weeklySpots.toList();
                  final hasMovement = spots.any((s) => s.y.abs() > 0);
                  if (spots.isEmpty || !hasMovement) {
                    return const Center(
                      child: Text(
                        'Sin movimientos esta semana',
                        style: TextStyle(
                          color: DashboardView._slate400,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return LineChart(_lineData(spots));
                }),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _DayLabel('LUN'),
                  _DayLabel('MAR'),
                  _DayLabel('MIE'),
                  _DayLabel('JUE'),
                  _DayLabel('VIE'),
                  _DayLabel('SAB'),
                  _DayLabel('DOM'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  LineChartData _lineData(List<FlSpot> spots) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppTheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppTheme.primary,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primary.withValues(alpha: 0.2),
                AppTheme.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String day;
  const _DayLabel(this.day);

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: DashboardView._slate400,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ── Recent Transactions ─────────────────────────────────────────────────────
class _RecentTransactions extends StatelessWidget {
  final DashboardController controller;
  final VoidCallback onViewAll;

  const _RecentTransactions({
    required this.controller,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionLabel('ÚLTIMOS MOVIMIENTOS'),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onViewAll,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Ver todos',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Obx(() {
          final txs = controller.recentTransactions;
          if (txs.isEmpty) {
            return _EmptyHint(
              icon: Icons.receipt_outlined,
              label: 'No hay movimientos recientes',
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: DashboardView._slate200.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < txs.length; i++) ...[
                  _TransactionRow(transaction: txs[i]),
                  if (i < txs.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: DashboardView._slate200.withValues(alpha: 0.4),
                      indent: 20,
                      endIndent: 20,
                    ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction transaction;
  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final isOpening = transaction.type == 'opening_balance';

    final IconData icon;
    final Color iconColor;
    final Color iconBg;
    if (isOpening) {
      icon = Icons.account_balance_wallet_rounded;
      iconColor = DashboardView._slate700;
      iconBg = DashboardView._slate100;
    } else if (isIncome) {
      icon = Icons.work_outline_rounded;
      iconColor = AppTheme.primary;
      iconBg = AppTheme.primary.withValues(alpha: 0.12);
    } else {
      icon = Icons.shopping_bag_outlined;
      iconColor = AppTheme.accentRed;
      iconBg = AppTheme.accentRed.withValues(alpha: 0.12);
    }

    final amountColor =
        isIncome || isOpening ? AppTheme.accentGreen : AppTheme.accentRed;
    final sign = (isIncome || isOpening) ? '+' : '-';

    final dateLabel = _formatDate(transaction.date);
    final subLabel = transaction.userCreated?.firstName.isNotEmpty == true
        ? transaction.userCreated!.firstName.toUpperCase()
        : 'WALLET';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.concept.isEmpty
                      ? (isIncome ? 'Ingreso' : 'Gasto')
                      : transaction.concept,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DashboardView._slate900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$subLabel • $dateLabel',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DashboardView._slate400,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final controller = Get.find<DashboardController>();
            final amountText =
                '$sign${CurrencyUtils.formatInDisplayCurrency(transaction.amount.abs(), controller.currency.value)}';
            return Text(
              amountText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: amountColor,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    return '$day $month';
  }
}

// ── Shared bits ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: DashboardView._slate400,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyHint({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: DashboardView._slate400),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: DashboardView._slate500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDE / DESKTOP LAYOUT
// ═══════════════════════════════════════════════════════════════════════════

class _WideTopBar extends StatelessWidget {
  final VoidCallback onAvatar;
  const _WideTopBar({required this.onAvatar});

  @override
  Widget build(BuildContext context) {
    final dashController = Get.find<DashboardController>();
    final workspacesController = Get.isRegistered<WorkspacesController>()
        ? Get.find<WorkspacesController>()
        : null;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: DashboardView._wideBg.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: DashboardView._wideOutline.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1C),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const TextField(
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  filled: false,
                  icon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF4A4455),
                    size: 18,
                  ),
                  hintText: 'Buscar transacciones, presupuestos...',
                  hintStyle: TextStyle(
                    color: Color(0xFF7B7487),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF4A4455),
            ),
            onPressed: () {},
            tooltip: 'Notificaciones',
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: DashboardView._wideOutline),
              ),
            ),
            child: Row(
              children: [
                Obx(() {
                  final ws = workspacesController?.activeWorkspace;
                  final wsLabel = ws?.name ?? 'Personal Workspace';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dashController.userName.value.isEmpty
                            ? 'Usuario'
                            : dashController.userName.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1C1C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        wsLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4A4455),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(width: 12),
                Obx(() {
                  final initial = dashController.userName.value.isNotEmpty
                      ? dashController.userName.value[0].toUpperCase()
                      : 'U';
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onAvatar,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color(0xFFEADDFF),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wide Hero Balance ──────────────────────────────────────────────────────
class _WideHeroBalance extends StatelessWidget {
  final DashboardController controller;
  const _WideHeroBalance({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -80,
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -40,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              right: 48,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: 56,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BALANCE DISPONIBLE',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final formatted = CurrencyUtils.formatInDisplayCurrency(
                      controller.totalBalance.value,
                      controller.currency.value,
                    );
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            formatted,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                              letterSpacing: -1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            CurrencyUtils.displayCurrency.value,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                  _SecondaryCurrencyPills(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryCurrencyPills extends StatelessWidget {
  final DashboardController controller;
  const _SecondaryCurrencyPills({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final base = controller.currency.value;
      final amount = controller.totalBalance.value;
      final pills = <Widget>[];
      final hasService = Get.isRegistered<ExchangeRateService>();
      final service = hasService ? Get.find<ExchangeRateService>() : null;

      for (final code in CurrencyUtils.displayCurrencies) {
        if (code == base) continue;
        double converted = amount;
        if (service != null) {
          converted = service.convertAmount(amount, base, code);
        }
        if (converted == 0 && amount != 0) continue;
        pills.add(_CurrencyPill(
          code: code,
          amount: converted,
        ));
        pills.add(const SizedBox(width: 12));
      }
      if (pills.isEmpty) return const SizedBox.shrink();
      pills.removeLast();
      return Row(mainAxisSize: MainAxisSize.min, children: pills);
    });
  }
}

class _CurrencyPill extends StatelessWidget {
  final String code;
  final double amount;
  const _CurrencyPill({required this.code, required this.amount});

  @override
  Widget build(BuildContext context) {
    final icon = code == 'EUR'
        ? Icons.euro_rounded
        : code == 'VES'
            ? Icons.payments_outlined
            : Icons.attach_money_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '${CurrencyUtils.formatAmount(amount, code)} $code',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wide KPI Row ───────────────────────────────────────────────────────────
class _WideKpiRow extends StatelessWidget {
  final DashboardController controller;
  const _WideKpiRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _WideKpiCard(
            title: 'Ingresos del Mes',
            icon: Icons.trending_up_rounded,
            iconBg: DashboardView._emerald50,
            iconColor: DashboardView._emerald600,
            amountObs: () => CurrencyUtils.formatInDisplayCurrency(
              controller.totalIncome.value,
              controller.currency.value,
            ),
            percentObs: () => controller.incomeChangePercentage.value,
            badgeColorPositive: true,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _WideKpiCard(
            title: 'Gastos del Mes',
            icon: Icons.trending_down_rounded,
            iconBg: DashboardView._rose50,
            iconColor: DashboardView._rose600,
            amountObs: () => CurrencyUtils.formatInDisplayCurrency(
              controller.totalExpense.value,
              controller.currency.value,
            ),
            percentObs: () => controller.expenseChangePercentage.value,
            badgeColorPositive: false,
          ),
        ),
      ],
    );
  }
}

class _WideKpiCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String Function() amountObs;
  final double Function() percentObs;
  final bool badgeColorPositive;

  const _WideKpiCard({
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.amountObs,
    required this.percentObs,
    required this.badgeColorPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _wideCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4455),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      amountObs(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1C1C),
                      ),
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
          ),
          Obx(() {
            final pct = percentObs();
            final sign = pct >= 0 ? '+' : '';
            final isPositive = badgeColorPositive ? pct >= 0 : pct <= 0;
            final fg = isPositive
                ? DashboardView._emerald600
                : DashboardView._rose600;
            final bg =
                isPositive ? DashboardView._emerald50 : DashboardView._rose50;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$sign${pct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'vs mes anterior',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF7B7487),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Wide Grid (2/3 + 1/3) ──────────────────────────────────────────────────
class _WideGrid extends StatelessWidget {
  final DashboardController controller;
  final VoidCallback onAddExpense;
  final VoidCallback onTransferFunds;
  final VoidCallback onAdjustBudget;
  final VoidCallback onAnalyzeTrends;
  final VoidCallback onViewAllTx;
  final VoidCallback onAddAccount;

  const _WideGrid({
    required this.controller,
    required this.onAddExpense,
    required this.onTransferFunds,
    required this.onAdjustBudget,
    required this.onAnalyzeTrends,
    required this.onViewAllTx,
    required this.onAddAccount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final stack = constraints.maxWidth < 800;
      if (stack) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WideWeeklyFlow(controller: controller),
            const SizedBox(height: 24),
            _WideTransactionsTable(
              controller: controller,
              onViewAll: onViewAllTx,
            ),
            const SizedBox(height: 24),
            _WideAccountsPanel(
              controller: controller,
              onAddAccount: onAddAccount,
            ),
            const SizedBox(height: 24),
            _WideQuickActions(
              onAddExpense: onAddExpense,
              onTransferFunds: onTransferFunds,
              onAdjustBudget: onAdjustBudget,
            ),
            const SizedBox(height: 24),
            _WideAITip(
              controller: controller,
              onAnalyze: onAnalyzeTrends,
            ),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WideWeeklyFlow(controller: controller),
                const SizedBox(height: 24),
                _WideTransactionsTable(
                  controller: controller,
                  onViewAll: onViewAllTx,
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WideAccountsPanel(
                  controller: controller,
                  onAddAccount: onAddAccount,
                ),
                const SizedBox(height: 24),
                _WideQuickActions(
                  onAddExpense: onAddExpense,
                  onTransferFunds: onTransferFunds,
                  onAdjustBudget: onAdjustBudget,
                ),
                const SizedBox(height: 24),
                _WideAITip(
                  controller: controller,
                  onAnalyze: onAnalyzeTrends,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ── Wide Weekly Flow (bar chart) ───────────────────────────────────────────
class _WideWeeklyFlow extends StatelessWidget {
  final DashboardController controller;
  const _WideWeeklyFlow({required this.controller});

  static const _days = ['LUN', 'MAR', 'MIE', 'JUE', 'VIE', 'SAB', 'DOM'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _wideCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Flujo Semanal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1C),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Últimos 7 días',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1C1C),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down,
                        size: 18, color: Color(0xFF4A4455)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: Obx(() {
              final spots = controller.weeklySpots.toList();
              final hasMovement = spots.any((s) => s.y.abs() > 0);
              if (spots.isEmpty || !hasMovement) {
                return const Center(
                  child: Text(
                    'Sin movimientos esta semana',
                    style: TextStyle(color: Color(0xFF7B7487)),
                  ),
                );
              }
              return BarChart(_barData(spots));
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days
                .map((d) => Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7B7487),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  BarChartData _barData(List<FlSpot> spots) {
    final maxY = spots
            .map((s) => s.y.abs())
            .fold<double>(0, (a, b) => a > b ? a : b) *
        1.2;
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY == 0 ? 1 : maxY,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => const Color(0xFF1A1C1C),
          getTooltipItem: (group, _, rod, __) => BarTooltipItem(
            CurrencyUtils.formatInDisplayCurrency(
              rod.toY,
              Get.find<DashboardController>().currency.value,
            ),
            const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      barGroups: spots.map((s) {
        final y = s.y.abs();
        return BarChartGroupData(
          x: s.x.toInt(),
          barRods: [
            BarChartRodData(
              toY: y == 0 ? maxY * 0.05 : y,
              color: AppTheme.primary.withValues(alpha: 0.18),
              width: 28,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ── Wide Transactions Table ────────────────────────────────────────────────
class _WideTransactionsTable extends StatelessWidget {
  final DashboardController controller;
  final VoidCallback onViewAll;

  const _WideTransactionsTable({
    required this.controller,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _wideCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimos Movimientos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1C),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onViewAll,
                  child: const Text(
                    'Ver todos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final txs = controller.recentTransactions;
            if (txs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.receipt_outlined,
                          size: 32, color: Color(0xFF7B7487)),
                      SizedBox(height: 8),
                      Text(
                        'No hay movimientos recientes',
                        style: TextStyle(color: Color(0xFF7B7487)),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: [
                _tableHeader(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: DashboardView._wideOutline,
                ),
                for (var i = 0; i < txs.length; i++) ...[
                  _tableRow(txs[i]),
                  if (i < txs.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color:
                          DashboardView._wideOutline.withValues(alpha: 0.6),
                    ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF4A4455),
      letterSpacing: 0.8,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('CONCEPTO', style: style)),
          Expanded(flex: 2, child: Text('CATEGORÍA', style: style)),
          Expanded(flex: 2, child: Text('FECHA', style: style)),
          Expanded(
            flex: 2,
            child: Text(
              'MONTO',
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(Transaction tx) {
    final isIncome = tx.type == 'income';
    final isOpening = tx.type == 'opening_balance';
    final amountColor =
        isIncome || isOpening ? DashboardView._emerald600 : DashboardView._rose600;
    final sign = (isIncome || isOpening) ? '+' : '-';
    final IconData icon;
    final Color iconColor;
    final Color iconBg;
    if (isOpening) {
      icon = Icons.account_balance_wallet_rounded;
      iconColor = const Color(0xFF4A4455);
      iconBg = const Color(0xFFEEEEEE);
    } else if (isIncome) {
      icon = Icons.payments_outlined;
      iconColor = DashboardView._emerald600;
      iconBg = DashboardView._emerald50;
    } else {
      icon = Icons.shopping_bag_outlined;
      iconColor = AppTheme.primary;
      iconBg = AppTheme.primary.withValues(alpha: 0.1);
    }

    final category = tx.category?.name ?? (isIncome ? 'Ingreso' : 'General');
    final categoryColor = isIncome
        ? DashboardView._emerald600
        : const Color(0xFF4A4455);
    final categoryBg = isIncome
        ? DashboardView._emerald50
        : const Color(0xFFF3F3F4);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tx.concept.isEmpty ? 'Sin concepto' : tx.concept,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C1C),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: categoryBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: categoryColor,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(tx.date),
              style: const TextStyle(fontSize: 13, color: Color(0xFF4A4455)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Obx(() {
              final amount = CurrencyUtils.formatInDisplayCurrency(
                tx.amount.abs(),
                controller.currency.value,
              );
              return Text(
                '$sign$amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
                textAlign: TextAlign.right,
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

// ── Wide Accounts Panel ────────────────────────────────────────────────────
class _WideAccountsPanel extends StatelessWidget {
  final DashboardController controller;
  final VoidCallback onAddAccount;

  const _WideAccountsPanel({
    required this.controller,
    required this.onAddAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _wideCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Mis Cuentas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final accounts = controller.accounts;
            if (accounts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Aún no tienes cuentas',
                    style: TextStyle(color: Color(0xFF7B7487)),
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final acc in accounts) ...[
                  _accountRow(acc),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }),
          const SizedBox(height: 12),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onAddAccount,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DashboardView._wideOutline,
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add_circle_outline,
                      size: 16,
                      color: Color(0xFF4A4455),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Añadir Nueva Cuenta',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4455),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountRow(Account acc) {
    final color = _accountColor(acc.type);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DashboardView._wideOutline),
            ),
            child: Icon(_accountIcon(acc.type), size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acc.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1C1C),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _accountTypeLabel(acc.type),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7B7487),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final ctrl = Get.find<DashboardController>();
            return Text(
              CurrencyUtils.formatInDisplayCurrency(
                acc.currentBalance,
                ctrl.currency.value,
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1C1C),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _accountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.payments_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'credit_card':
        return Icons.credit_card_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _accountColor(String type) {
    switch (type) {
      case 'cash':
        return AppTheme.primary;
      case 'bank':
        return const Color(0xFF5B598C);
      case 'credit_card':
        return AppTheme.primary;
      case 'investment':
        return DashboardView._emerald600;
      default:
        return const Color(0xFF7B7487);
    }
  }

  String _accountTypeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Efectivo';
      case 'bank':
        return 'Cuenta bancaria';
      case 'credit_card':
        return 'Tarjeta de crédito';
      case 'investment':
        return 'Inversión';
      default:
        return 'Otra cuenta';
    }
  }
}

// ── Wide Quick Actions ─────────────────────────────────────────────────────
class _WideQuickActions extends StatelessWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onTransferFunds;
  final VoidCallback onAdjustBudget;

  const _WideQuickActions({
    required this.onAddExpense,
    required this.onTransferFunds,
    required this.onAdjustBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _wideCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 20),
          _PrimaryAction(
            icon: Icons.add_rounded,
            label: 'Añadir Gasto',
            onTap: onAddExpense,
          ),
          const SizedBox(height: 12),
          _SecondaryAction(
            icon: Icons.swap_horiz_rounded,
            label: 'Transferir Fondos',
            onTap: onTransferFunds,
          ),
          const SizedBox(height: 12),
          _OutlineAction(
            icon: Icons.edit_note_rounded,
            label: 'Ajustar Presupuesto',
            onTap: onAdjustBudget,
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3DFFF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF181445), size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF181445),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF7B7487)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF1A1C1C), size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1C1C),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Wide AI Tip ────────────────────────────────────────────────────────────
class _WideAITip extends StatelessWidget {
  final DashboardController controller;
  final VoidCallback onAnalyze;

  const _WideAITip({required this.controller, required this.onAnalyze});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final insights = controller.insights;
      final tip = insights.isNotEmpty
          ? insights.first
          : 'Sigue registrando movimientos para recibir consejos personalizados de tu Coach AI.';
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: DashboardView._wideTipBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -4,
              right: -4,
              child: Icon(
                Icons.psychology_outlined,
                size: 64,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AI Smart Tip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tip,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 16),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onAnalyze,
                    child: Text(
                      'Analizar tendencias',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ── Shared wide card decoration ────────────────────────────────────────────
BoxDecoration _wideCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: DashboardView._wideOutline),
    boxShadow: [
      BoxShadow(
        color: AppTheme.primary.withValues(alpha: 0.05),
        blurRadius: 30,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
