import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/transaction_items_controller.dart';

class TransactionItemEvolutionView extends StatefulWidget {
  final String itemName;
  const TransactionItemEvolutionView({super.key, required this.itemName});

  @override
  State<TransactionItemEvolutionView> createState() => _TransactionItemEvolutionViewState();
}

class _TransactionItemEvolutionViewState extends State<TransactionItemEvolutionView> {
  final TransactionItemsController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.loadItemEvolution(widget.itemName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Evolución: ${widget.itemName}'),
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoadingEvolution.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.selectedItemEvolution.isEmpty) {
          return const Center(
            child: Text("No hay datos históricos", style: TextStyle(color: Colors.white24)),
          );
        }

        return Column(
          children: [
            _buildPriceChart(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.selectedItemEvolution.length,
                itemBuilder: (context, index) {
                  final history = controller.selectedItemEvolution[index];
                  return _buildHistoryItem(history);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPriceChart() {
    final items = controller.selectedItemEvolution.toList()
      ..sort((a, b) {
        final aDate = a.transactionDate ?? DateTime(2000);
        final bDate = b.transactionDate ?? DateTime(2000);
        return aDate.compareTo(bDate);
      });

    if (items.length < 2) {
      return Container(
        height: 200,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            'Se necesitan al menos 2 registros para graficar',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          ),
        ),
      );
    }

    final spots = items.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.unitPrice);
    }).toList();

    final dateFormat = DateFormat('dd/MM');

    return Container(
      height: 200,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.fromLTRB(10, 20, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: (items.length / 4).ceilToDouble().clamp(1, double.infinity),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= items.length) return const SizedBox.shrink();
                  final date = items[idx].transactionDate;
                  if (date == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dateFormat.format(date),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                return LineTooltipItem(
                  '\$${s.y.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3,
                  color: AppTheme.primaryColor,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(dynamic history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Precio Unitario', style: TextStyle(color: Colors.white54, fontSize: 12)),
              Text(
                controller.formatCurrency(history.unitPrice),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Fecha', style: TextStyle(color: Colors.white54, fontSize: 12)),
              Text(
                history.transactionDate != null
                    ? "${history.transactionDate!.day}/${history.transactionDate!.month}/${history.transactionDate!.year}"
                    : 'Historial',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
