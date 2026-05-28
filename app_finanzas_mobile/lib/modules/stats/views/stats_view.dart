import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/services/directus_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';

class StatsController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController = Get.find();

  final isLoading = true.obs;
  final categoryExpenses = <Map<String, dynamic>>[].obs;
  final monthlyTrend = <Map<String, dynamic>>[].obs;
  final totalExpenseThisMonth = 0.0.obs;
  final totalIncomeThisMonth = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
    ever(_workspacesController.activeWorkspaceRx, (_) => loadStats());
  }

  Future<void> loadStats() async {
    final wsId = _workspacesController.activeWorkspace?.id;
    if (wsId == null) return;

    isLoading.value = true;
    try {
      final now = DateTime.now();

      // Get all transactions for this month
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final transactions = await _directusService.getTransactions(
        limit: 500,
        startDate: startDate,
        endDate: endDate,
        workspaceId: wsId,
      );

      // Category breakdown
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

      // Sort by amount desc
      final sorted = catTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      categoryExpenses.value = sorted.map((e) => {
        'id': e.key,
        'name': catNames[e.key] ?? 'Otros',
        'amount': e.value,
        'percentage': totalExp > 0 ? (e.value / totalExp * 100) : 0.0,
      }).toList();

      // Monthly trend (last 6 months)
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

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final StatsController controller;
    if (Get.isRegistered<StatsController>()) {
      controller = Get.find<StatsController>();
    } else {
      controller = Get.put(StatsController());
    }

    const cardColor = Color(0xFF1E293B);
    const textWhite = Colors.white;
    const textGrey = Color(0xFF94A3B8);

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
                      "Estadísticas",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white54),
                    onPressed: () => controller.loadStats(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                  onRefresh: controller.loadStats,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              'Ingresos',
                              controller.totalIncomeThisMonth.value,
                              AppTheme.accentGreen,
                              cardColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _summaryCard(
                              'Gastos',
                              controller.totalExpenseThisMonth.value,
                              AppTheme.accentRed,
                              cardColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Monthly Trend Chart
                      if (controller.monthlyTrend.isNotEmpty) ...[
                        const Text(
                          'TENDENCIA MENSUAL',
                          style: TextStyle(
                            color: textGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 220,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: _buildBarChart(controller.monthlyTrend),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Category Breakdown
                      const Text(
                        'GASTOS POR CATEGORÍA',
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (controller.categoryExpenses.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'No hay gastos este mes',
                              style: TextStyle(color: textGrey),
                            ),
                          ),
                        )
                      else ...[
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: _buildPieChart(controller.categoryExpenses),
                        ),
                        const SizedBox(height: 12),
                        ...controller.categoryExpenses.map((cat) {
                          final pct = (cat['percentage'] as double).toStringAsFixed(1);
                          final amount = (cat['amount'] as double).toStringAsFixed(2);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _categoryColor(
                                      controller.categoryExpenses.indexOf(cat),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    cat['name'] as String,
                                    style: const TextStyle(
                                      color: textWhite,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$$amount',
                                  style: const TextStyle(
                                    color: textWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$pct%',
                                  style: const TextStyle(
                                    color: textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, double value, Color color, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Color _categoryColor(int index) {
    const colors = [
      Color(0xFF3B82F6),
      AppTheme.accentGreen,
      Color(0xFFF59E0B),
      AppTheme.accentRed,
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
      Color(0xFFEC4899),
      Color(0xFF84CC16),
    ];
    return colors[index % colors.length];
  }

  Widget _buildPieChart(List<Map<String, dynamic>> data) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          return PieChartSectionData(
            value: cat['amount'] as double,
            color: _categoryColor(i),
            radius: 30,
            showTitle: false,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < data.length) {
                  final month = data[idx]['month'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[month.month - 1],
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (item['income'] as double),
                color: AppTheme.accentGreen,
                width: 8,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: (item['expense'] as double),
                color: AppTheme.accentRed,
                width: 8,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
