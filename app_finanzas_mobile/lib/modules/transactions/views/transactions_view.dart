import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/services/directus_service.dart';
import '../controllers/transactions_controller.dart';
import 'add_transaction_view.dart';

// ════════════════════════════════════════════════════════════════════════
// TransactionsView — light fintech 1:1 con doc/diseno/Paginas internas 1
// Mobile: search + chips + cards agrupadas por fecha + FAB.
// Desktop: title + toolbar + filters sidebar + table.
// ════════════════════════════════════════════════════════════════════════

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  static const _desktopBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TransactionsController>()) {
      Get.put(TransactionsController());
    }
    return Container(
      color: const Color(0xFFF8FAFC),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _desktopBreakpoint) {
            return _DesktopTransactions(controller: controller);
          }
          return _MobileTransactions(controller: controller);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// MOBILE
// ─────────────────────────────────────────────────────────────────────────

class _MobileTransactions extends StatelessWidget {
  final TransactionsController controller;
  const _MobileTransactions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _MobileHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.refreshTransactions,
                  color: AppTheme.primary,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      _SearchAndFilterBar(controller: controller),
                      const SizedBox(height: 16),
                      _TypeFilterChips(controller: controller),
                      const SizedBox(height: 16),
                      _PeriodNav(controller: controller),
                      const SizedBox(height: 12),
                      _SummaryRow(controller: controller),
                      const SizedBox(height: 20),
                      ..._buildGroupedTransactions(),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
        Positioned(
          right: 24,
          bottom: 24,
          child: _Fab(
            onPressed: () {
              controller.clearForm();
              Get.to(() => const AddTransactionView());
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedTransactions() {
    final tx = controller.filteredTransactions;
    if (tx.isEmpty) {
      return [const _EmptyState()];
    }

    final groups = _groupByDate(tx);
    final widgets = <Widget>[];
    groups.forEach((label, items) {
      widgets.add(_DateSectionHeader(label: label));
      widgets.add(const SizedBox(height: 8));
      for (final item in items) {
        widgets.add(_TransactionRow(tx: item, controller: controller));
        widgets.add(const SizedBox(height: 8));
      }
      widgets.add(const SizedBox(height: 16));
    });
    return widgets;
  }
}

class _MobileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEAF6)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Transacciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Get.find<TransactionsController>().exportToCsv(),
            icon: const Icon(
              Icons.file_download_outlined,
              color: Color(0xFF7B7487),
              size: 22,
            ),
            tooltip: 'Exportar CSV',
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  final TransactionsController controller;
  const _SearchAndFilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE2E0F7)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: Color(0xFF7B7487),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => controller.searchQuery.value = v,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1C1C),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Buscar transacciones…',
                      hintStyle: TextStyle(
                        color: Color(0xFF7B7487),
                        fontSize: 14,
                      ),
                      isCollapsed: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEDEAF6)),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.tune,
              color: Color(0xFF7B7487),
              size: 20,
            ),
            onPressed: () {
              // TODO: open filter sheet
            },
          ),
        ),
      ],
    );
  }
}

class _TypeFilterChips extends StatelessWidget {
  final TransactionsController controller;
  const _TypeFilterChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(null, 'Todos'),
          _chip('income', 'Ingresos'),
          _chip('expense', 'Gastos'),
          _chip('transfer', 'Transferencias'),
        ],
      ),
    );
  }

  Widget _chip(String? value, String label) {
    return Obx(() {
      final selected = controller.filterType.value == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => controller.filterType.value = value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : const Color(0xFFE3DFFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF181445),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _PeriodNav extends StatelessWidget {
  final TransactionsController controller;
  const _PeriodNav({required this.controller});

  @override
  Widget build(BuildContext context) {
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
          dateText =
              '${DateFormat('dd MMM').format(start)} – ${DateFormat('dd MMM').format(end)}';
          break;
        case 'year':
          dateText = DateFormat('yyyy').format(date);
          break;
        default:
          dateText = DateFormat('MMMM yyyy', 'es').format(date);
      }
      return Row(
        children: [
          _navBtn(Icons.chevron_left_rounded, controller.previousPeriod),
          Expanded(
            child: Center(
              child: Text(
                dateText.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7B7487),
                ),
              ),
            ),
          ),
          _navBtn(Icons.chevron_right_rounded, controller.nextPeriod),
        ],
      );
    });
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Icon(icon, color: const Color(0xFF7B7487), size: 22),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final TransactionsController controller;
  const _SummaryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.totalAmount;
      final positive = total >= 0;
      return Center(
        child: Column(
          children: [
            const Text(
              'BALANCE DEL PERÍODO',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7B7487),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              CurrencyUtils.formatInDisplayCurrency(total.abs(), 'USD'),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color:
                    positive ? AppTheme.accentGreen : AppTheme.accentRed,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _DateSectionHeader extends StatelessWidget {
  final String label;
  const _DateSectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF7B7487),
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction tx;
  final TransactionsController controller;
  const _TransactionRow({required this.tx, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income' || tx.type == 'opening_balance';
    final amountColor =
        isIncome ? AppTheme.accentGreen : AppTheme.accentRed;
    final accent = isIncome ? AppTheme.accentGreen : AppTheme.primary;
    final iconData = _iconForTx(tx);

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: _swipeBg(),
      onDismissed: (_) => controller.deleteTransaction(tx.id),
      confirmDismiss: (_) async {
        if (tx.id.startsWith('opening-')) return false;
        return true;
      },
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEAF6)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.10),
              ),
              child: Icon(iconData, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tx.concept,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C1C),
                    ),
                  ),
                  Text(
                    tx.category?.name ?? 'Sin categoría',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7B7487),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${CurrencyUtils.formatInDisplayCurrency(tx.amount, tx.currency)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _swipeBg() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: AppTheme.accentRed,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }
}

class _Fab extends StatelessWidget {
  final VoidCallback onPressed;
  const _Fab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEDE9FE),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin transacciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Crea tu primera transacción con el botón +',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF7B7487),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// DESKTOP
// ─────────────────────────────────────────────────────────────────────────

class _DesktopTransactions extends StatelessWidget {
  final TransactionsController controller;
  const _DesktopTransactions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DesktopHeader(controller: controller),
              const SizedBox(height: 24),
              _DesktopToolbar(controller: controller),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 240,
                      child: _FiltersSidebar(controller: controller),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _DesktopTable(controller: controller),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  final TransactionsController controller;
  const _DesktopHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transacciones',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Color(0xFF1A1C1C),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Lista unificada de movimientos en tus cuentas.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A4455),
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: controller.exportToCsv,
          icon: const Icon(Icons.download_rounded, size: 16),
          label: const Text('Export CSV'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary,
            side: const BorderSide(color: Color(0xFFE2E0F7)),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            controller.clearForm();
            Get.to(() => const AddTransactionView());
          },
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Nueva transacción'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopToolbar extends StatelessWidget {
  final TransactionsController controller;
  const _DesktopToolbar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 400,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E0F7)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  size: 18,
                  color: Color(0xFF7B7487),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => controller.searchQuery.value = v,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1C1C),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Buscar por descripción, monto…',
                      hintStyle: TextStyle(
                        color: Color(0xFF7B7487),
                        fontSize: 14,
                      ),
                      isCollapsed: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        _periodChip(controller),
      ],
    );
  }

  Widget _periodChip(TransactionsController c) {
    return Obx(() {
      String label;
      switch (c.selectedPeriod.value) {
        case 'day':
          label = DateFormat('dd MMM yyyy', 'es').format(c.filterDate.value);
          break;
        case 'week':
          label = 'Esta semana';
          break;
        case 'year':
          label = DateFormat('yyyy').format(c.filterDate.value);
          break;
        default:
          label = DateFormat('MMM yyyy', 'es').format(c.filterDate.value);
      }
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E0F7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Color(0xFF7B7487),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.chevron_left,
                size: 18,
                color: Color(0xFF7B7487),
              ),
              onPressed: c.previousPeriod,
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.chevron_right,
                size: 18,
                color: Color(0xFF7B7487),
              ),
              onPressed: c.nextPeriod,
            ),
          ],
        ),
      );
    });
  }
}

class _FiltersSidebar extends StatelessWidget {
  final TransactionsController controller;
  const _FiltersSidebar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEAF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1C1C),
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.filterType.value = null;
                  controller.filterCategoryId.value = null;
                  controller.searchQuery.value = '';
                },
                child: const Text(
                  'Limpiar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEDEAF6), height: 1),
          const SizedBox(height: 16),

          const Text(
            'TIPO',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7B7487),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Column(
                children: [
                  _typeRadio(null, 'Todos'),
                  _typeRadio('income', 'Ingresos'),
                  _typeRadio('expense', 'Egresos'),
                ],
              )),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFFEDEAF6), height: 1),
          const SizedBox(height: 16),

          const Text(
            'CATEGORÍAS',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7B7487),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.categories.isEmpty) {
              return const Text(
                'Sin categorías',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7B7487),
                ),
              );
            }
            return Column(
              children: controller.categories.take(6).map((c) {
                return _categoryCheckbox(c);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _typeRadio(String? value, String label) {
    final selected = controller.filterType.value == value;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.filterType.value = value,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppTheme.primary
                        : const Color(0xFFE2E0F7),
                    width: 2,
                  ),
                  color: selected ? AppTheme.primary : Colors.transparent,
                ),
                child: selected
                    ? const Center(
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF1A1C1C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryCheckbox(Category c) {
    final selected = controller.filterCategoryId.value == c.id;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.changeCategoryFilter(selected ? null : c.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: selected
                        ? AppTheme.primary
                        : const Color(0xFFE2E0F7),
                    width: 2,
                  ),
                  color: selected ? AppTheme.primary : Colors.transparent,
                ),
                child: selected
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF1A1C1C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopTable extends StatelessWidget {
  final TransactionsController controller;
  const _DesktopTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEAF6)),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(48),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }
        final rows = controller.filteredTransactions;
        if (rows.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(64),
            child: _EmptyState(),
          );
        }
        return Column(
          children: [
            const _TableHeader(),
            ...rows.map((tx) => _TableRow(tx: tx, controller: controller)),
          ],
        );
      }),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEAF6)),
        ),
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 100,
            child: _Th('Fecha'),
          ),
          Expanded(flex: 3, child: _Th('Descripción')),
          Expanded(flex: 2, child: _Th('Categoría')),
          Expanded(flex: 2, child: _Th('Cuenta')),
          SizedBox(
            width: 120,
            child: _Th('Monto', right: true),
          ),
        ],
      ),
    );
  }
}

class _Th extends StatelessWidget {
  final String text;
  final bool right;
  const _Th(this.text, {this.right = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: right ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: Color(0xFF7B7487),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final Transaction tx;
  final TransactionsController controller;
  const _TableRow({required this.tx, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income' || tx.type == 'opening_balance';
    final accent = isIncome ? AppTheme.accentGreen : AppTheme.primary;
    final iconData = _iconForTx(tx);
    final amountColor =
        isIncome ? AppTheme.accentGreen : const Color(0xFF1A1C1C);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {},
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFEDEAF6)),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  DateFormat('dd MMM yy', 'es').format(tx.date),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7B7487),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.10),
                      ),
                      child: Icon(iconData, size: 16, color: accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tx.concept,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: _CategoryChip(
                  label: tx.category?.name ?? 'Sin categoría',
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Cuenta principal',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7B7487),
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  '${isIncome ? '+ ' : '- '}${CurrencyUtils.formatInDisplayCurrency(tx.amount, tx.currency)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E2).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A4455),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// helpers
// ─────────────────────────────────────────────────────────────────────────

IconData _iconForTx(Transaction tx) {
  final name = (tx.category?.name ?? tx.concept).toLowerCase();
  if (tx.type == 'income' || tx.type == 'opening_balance') {
    if (name.contains('salar') || name.contains('nómin') || name.contains('nomin')) {
      return Icons.account_balance_wallet_rounded;
    }
    return Icons.attach_money_rounded;
  }
  if (name.contains('comida') || name.contains('food') || name.contains('restaur')) return Icons.restaurant_rounded;
  if (name.contains('transp') || name.contains('uber') || name.contains('taxi') || name.contains('auto')) return Icons.directions_car_rounded;
  if (name.contains('compra') || name.contains('shop') || name.contains('zara') || name.contains('ropa')) return Icons.shopping_bag_rounded;
  if (name.contains('mercado') || name.contains('super')) return Icons.shopping_cart_rounded;
  if (name.contains('luz') || name.contains('energ') || name.contains('servic') || name.contains('intern') || name.contains('factur')) return Icons.bolt_rounded;
  if (name.contains('café') || name.contains('cafe') || name.contains('bar')) return Icons.local_cafe_rounded;
  if (name.contains('ocio') || name.contains('movie') || name.contains('cine')) return Icons.movie_rounded;
  if (name.contains('viaje') || name.contains('avion') || name.contains('hotel')) return Icons.flight_takeoff_rounded;
  if (name.contains('hogar') || name.contains('casa') || name.contains('renta') || name.contains('vivien')) return Icons.home_rounded;
  if (name.contains('salud') || name.contains('medic') || name.contains('hosp')) return Icons.local_hospital_rounded;
  return Icons.receipt_long_rounded;
}

Map<String, List<Transaction>> _groupByDate(List<Transaction> items) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final weekStart = today.subtract(Duration(days: today.weekday - 1));

  final groups = <String, List<Transaction>>{};
  for (final tx in items) {
    final d = DateTime(tx.date.year, tx.date.month, tx.date.day);
    String label;
    if (d == today) {
      label = 'Hoy';
    } else if (d == yesterday) {
      label = 'Ayer';
    } else if (d.isAfter(weekStart) ||
        d.isAtSameMomentAs(weekStart)) {
      label = 'Esta semana';
    } else {
      label = DateFormat('MMMM yyyy', 'es').format(d);
    }
    groups.putIfAbsent(label, () => []).add(tx);
  }
  return groups;
}
