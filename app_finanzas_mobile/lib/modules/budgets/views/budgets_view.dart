import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/services/directus_service.dart';
import '../controllers/budgets_controller.dart';

// ════════════════════════════════════════════════════════════════════════
// BudgetsView — light fintech 1:1 con doc/diseno/Paginas internas 1
// Mobile: alert + summary card con ring + cards de categorías.
// Desktop: alert banner + KPIs 4-col + tabla detallada.
// ════════════════════════════════════════════════════════════════════════

class BudgetsView extends GetView<BudgetsController> {
  const BudgetsView({super.key});

  static const _desktopBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BudgetsController>()) {
      Get.put(BudgetsController());
    }
    return Container(
      color: const Color(0xFFF8FAFC),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _desktopBreakpoint) {
            return _DesktopBudgets(controller: controller);
          }
          return _MobileBudgets(controller: controller);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Helpers compartidos
// ─────────────────────────────────────────────────────────────────────────

class _BudgetStats {
  final double totalLimit;
  final double totalSpent;
  final int alertsCount;
  final List<Budget> overBudget;
  final List<Budget> warnings;

  const _BudgetStats({
    required this.totalLimit,
    required this.totalSpent,
    required this.alertsCount,
    required this.overBudget,
    required this.warnings,
  });

  double get remaining => totalLimit - totalSpent;
  double get percentUsed =>
      totalLimit > 0 ? (totalSpent / totalLimit * 100).clamp(0, 100) : 0;

  factory _BudgetStats.from(List<Budget> budgets) {
    double tl = 0;
    double ts = 0;
    final overs = <Budget>[];
    final warns = <Budget>[];
    for (final b in budgets) {
      tl += b.limit;
      ts += b.spent;
      final pct = b.limit > 0 ? b.spent / b.limit : 0;
      if (pct > 1) {
        overs.add(b);
      } else if (pct >= 0.9) {
        warns.add(b);
      }
    }
    return _BudgetStats(
      totalLimit: tl,
      totalSpent: ts,
      alertsCount: overs.length + warns.length,
      overBudget: overs,
      warnings: warns,
    );
  }
}

class _BudgetVisual {
  final Color accent;
  final Color softBg;
  final String? statusLabel;
  final Color? statusColor;
  final IconData icon;

  const _BudgetVisual({
    required this.accent,
    required this.softBg,
    required this.icon,
    this.statusLabel,
    this.statusColor,
  });

  factory _BudgetVisual.from(Budget b) {
    final pct = b.limit > 0 ? b.spent / b.limit : 0;
    final icon = _iconForBudget(b.name);
    if (pct > 1) {
      return _BudgetVisual(
        accent: AppTheme.accentRed,
        softBg: AppTheme.accentRed.withValues(alpha: 0.10),
        icon: icon,
        statusLabel: 'Exceso',
        statusColor: AppTheme.accentRed,
      );
    }
    if (pct >= 0.9) {
      return _BudgetVisual(
        accent: AppTheme.accentWarning,
        softBg: AppTheme.accentWarning.withValues(alpha: 0.12),
        icon: icon,
      );
    }
    return _BudgetVisual(
      accent: AppTheme.primary,
      softBg: const Color(0xFFEDE9FE),
      icon: icon,
    );
  }
}

IconData _iconForBudget(String name) {
  final n = name.toLowerCase();
  if (n.contains('comid') || n.contains('food') || n.contains('alim')) {
    return Icons.restaurant_rounded;
  }
  if (n.contains('transp') || n.contains('auto')) {
    return Icons.directions_car_rounded;
  }
  if (n.contains('hogar') || n.contains('vivien') || n.contains('renta')) {
    return Icons.home_rounded;
  }
  if (n.contains('compra') || n.contains('ropa')) {
    return Icons.shopping_bag_rounded;
  }
  if (n.contains('ocio') || n.contains('entretenim') || n.contains('movie')) {
    return Icons.sports_esports_rounded;
  }
  if (n.contains('servic') || n.contains('luz') || n.contains('agua')) {
    return Icons.bolt_rounded;
  }
  if (n.contains('salud')) return Icons.local_hospital_rounded;
  if (n.contains('educ') || n.contains('estud')) return Icons.school_rounded;
  return Icons.pie_chart_rounded;
}

// ─────────────────────────────────────────────────────────────────────────
// MOBILE
// ─────────────────────────────────────────────────────────────────────────

class _MobileBudgets extends StatelessWidget {
  final BudgetsController controller;
  const _MobileBudgets({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _MobileHeader(onAdd: controller.showAddBudgetDialog),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }
                final budgets = controller.budgets.toList();
                final stats = _BudgetStats.from(budgets);
                return RefreshIndicator(
                  onRefresh: () => controller.loadBudgets(),
                  color: AppTheme.primary,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      if (stats.overBudget.isNotEmpty) ...[
                        _AlertBanner(
                          message:
                              'Has superado tu presupuesto de ${stats.overBudget.first.name} en ${CurrencyUtils.formatInDisplayCurrency((stats.overBudget.first.spent - stats.overBudget.first.limit).abs(), controller.currency)}.',
                        ),
                        const SizedBox(height: 16),
                      ],
                      _SummaryCard(stats: stats, currency: controller.currency),
                      const SizedBox(height: 24),
                      const _SmallLabel('CATEGORÍAS ACTIVAS'),
                      const SizedBox(height: 12),
                      if (budgets.isEmpty)
                        const _EmptyState()
                      else
                        ...budgets.map(
                          (b) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BudgetCard(
                              budget: b,
                              currency: controller.currency,
                              onTap: () => controller.editBudget(
                                b.id,
                                b.limit,
                                b.name,
                              ),
                              onDelete: () =>
                                  controller.deleteBudget(b.id, b.name),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 24,
          child: _FabExtended(
            label: 'Nuevo presupuesto',
            onPressed: controller.showAddBudgetDialog,
          ),
        ),
      ],
    );
  }
}

class _MobileHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _MobileHeader({required this.onAdd});

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
          const Text(
            'Presupuestos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0FB),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFEDEAF6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Este mes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4455),
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.expand_more_rounded,
                  size: 16,
                  color: Color(0xFF4A4455),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final String message;
  const _AlertBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.accentRed.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.accentRed,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF1A1C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _BudgetStats stats;
  final String currency;
  const _SummaryCard({required this.stats, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F0FB)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Gastado',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7B7487),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyUtils.formatInDisplayCurrency(
                        stats.totalSpent,
                        currency,
                      ),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Presupuesto',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7B7487),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyUtils.formatInDisplayCurrency(
                      stats.totalLimit,
                      currency,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1C1C),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ProgressRing(
            percent: stats.percentUsed,
            size: 130,
            strokeWidth: 12,
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFEDEAF6), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  'Restante',
                  CurrencyUtils.formatInDisplayCurrency(
                    stats.remaining,
                    currency,
                  ),
                ),
              ),
              Expanded(
                child: _miniStat(
                  'Alertas',
                  stats.alertsCount.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF7B7487),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1C),
          ),
        ),
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double percent; // 0..100
  final double size;
  final double strokeWidth;
  const _ProgressRing({
    required this.percent,
    required this.size,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              percent: percent / 100,
              strokeWidth: strokeWidth,
              trackColor: const Color(0xFFF1F0FB),
              valueColor: AppTheme.primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const Text(
                'utilizado',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7B7487),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final double strokeWidth;
  final Color trackColor;
  final Color valueColor;

  _RingPainter({
    required this.percent,
    required this.strokeWidth,
    required this.trackColor,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final valuePaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * math.pi * percent.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent ||
      old.trackColor != trackColor ||
      old.valueColor != valueColor;
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _BudgetCard({
    required this.budget,
    required this.currency,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final visual = _BudgetVisual.from(budget);
    final pct = budget.limit > 0
        ? (budget.spent / budget.limit).clamp(0.0, 1.0)
        : 0.0;
    final excess = budget.spent - budget.limit;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F0FB)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: visual.softBg,
                    ),
                    child: Icon(visual.icon, color: visual.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1C1C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${CurrencyUtils.formatInDisplayCurrency(budget.spent, currency)} de ${CurrencyUtils.formatInDisplayCurrency(budget.limit, currency)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7B7487),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (visual.statusLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: visual.statusColor!.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: visual.statusColor!.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Text(
                        visual.statusLabel!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: visual.statusColor,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFF7B7487),
                      ),
                      onPressed: onDelete,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF1F0FB),
                  valueColor: AlwaysStoppedAnimation<Color>(visual.accent),
                ),
              ),
              if (excess > 0) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '-${CurrencyUtils.formatInDisplayCurrency(excess, currency)} superado',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentRed,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  final String text;
  const _SmallLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
          color: Color(0xFF7B7487),
        ),
      ),
    );
  }
}

class _FabExtended extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _FabExtended({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(999),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEDE9FE),
              ),
              child: const Icon(
                Icons.pie_chart_outline_rounded,
                size: 32,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Sin presupuestos',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Crea tu primer presupuesto y controla tus gastos.',
              textAlign: TextAlign.center,
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

class _DesktopBudgets extends StatelessWidget {
  final BudgetsController controller;
  const _DesktopBudgets({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(64),
                child: Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.primary),
                ),
              );
            }
            final budgets = controller.budgets.toList();
            final stats = _BudgetStats.from(budgets);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (stats.overBudget.isNotEmpty) ...[
                  _DesktopAlert(
                    overName: stats.overBudget.first.name,
                    overPct: stats.overBudget.first.limit > 0
                        ? ((stats.overBudget.first.spent -
                                    stats.overBudget.first.limit) /
                                stats.overBudget.first.limit *
                                100)
                            .clamp(0, 999)
                        : 0,
                  ),
                  const SizedBox(height: 20),
                ],
                _DesktopHeader(onAdd: controller.showAddBudgetDialog),
                const SizedBox(height: 24),
                _KpiGrid(stats: stats, currency: controller.currency),
                const SizedBox(height: 24),
                _DetailTable(
                  budgets: budgets,
                  currency: controller.currency,
                  onEdit: (b) => controller.editBudget(b.id, b.limit, b.name),
                  onDelete: (b) => controller.deleteBudget(b.id, b.name),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _DesktopAlert extends StatelessWidget {
  final String overName;
  final double overPct;
  const _DesktopAlert({required this.overName, required this.overPct});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentRed.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.accentRed.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentRed.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.accentRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerta de Presupuesto: $overName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentRed,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Has superado el presupuesto en un ${overPct.toStringAsFixed(0)}%. Te sugerimos revisar tus gastos.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A4455),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _DesktopHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Presupuestos',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Color(0xFF1A1C1C),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Monitorea y optimiza tus gastos mensuales.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A4455),
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.calendar_today_outlined, size: 16),
          label: const Text('Este mes'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1A1C1C),
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
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Nuevo Presupuesto'),
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

class _KpiGrid extends StatelessWidget {
  final _BudgetStats stats;
  final String currency;
  const _KpiGrid({required this.stats, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _KpiCard(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Presupuesto Total',
            value: CurrencyUtils.formatInDisplayCurrency(
                stats.totalLimit, currency),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _KpiCard(
            icon: Icons.shopping_cart_rounded,
            label: 'Gastado (mes actual)',
            value: CurrencyUtils.formatInDisplayCurrency(
                stats.totalSpent, currency),
            progressPercent: stats.percentUsed / 100,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _KpiCard(
            icon: Icons.savings_rounded,
            label: 'Restante disponible',
            value: CurrencyUtils.formatInDisplayCurrency(
              stats.remaining,
              currency,
            ),
            valueColor: stats.remaining >= 0
                ? AppTheme.accentGreen
                : AppTheme.accentRed,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _KpiCard(
            icon: Icons.notifications_active_rounded,
            iconBg: AppTheme.accentRed.withValues(alpha: 0.10),
            iconColor: AppTheme.accentRed,
            label: 'Alertas activas',
            value: stats.alertsCount.toString(),
            valueColor: AppTheme.accentRed,
            border: AppTheme.accentRed.withValues(alpha: 0.20),
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color? iconBg;
  final Color? iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? border;
  final double? progressPercent;
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    this.iconBg,
    this.iconColor,
    this.valueColor,
    this.border,
    this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border ?? const Color(0xFFEDEAF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBg ?? const Color(0xFFF1F0FB),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7B7487),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: valueColor ?? const Color(0xFF1A1C1C),
            ),
          ),
          if (progressPercent != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progressPercent!.clamp(0, 1),
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F0FB),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailTable extends StatelessWidget {
  final List<Budget> budgets;
  final String currency;
  final void Function(Budget) onEdit;
  final void Function(Budget) onDelete;
  const _DetailTable({
    required this.budgets,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEAF6)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Detalle por Categoría',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1C1C),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEDEAF6), height: 1),
          if (budgets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(48),
              child: _EmptyState(),
            )
          else ...[
            const _TableHeader(),
            ...budgets.map(
              (b) => _DesktopTableRow(
                budget: b,
                currency: currency,
                onEdit: () => onEdit(b),
                onDelete: () => onDelete(b),
              ),
            ),
          ],
        ],
      ),
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
          Expanded(flex: 3, child: _Th('Categoría')),
          Expanded(flex: 2, child: _Th('Presupuesto')),
          Expanded(flex: 2, child: _Th('Gastado')),
          Expanded(flex: 2, child: _Th('Restante')),
          Expanded(flex: 3, child: _Th('Progreso')),
          SizedBox(width: 80, child: _Th('', right: true)),
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

class _DesktopTableRow extends StatelessWidget {
  final Budget budget;
  final String currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _DesktopTableRow({
    required this.budget,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final visual = _BudgetVisual.from(budget);
    final pct = budget.limit > 0
        ? (budget.spent / budget.limit).clamp(0.0, 1.0)
        : 0.0;
    final remaining = budget.limit - budget.spent;
    final overBudget = remaining < 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onEdit,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFEDEAF6)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: visual.softBg,
                      ),
                      child: Icon(visual.icon, color: visual.accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            budget.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1C1C),
                            ),
                          ),
                          if (overBudget)
                            Row(
                              children: const [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 12,
                                  color: AppTheme.accentRed,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Sobregiro',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.accentRed,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  CurrencyUtils.formatInDisplayCurrency(
                    budget.limit,
                    currency,
                  ),
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF1A1C1C),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  CurrencyUtils.formatInDisplayCurrency(
                    budget.spent,
                    currency,
                  ),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: overBudget
                        ? AppTheme.accentRed
                        : const Color(0xFF1A1C1C),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${overBudget ? '-' : ''}${CurrencyUtils.formatInDisplayCurrency(remaining.abs(), currency)}',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: overBudget
                        ? AppTheme.accentRed
                        : const Color(0xFF4A4455),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F0FB),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(visual.accent),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFF7B7487),
                      ),
                      onPressed: onEdit,
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFF7B7487),
                      ),
                      onPressed: onDelete,
                      tooltip: 'Eliminar',
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
