import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_finanzas_mobile/core/theme/app_theme.dart';
import 'package:app_finanzas_mobile/core/widgets/navigation/custom_bottom_navigation_bar.dart';
import 'package:app_finanzas_mobile/core/widgets/navigation/custom_bottom_nav_bar_item.dart';
import '../controllers/home_controller.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../profile/views/profile_view.dart';
import '../../../routes/app_routes.dart';
import '../../stats/views/stats_view.dart';
import '../../ai_coach/views/ai_coach_view.dart';
import '../../settings/views/settings_view.dart';
import '../../savings/views/savings_view.dart';
import '../../budgets/views/budgets_view.dart';
import '../../debts/views/debts_view.dart';
import '../../incomes/views/incomes_view.dart';
import '../../subscriptions/views/subscriptions_view.dart';
import '../../expenses/views/expenses_view.dart';
import '../../transactions/views/transactions_view.dart';
import '../../events/views/events_view.dart';
import '../../workspaces/views/workspaces_view.dart';
import '../../recurring/views/recurring_view.dart';
import '../../../core/widgets/transactions/add_transaction_modal.dart';

class HomeView extends StatefulWidget {
  final int initialIndex;

  const HomeView({super.key, this.initialIndex = 0});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeController controller;
  bool _sidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();

    if (controller.currentIndex.value != widget.initialIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.currentIndex.value = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return _buildWideLayout(context);
        }
        return _buildNarrowLayout(context);
      },
    );
  }

  // ─── NARROW LAYOUT (móvil / tablet pequeño) ─────────────────────────────

  Widget _buildNarrowLayout(BuildContext context) {
    final navItems = [
      const CustomBottomNavBarItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
      const CustomBottomNavBarItem(icon: Icons.analytics_outlined, label: 'Stats'),
      const CustomBottomNavBarItem(icon: Icons.add, isAddButton: true),
      const CustomBottomNavBarItem(icon: Icons.chat_bubble_outline_rounded, label: 'Coach'),
      const CustomBottomNavBarItem(icon: Icons.settings_outlined, label: 'Ajustes'),
    ];

    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() => _buildCurrentPage()),
      drawer: _buildDrawer(context),
      bottomNavigationBar: Obx(
        () => CustomBottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeIndex,
          items: navItems,
        ),
      ),
    );
  }

  // ─── WIDE LAYOUT (web / tablet grande / desktop) ─────────────────────────

  Widget _buildWideLayout(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: _sidebarCollapsed ? 64 : 260,
            child: _buildPersistentSidebar(context),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFEDEAF6)),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const maxW = 1280.0;
                final hPad = constraints.maxWidth > maxW
                    ? (constraints.maxWidth - maxW) / 2.0
                    : 0.0;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Obx(() => _buildCurrentPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── CONTENIDO ACTUAL (compartido entre layouts) ────────────────────────

  Widget _buildCurrentPage() {
    var stackIndex = controller.currentIndex.value;
    if (stackIndex > 2) stackIndex -= 1;
    if (stackIndex < 0) stackIndex = 0;

    if (stackIndex <= 3) {
      return IndexedStack(
        index: stackIndex,
        children: const [
          DashboardView(),
          StatsView(),
          AICoachView(),
          SettingsView(),
        ],
      );
    }

    return switch (stackIndex) {
      4 => const SavingsView(),
      5 => const BudgetsView(),
      6 => const DebtsView(),
      7 => const IncomesView(),
      8 => const SubscriptionsView(),
      9 => const ExpensesView(),
      10 => const TransactionsView(),
      11 => const EventsView(),
      12 => const WorkspacesView(),
      13 => const RecurringView(),
      14 => const ProfileView(),
      _ => const DashboardView(),
    };
  }

  // ─── SIDEBAR PERSISTENTE (solo en wide layout) ──────────────────────────

  Widget _buildPersistentSidebar(BuildContext context) {
    final collapsed = _sidebarCollapsed;

    // Botón toggle reutilizable
    final toggleBtn = Tooltip(
      message: collapsed ? 'Expandir menú' : 'Colapsar menú',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AnimatedRotation(
              turns: collapsed ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: const Icon(
                Icons.keyboard_double_arrow_left_rounded,
                size: 16,
                color: Color(0xFF7B7487),
              ),
            ),
          ),
        ),
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFEDEAF6)),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────────
            if (collapsed)
              // Colapsado: solo el toggle centrado
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(child: toggleBtn),
              )
            else
              // Expandido: logo + nombre + toggle
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'FinVault',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    toggleBtn,
                  ],
                ),
              ),

            // ── Nombre organización (solo expandido) ──────────────────────
            if (!collapsed)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Obx(
                  () => MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/organizations'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.organizationName.value,
                              style: const TextStyle(
                                color: Color(0xFF7B7487),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.unfold_more_rounded,
                            size: 13,
                            color: Color(0xFF7B7487),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── Botón Nueva Transacción ────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: collapsed ? 10 : 12),
              child: collapsed
                  ? Tooltip(
                      message: 'Nueva Transacción',
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => Get.bottomSheet(
                            const AddTransactionModal(),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Icon(Icons.add_rounded, size: 20),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => Get.bottomSheet(
                        const AddTransactionModal(),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Nueva Transacción'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 12),
            const Divider(color: Color(0xFFEDEAF6), height: 1),

            // ── Items de navegación ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: collapsed ? 6 : 10,
                  vertical: 10,
                ),
                child: Obx(() {
                  final idx = controller.currentIndex.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // PRINCIPAL
                      if (!collapsed)
                        _SidebarSectionLabel(label: 'Principal'),
                      _SidebarEntry(
                        icon: Icons.grid_view_rounded,
                        label: 'Dashboard',
                        isActive: idx == HomeController.dashboardIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.dashboardIndex,
                      ),
                      _SidebarEntry(
                        icon: Icons.analytics_outlined,
                        label: 'Estadísticas',
                        isActive: idx == HomeController.statsIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.statsIndex,
                      ),
                      _SidebarEntry(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'AI Coach',
                        isActive: idx == HomeController.coachIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.coachIndex,
                      ),

                      SizedBox(height: collapsed ? 8 : 0),
                      if (!collapsed) _SidebarSectionLabel(label: 'Finanzas'),
                      if (collapsed) const Divider(color: Color(0xFFEDEAF6), height: 16),

                      _SidebarEntry(
                        icon: Icons.add_chart_rounded,
                        label: 'Ingresos',
                        isActive: idx == HomeController.incomesIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.incomesIndex,
                      ),
                      _SidebarEntry(
                        icon: Icons.receipt_long_rounded,
                        label: 'Gastos',
                        isActive: idx == HomeController.expensesIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.expensesIndex,
                      ),
                      _SidebarEntry(
                        icon: Icons.pie_chart_rounded,
                        label: 'Presupuestos',
                        isActive: idx == HomeController.budgetsIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.budgetsIndex,
                      ),
                      _SidebarEntry(
                        icon: Icons.savings_rounded,
                        label: 'Ahorros',
                        isActive: idx == HomeController.savingsIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.savingsIndex,
                      ),
                      _SidebarEntry(
                        icon: Icons.money_off_rounded,
                        label: 'Deudas',
                        isActive: idx == HomeController.debtsIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.debtsIndex,
                      ),
                      _SidebarEntry(
                        icon: Icons.subscriptions_rounded,
                        label: 'Suscripciones',
                        isActive: idx == HomeController.subscriptionsIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.subscriptionsIndex,
                      ),

                      SizedBox(height: collapsed ? 8 : 0),
                      if (!collapsed) _SidebarSectionLabel(label: 'Herramientas'),
                      if (collapsed) const Divider(color: Color(0xFFEDEAF6), height: 16),

                      _SidebarEntry(
                        icon: Icons.receipt_long_outlined,
                        label: 'Transacciones',
                        isActive: idx == HomeController.transactionsIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.transactionsIndex,
                      ),
                      _SidebarEntry(
                        icon: Icons.repeat_rounded,
                        label: 'Recurrentes',
                        isActive: idx == HomeController.recurringIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.recurringIndex,
                      ),
                      _SidebarEntry(
                        icon: Icons.flight_takeoff_rounded,
                        label: 'Eventos',
                        isActive: idx == HomeController.eventsIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.eventsIndex,
                      ),
                      _SidebarEntry(
                        icon: Icons.workspaces_rounded,
                        label: 'Workspaces',
                        isActive: idx == HomeController.workspacesIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.workspacesIndex,
                      ),

                      SizedBox(height: collapsed ? 8 : 0),
                      if (!collapsed) _SidebarSectionLabel(label: 'Cuenta'),
                      if (collapsed) const Divider(color: Color(0xFFEDEAF6), height: 16),

                      _SidebarEntry(
                        icon: Icons.person_outline_rounded,
                        label: 'Mi Perfil',
                        isActive: idx == HomeController.profileIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.profileIndex,
                      ),
                      _SidebarEntry(
                        icon: Icons.business_rounded,
                        label: 'Organización',
                        isActive: false,
                        collapsed: collapsed,
                        onTap: () => Get.toNamed('/organization-details'),
                      ),
                      _SidebarEntry(
                        icon: Icons.settings_outlined,
                        label: 'Ajustes',
                        isActive: idx == HomeController.settingsIndex,
                        collapsed: collapsed,
                        onTap: () => controller.currentIndex.value = HomeController.settingsIndex,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── DRAWER (solo en narrow layout) ─────────────────────────────────────

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Color(0xFFEDEAF6)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Organización',
                        style: TextStyle(
                          color: Color(0xFF7B7487),
                          fontSize: 12,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.back();
                          Get.toNamed('/organizations');
                        },
                        child: Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: Text(
                                  controller.organizationName.value,
                                  style: const TextStyle(
                                    color: Color(0xFF1A1C1C),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF7B7487),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.business_rounded,
            label: 'Gestionar Organización',
            onTap: () {
              Get.back();
              Get.toNamed('/organization-details');
            },
          ),
          const Divider(color: Color(0xFFEDEAF6), height: 1),
          _DrawerItem(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            onTap: () {
              controller.changeIndex(0);
              Get.back();
            },
          ),
          _DrawerItem(
            icon: Icons.savings_rounded,
            label: 'Mis Ahorros',
            onTap: () {
              controller.showSavings();
              Get.back();
            },
          ),
          _DrawerItem(
            icon: Icons.pie_chart_rounded,
            label: 'Presupuestos',
            onTap: () {
              controller.currentIndex.value = HomeController.budgetsIndex;
              Get.back();
            },
          ),
          _DrawerItem(
            icon: Icons.receipt_long_rounded,
            label: 'Gestión de Gastos',
            onTap: () {
              controller.currentIndex.value = HomeController.expensesIndex;
              Get.back();
            },
          ),
          _DrawerItem(
            icon: Icons.money_off_rounded,
            label: 'Control de Deudas',
            onTap: () {
              controller.currentIndex.value = HomeController.debtsIndex;
              Get.back();
            },
          ),
          _DrawerItem(
            icon: Icons.add_chart_rounded,
            label: 'Gestión de Ingresos',
            onTap: () {
              controller.currentIndex.value = HomeController.incomesIndex;
              Get.back();
            },
          ),
          _DrawerItem(
            icon: Icons.subscriptions_rounded,
            label: 'Suscripciones',
            onTap: () {
              controller.currentIndex.value = HomeController.subscriptionsIndex;
              Get.back();
            },
          ),
          _DrawerItem(
            icon: Icons.repeat_rounded,
            label: 'Pagos Recurrentes',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.recurring);
            },
          ),
          const Divider(color: Color(0xFFEDEAF6), height: 1),
          _DrawerItem(
            icon: Icons.receipt_long_outlined,
            label: 'Transacciones',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.transactions);
            },
          ),
          _DrawerItem(
            icon: Icons.flight_takeoff_rounded,
            label: 'Eventos',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.events);
            },
          ),
          _DrawerItem(
            icon: Icons.workspaces_rounded,
            label: 'Workspaces',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.workspaces);
            },
          ),
          _DrawerItem(
            icon: Icons.person_outline_rounded,
            label: 'Mi Perfil',
            onTap: () {
              Get.back();
              Get.to(() => const ProfileView());
            },
          ),
          const Divider(color: Color(0xFFEDEAF6), height: 1),
          _DrawerItem(
            icon: Icons.settings_rounded,
            label: 'Ajustes',
            onTap: () {
              controller.changeIndex(4);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

// ─── SIDEBAR SECTION LABEL ────────────────────────────────────────────────

class _SidebarSectionLabel extends StatelessWidget {
  final String label;
  const _SidebarSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF7B7487),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

// ─── SIDEBAR ENTRY (web/desktop) ──────────────────────────────────────────

class _SidebarEntry extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarEntry({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isActive ? AppTheme.primary : const Color(0xFF7B7487);
    final bg =
        isActive ? const Color(0xFFEDE9FE) : Colors.transparent;
    final textColor = isActive
        ? AppTheme.primary
        : const Color(0xFF4A4455);

    final tile = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 2),
          height: 38,
          padding: collapsed
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: collapsed
              ? Center(child: Icon(icon, size: 19, color: iconColor))
              : Row(
                  children: [
                    Icon(icon, size: 19, color: iconColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isActive)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );

    if (collapsed) {
      return Tooltip(
        message: label,
        preferBelow: false,
        child: tile,
      );
    }
    return tile;
  }
}

// ─── DRAWER ITEM (móvil) ──────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF7B7487)),
        title: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A1C1C),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
