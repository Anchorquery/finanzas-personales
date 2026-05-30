import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/services/directus_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';

// ════════════════════════════════════════════════════════════════════════
// Controller
// ════════════════════════════════════════════════════════════════════════

class StatsController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController = Get.find();

  final isLoading = true.obs;
  final categoryExpenses = <Map<String, dynamic>>[].obs;
  final monthlyTrend = <Map<String, dynamic>>[].obs;
  final totalExpenseThisMonth = 0.0.obs;
  final totalIncomeThisMonth = 0.0.obs;
  final period = 'month'.obs; // 'week' | 'month' | 'year'

  String get currency =>
      _workspacesController.activeWorkspace?.currency ?? 'USD';

  double get netFlow => totalIncomeThisMonth.value - totalExpenseThisMonth.value;

  @override
  void onInit() {
    super.onInit();
    loadStats();
    ever(_workspacesController.activeWorkspaceRx, (_) => loadStats());
    ever(_directusService.dataVersion, (_) => loadStats());
  }

  void changePeriod(String p) {
    period.value = p;
    loadStats();
  }

  Future<void> loadStats() async {
    final wsId = _workspacesController.activeWorkspace?.id;
    if (wsId == null) return;

    isLoading.value = true;
    try {
      final now = DateTime.now();
      late DateTime startDate;
      late DateTime endDate;
      switch (period.value) {
        case 'week':
          final startOfWeek =
              now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(
              startOfWeek.year, startOfWeek.month, startOfWeek.day);
          endDate = startDate
              .add(const Duration(days: 7))
              .subtract(const Duration(seconds: 1));
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      }

      final transactions = await _directusService.getTransactions(
        limit: 500,
        startDate: startDate,
        endDate: endDate,
        workspaceId: wsId,
      );

      final Map<String, double> catTotals = {};
      final Map<String, String> catNames = {};
      double totalExp = 0;
      double totalInc = 0;

      for (final tx in transactions) {
        if (tx.type == 'expense') {
          totalExp += tx.amount;
          final catId = tx.category?.id ?? 'other';
          final catName = tx.category?.name ?? 'Otros';
          catTotals[catId] = (catTotals[catId] ?? 0) + tx.amount;
          catNames[catId] = catName;
        } else {
          totalInc += tx.amount;
        }
      }

      totalExpenseThisMonth.value = totalExp;
      totalIncomeThisMonth.value = totalInc;

      final sorted = catTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      categoryExpenses.value = sorted
          .map((e) => {
                'id': e.key,
                'name': catNames[e.key] ?? 'Otros',
                'amount': e.value,
                'percentage':
                    totalExp > 0 ? (e.value / totalExp * 100) : 0.0,
              })
          .toList();

      // Trend (last 6 months) reused even in week/year for now.
      final trend = <Map<String, dynamic>>[];
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(month.year, month.month + 1, 0);
        try {
          final summary = await _directusService.getDashboardSummary(
            startDate: month,
            endDate: monthEnd,
            workspaceId: wsId,
          );
          trend.add({
            'month': month,
            'income': summary.monthlyIncome,
            'expense': summary.monthlyExpenses,
          });
        } catch (_) {
          trend.add({
            'month': month,
            'income': 0.0,
            'expense': 0.0,
          });
        }
      }
      monthlyTrend.value = trend;
    } catch (e) {
      Get.log('StatsController: Error loading stats: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════
// View
// ════════════════════════════════════════════════════════════════════════

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  static const _desktopBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StatsController>()
        ? Get.find<StatsController>()
        : Get.put(StatsController());
    return Container(
      color: const Color(0xFFF8FAFC),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _desktopBreakpoint) {
            return _DesktopStats(controller: controller);
          }
          return _MobileStats(controller: controller);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Palette para charts (violet-centric)
// ─────────────────────────────────────────────────────────────────────────

const _kChartPalette = <Color>[
  AppTheme.primary,
  Color(0xFF5B598C),
  Color(0xFFC7C3FE),
  Color(0xFF8B5CF6),
  Color(0xFFCCC3D8),
  Color(0xFFBA1A1A),
];

Color _categoryColor(int index) => _kChartPalette[index % _kChartPalette.length];

// ─────────────────────────────────────────────────────────────────────────
// MOBILE
// ─────────────────────────────────────────────────────────────────────────

class _MobileStats extends StatelessWidget {
  final StatsController controller;
  const _MobileStats({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MobileHeader(),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.loadStats,
              color: AppTheme.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _PeriodSelector(controller: controller),
                  const SizedBox(height: 16),
                  _HeadlineKpi(controller: controller),
                  const SizedBox(height: 16),
                  _DonutCard(controller: controller),
                  const SizedBox(height: 16),
                  const _SmallTitle('Categorías populares'),
                  const SizedBox(height: 12),
                  _CategoriesHorizontalList(controller: controller),
                  const SizedBox(height: 16),
                  _TrendCard(controller: controller),
                ],
              ),
            );
          }),
        ),
      ],
    );
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
              Icons.insights_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Get.find<StatsController>().loadStats(),
            icon: const Icon(
              Icons.filter_list_rounded,
              color: Color(0xFF7B7487),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final StatsController controller;
  const _PeriodSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Obx(
        () => Row(
          children: [
            _periodTab('week', 'Semana'),
            _periodTab('month', 'Mes'),
            _periodTab('year', 'Año'),
          ],
        ),
      ),
    );
  }

  Widget _periodTab(String value, String label) {
    final selected = controller.period.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changePeriod(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF4A4455),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallTitle extends StatelessWidget {
  final String text;
  const _SmallTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1C1C),
        ),
      ),
    );
  }
}

class _HeadlineKpi extends StatelessWidget {
  final StatsController controller;
  const _HeadlineKpi({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F0FB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GASTOS DEL PERÍODO',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7B7487),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              CurrencyUtils.formatInDisplayCurrency(
                controller.totalExpenseThisMonth.value,
                controller.currency,
              ),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0FB),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final net = controller.netFlow;
                  return Icon(
                    net >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 16,
                    color: AppTheme.primary,
                  );
                }),
                const SizedBox(width: 6),
                Obx(() {
                  return Text(
                    'Flujo neto: ${CurrencyUtils.formatInDisplayCurrency(controller.netFlow.abs(), controller.currency)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
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

// ── Donut + legend ─────────────────────────────────────────────────────

class _DonutCard extends StatelessWidget {
  final StatsController controller;
  const _DonutCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F0FB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Distribución',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1C1C),
                ),
              ),
              Icon(
                Icons.more_horiz_rounded,
                size: 20,
                color: Color(0xFF7B7487),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Obx(() {
            final items = controller.categoryExpenses;
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Sin gastos para mostrar',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7B7487),
                    ),
                  ),
                ),
              );
            }
            return Row(
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CustomPaint(
                    painter: _DonutPainter(items: items),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7B7487),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _shortCurrency(
                              controller.totalExpenseThisMonth.value,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: List.generate(
                      items.length.clamp(0, 5),
                      (i) {
                        final item = items[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _categoryColor(i),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['name'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF4A4455),
                                  ),
                                ),
                              ),
                              Text(
                                '${(item['percentage'] as double).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1C1C),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;
  _DonutPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const stroke = 14.0;
    final radius = (size.width - stroke) / 2;
    final track = Paint()
      ..color = const Color(0xFFF1F0FB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, track);

    double start = -math.pi / 2;
    for (var i = 0; i < items.length; i++) {
      final pct = (items[i]['percentage'] as double) / 100;
      final sweep = pct * 2 * math.pi;
      final paint = Paint()
        ..color = _categoryColor(i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep - 0.02,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.items != items;
}

// ── Categories horizontal cards ────────────────────────────────────────

class _CategoriesHorizontalList extends StatelessWidget {
  final StatsController controller;
  const _CategoriesHorizontalList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.categoryExpenses;
      if (items.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length.clamp(0, 6),
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final item = items[i];
            final color = _categoryColor(i);
            return Container(
              width: 150,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F0FB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.10),
                    ),
                    child: Icon(
                      _iconForCategory(item['name'] as String),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['name'] as String,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1C1C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyUtils.formatInDisplayCurrency(
                      item['amount'] as double,
                      controller.currency,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7B7487),
                    ),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (item['percentage'] as double) / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFF1F0FB),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

IconData _iconForCategory(String name) {
  final n = name.toLowerCase();
  if (n.contains('comid') || n.contains('food')) return Icons.restaurant_rounded;
  if (n.contains('transp') || n.contains('auto')) return Icons.directions_car_rounded;
  if (n.contains('hogar') || n.contains('vivien') || n.contains('renta')) return Icons.home_rounded;
  if (n.contains('compra')) return Icons.shopping_bag_rounded;
  if (n.contains('viaje')) return Icons.flight_takeoff_rounded;
  if (n.contains('ocio') || n.contains('entret')) return Icons.movie_rounded;
  if (n.contains('salud')) return Icons.local_hospital_rounded;
  if (n.contains('educ')) return Icons.school_rounded;
  if (n.contains('servic') || n.contains('luz')) return Icons.bolt_rounded;
  return Icons.shopping_cart_rounded;
}

// ── Trend line chart ───────────────────────────────────────────────────

class _TrendCard extends StatelessWidget {
  final StatsController controller;
  const _TrendCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F0FB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendencia (últimos 6 meses)',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: Obx(() {
              final trend = controller.monthlyTrend;
              if (trend.isEmpty) {
                return const Center(
                  child: Text(
                    'Sin datos',
                    style: TextStyle(color: Color(0xFF7B7487)),
                  ),
                );
              }
              return CustomPaint(
                painter: _LineChartPainter(trend: trend),
                size: Size.infinite,
              );
            }),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final trend = controller.monthlyTrend;
            if (trend.isEmpty) return const SizedBox.shrink();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: trend
                  .map(
                    (m) => Text(
                      DateFormat('MMM', 'es').format(m['month'] as DateTime),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7B7487),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppTheme.accentGreen, 'Ingresos'),
              const SizedBox(width: 20),
              _legendDot(AppTheme.accentRed, 'Gastos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4A4455)),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> trend;
  _LineChartPainter({required this.trend});

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.isEmpty) return;

    // grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F0FB)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = trend.fold<double>(0, (m, e) {
      final v = math.max(e['income'] as double, e['expense'] as double);
      return v > m ? v : m;
    });
    if (maxValue <= 0) return;

    Path buildPath(String key) {
      final p = Path();
      for (var i = 0; i < trend.length; i++) {
        final x = size.width * (i / (trend.length - 1));
        final y =
            size.height - ((trend[i][key] as double) / maxValue) * size.height;
        if (i == 0) {
          p.moveTo(x, y);
        } else {
          p.lineTo(x, y);
        }
      }
      return p;
    }

    final incomePaint = Paint()
      ..color = AppTheme.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final expensePaint = Paint()
      ..color = AppTheme.accentRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(buildPath('income'), incomePaint);
    canvas.drawPath(buildPath('expense'), expensePaint);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.trend != trend;
}

// ─────────────────────────────────────────────────────────────────────────
// DESKTOP
// ─────────────────────────────────────────────────────────────────────────

class _DesktopStats extends StatelessWidget {
  final StatsController controller;
  const _DesktopStats({required this.controller});

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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DesktopHeader(controller: controller),
                const SizedBox(height: 24),
                // 2x2 grid
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _CardWrap(child: _DesktopDonut(controller: controller))),
                      const SizedBox(width: 20),
                      Expanded(child: _CardWrap(child: _DesktopTrend(controller: controller))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _CardWrap(child: _DesktopBars(controller: controller))),
                      const SizedBox(width: 20),
                      Expanded(child: _CardWrap(child: _DesktopAreaPlaceholder(controller: controller))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _DesktopTable(controller: controller),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  final StatsController controller;
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
                'Analytics',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Color(0xFF1A1C1C),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Vista detallada de tus finanzas.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A4455),
                ),
              ),
            ],
          ),
        ),
        _periodChip('week', 'Semana'),
        const SizedBox(width: 8),
        _periodChip('month', 'Mes'),
        const SizedBox(width: 8),
        _periodChip('year', 'Año'),
      ],
    );
  }

  Widget _periodChip(String value, String label) {
    return Obx(() {
      final selected = controller.period.value == value;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => controller.changePeriod(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppTheme.primary : const Color(0xFFE2E0F7),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF1A1C1C),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _CardWrap extends StatelessWidget {
  final Widget child;
  const _CardWrap({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F0FB)),
      ),
      child: child,
    );
  }
}

class _DesktopDonut extends StatelessWidget {
  final StatsController controller;
  const _DesktopDonut({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Desglose por categoría',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1C),
          ),
        ),
        const SizedBox(height: 18),
        Obx(() {
          final items = controller.categoryExpenses;
          if (items.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Sin gastos para mostrar',
                  style: TextStyle(color: Color(0xFF7B7487)),
                ),
              ),
            );
          }
          return Row(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _DonutPainter(items: items),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7B7487),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtils.formatInDisplayCurrency(
                            controller.totalExpenseThisMonth.value,
                            controller.currency,
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: List.generate(
                    items.length.clamp(0, 6),
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _categoryColor(i),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              items[i]['name'] as String,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4A4455),
                              ),
                            ),
                          ),
                          Text(
                            '${(items[i]['percentage'] as double).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _DesktopTrend extends StatelessWidget {
  final StatsController controller;
  const _DesktopTrend({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ingresos vs Gastos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1C1C),
              ),
            ),
            Row(
              children: [
                _legendDot(AppTheme.accentGreen, 'Ingresos'),
                const SizedBox(width: 14),
                _legendDot(AppTheme.accentRed, 'Gastos'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 220,
          child: Obx(() {
            final trend = controller.monthlyTrend;
            if (trend.isEmpty) {
              return const Center(
                child: Text(
                  'Sin datos',
                  style: TextStyle(color: Color(0xFF7B7487)),
                ),
              );
            }
            return CustomPaint(
              painter: _LineChartPainter(trend: trend),
              size: Size.infinite,
            );
          }),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final trend = controller.monthlyTrend;
          if (trend.isEmpty) return const SizedBox.shrink();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: trend
                .map(
                  (m) => Text(
                    DateFormat('MMM', 'es').format(m['month'] as DateTime),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7B7487),
                    ),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4A4455)),
        ),
      ],
    );
  }
}

class _DesktopBars extends StatelessWidget {
  final StatsController controller;
  const _DesktopBars({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top categorías',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1C),
          ),
        ),
        const SizedBox(height: 18),
        Obx(() {
          final items = controller.categoryExpenses;
          if (items.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Sin gastos',
                  style: TextStyle(color: Color(0xFF7B7487)),
                ),
              ),
            );
          }
          final maxAmount = items.first['amount'] as double;
          return Column(
            children: List.generate(
              items.length.clamp(0, 6),
              (i) {
                final pct = (items[i]['amount'] as double) / maxAmount;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          items[i]['name'] as String,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A4455),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 16,
                            backgroundColor: const Color(0xFFF1F0FB),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primary
                                  .withValues(alpha: 0.4 + (1 - i / 6) * 0.6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 80,
                        child: Text(
                          _shortCurrency(items[i]['amount'] as double),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

class _DesktopAreaPlaceholder extends StatelessWidget {
  final StatsController controller;
  const _DesktopAreaPlaceholder({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Balance por mes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1C),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 220,
          child: Obx(() {
            final trend = controller.monthlyTrend;
            if (trend.isEmpty) {
              return const Center(
                child: Text(
                  'Sin datos',
                  style: TextStyle(color: Color(0xFF7B7487)),
                ),
              );
            }
            return CustomPaint(
              painter: _AreaPainter(trend: trend),
              size: Size.infinite,
            );
          }),
        ),
      ],
    );
  }
}

class _AreaPainter extends CustomPainter {
  final List<Map<String, dynamic>> trend;
  _AreaPainter({required this.trend});

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.isEmpty) return;
    final maxValue = trend.fold<double>(0, (m, e) {
      final net = (e['income'] as double) - (e['expense'] as double);
      final v = net.abs();
      return v > m ? v : m;
    });
    if (maxValue <= 0) return;

    final path = Path();
    final fillPath = Path();
    for (var i = 0; i < trend.length; i++) {
      final net = (trend[i]['income'] as double) - (trend[i]['expense'] as double);
      final x = size.width * (i / (trend.length - 1));
      final ratio = (net / maxValue).clamp(-1.0, 1.0);
      final y = size.height / 2 - ratio * (size.height / 2 - 8);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primary.withValues(alpha: 0.22),
          AppTheme.primary.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // zero line
    final zeroPaint = Paint()
      ..color = const Color(0xFFEDEAF6)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      zeroPaint,
    );
  }

  @override
  bool shouldRepaint(_AreaPainter old) => old.trend != trend;
}

class _DesktopTable extends StatelessWidget {
  final StatsController controller;
  const _DesktopTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F0FB)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Detalle por categoría',
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
          Container(
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
                Expanded(flex: 4, child: _Th('Categoría')),
                Expanded(flex: 2, child: _Th('Monto')),
                Expanded(flex: 2, child: _Th('% Total')),
                Expanded(flex: 3, child: _Th('Distribución')),
              ],
            ),
          ),
          Obx(() {
            final items = controller.categoryExpenses;
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: Text(
                    'Sin gastos para mostrar',
                    style: TextStyle(color: Color(0xFF7B7487)),
                  ),
                ),
              );
            }
            return Column(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final color = _categoryColor(i);
                return Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEDEAF6)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: 0.10),
                              ),
                              child: Icon(
                                _iconForCategory(item['name'] as String),
                                color: color,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['name'] as String,
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
                        child: Text(
                          CurrencyUtils.formatInDisplayCurrency(
                            item['amount'] as double,
                            controller.currency,
                          ),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1C1C),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${(item['percentage'] as double).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF4A4455),
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
                              value:
                                  (item['percentage'] as double) / 100,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFF1F0FB),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

class _Th extends StatelessWidget {
  final String text;
  const _Th(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: Color(0xFF7B7487),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// helpers
// ─────────────────────────────────────────────────────────────────────────

String _shortCurrency(double v) {
  if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}k';
  return '\$${v.toStringAsFixed(0)}';
}
