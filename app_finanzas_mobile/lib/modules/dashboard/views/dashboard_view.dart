import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/models/finance/account.dart';
import '../../../data/models/finance/transaction.dart';
import '../../../data/models/workspace.dart';
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
                  if (spots.isEmpty) {
                    return const Center(
                      child: Text(
                        'Sin datos esta semana',
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
