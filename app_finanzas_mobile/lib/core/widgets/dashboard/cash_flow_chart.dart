import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:app_finanzas_mobile/core/theme/app_theme.dart';
import 'package:app_finanzas_mobile/core/utils/currency_utils.dart';

class CashFlowChart extends StatelessWidget {
  final List<FlSpot> spots;
  final double netFlow;
  final String currency;
  final String periodLabel;

  const CashFlowChart({
    super.key,
    required this.spots,
    required this.netFlow,
    this.currency = 'USD',
    this.periodLabel = 'Semana actual',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      // Consistent Styling
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2030) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    CurrencyUtils.formatInDisplayCurrency(netFlow, currency),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Flujo neto $periodLabel',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black12,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Color(0xFF64748B), // Slate 500
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = 'Lun';
                            break;
                          case 1:
                            text = 'Mar';
                            break;
                          case 2:
                            text = 'Mié';
                            break;
                          case 3:
                            text = 'Jue';
                            break;
                          case 4:
                            text = 'Vie';
                            break;
                          case 5:
                            text = 'Sáb';
                            break;
                          case 6:
                            text = 'Dom';
                            break;
                          default:
                            return Container();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: null, // Auto scale
                maxY: null, // Auto scale
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isEmpty
                        ? const [FlSpot(0, 0), FlSpot(6, 0)]
                        : spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        Color(0xFF60A5FA),
                      ], // Primary to Blue-400
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.3),
                          AppTheme.primaryColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
