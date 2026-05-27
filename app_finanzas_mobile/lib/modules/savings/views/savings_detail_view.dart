import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_utils.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/finance/saving.dart';
import '../../../data/models/finance/transaction.dart';
import '../controllers/savings_controller.dart';

class SavingsDetailView extends StatefulWidget {
  final Saving saving;

  const SavingsDetailView({super.key, required this.saving});

  @override
  State<SavingsDetailView> createState() => _SavingsDetailViewState();
}

class _SavingsDetailViewState extends State<SavingsDetailView> {
  late final SavingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SavingsController>();
    controller.loadGoalHistory(widget.saving.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSaving = controller.savings.firstWhere(
        (saving) => saving.id == widget.saving.id,
        orElse: () => widget.saving,
      );

      final progress =
          (currentSaving.currentAmount / currentSaving.targetAmount).clamp(
            0.0,
            1.0,
          );
      final remaining =
          (currentSaving.targetAmount - currentSaving.currentAmount).clamp(
            0.0,
            double.infinity,
          );

      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildCircularProgress(progress, controller, currentSaving),
                    const SizedBox(height: 40),
                    const SizedBox(height: 40),
                    _buildRemainingSection(
                      remaining,
                      currentSaving,
                      controller,
                    ),
                    const SizedBox(height: 40),
                    _buildGrowthSection(),
                    const SizedBox(height: 40),
                    _buildActivitySection(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildAddSavingsButton(controller, currentSaving),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Goal Details',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () =>
              _showEditGoalModal(context, controller, widget.saving),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => controller.deleteGoal(widget.saving.id),
        ),
        const SizedBox(width: 8),
      ],
      floating: true,
    );
  }

  Widget _buildCircularProgress(
    double progress,
    SavingsController controller,
    Saving currentSaving,
  ) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 200,
            height: 200,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              controller.getGoalIconWidget(currentSaving, size: 42),
              const SizedBox(height: 8),
              Text(
                CurrencyUtils.formatInDisplayCurrency(currentSaving.currentAmount, controller.currency),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% Reached',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingSection(
    double remaining,
    Saving currentSaving,
    SavingsController controller,
  ) {
    return Column(
      children: [
        Text(
          'Restante: ${CurrencyUtils.formatInDisplayCurrency(remaining, controller.currency)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Meta: ${CurrencyUtils.formatInDisplayCurrency(currentSaving.targetAmount, controller.currency)}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            controller.calculateProjection(currentSaving),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthSection() {
    final controller = Get.find<SavingsController>();
    final transactions = controller.goalTransactions.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Build cumulative sum
    final spots = <FlSpot>[];
    double cumulative = 0;
    final months = <String>[];
    final dateFormat = DateFormat('MMM', 'es');

    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      cumulative += tx.type == 'contribution' || tx.type == 'income'
          ? tx.amount
          : -tx.amount;
      spots.add(FlSpot(i.toDouble(), cumulative));
      months.add(dateFormat.format(tx.date));
    }

    // Growth percentage
    final growthPct = spots.length >= 2 && spots.first.y > 0
        ? ((spots.last.y - spots.first.y) / spots.first.y * 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CRECIMIENTO',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              '${growthPct >= 0 ? '+' : ''}${growthPct.toStringAsFixed(1)}%',
              style: TextStyle(
                color: growthPct >= 0 ? AppTheme.primaryColor : Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 160,
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: spots.length < 2
              ? Center(
                  child: Text(
                    'Registra aportes para ver el crecimiento',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                )
              : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (spots.length / 5).ceilToDouble().clamp(1, double.infinity),
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= months.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months[idx],
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          reservedSize: 22,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppTheme.primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withValues(alpha: 0.3),
                              AppTheme.primaryColor.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'HISTORIAL DE APORTES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.goalTransactions.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: Colors.white.withValues(alpha: 0.1),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sin transacciones aun',
                    style: TextStyle(color: Colors.white24),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: controller.goalTransactions.map((tx) {
              final isDeposit = tx.type == 'expense';
              return _buildContributionItem(tx, isDeposit);
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildContributionItem(Transaction tx, bool isDeposit) {
    final color = isDeposit ? AppTheme.primaryColor : Colors.redAccent;
    final dateStr = DateFormat('dd MMM yyyy').format(tx.date);
    final userName = tx.userCreated?.firstName ?? 'Sistema';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isDeposit
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.concept,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Por: $userName',
                        style: TextStyle(
                          color: AppTheme.primaryColor.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isDeposit ? '+' : '-'}${CurrencyUtils.formatInDisplayCurrency(tx.amount, controller.currency)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSavingsButton(
    SavingsController controller,
    Saving currentSaving,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => _showWithdrawFundsModal(
                  Get.context!,
                  controller,
                  currentSaving,
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.redAccent.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () =>
                    controller.addFunds(currentSaving.id, currentSaving.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 8),
                    Text(
                      'Aportar Fondos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  void _showWithdrawFundsModal(
    BuildContext context,
    SavingsController controller,
    Saving saving,
  ) {
    final amountController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Retirar Fondos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Disponible: ${CurrencyUtils.formatInDisplayCurrency(saving.currentAmount, controller.currency)}',
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                border: InputBorder.none,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  if (amount > 0 && amount <= saving.currentAmount) {
                    Get.back();
                    controller.submitWithdrawFunds(saving.id, amount);
                  } else {
                    Get.snackbar('Error', 'Monto invalido para retirar');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('Confirmar Retiro'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGoalModal(
    BuildContext context,
    SavingsController controller,
    Saving saving,
  ) {
    final nameController = TextEditingController(text: saving.name);
    final amountController = TextEditingController(
      text: saving.targetAmount.toString(),
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre de la Meta',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Monto Objetivo',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  controller.submitUpdateGoal(
                    id: saving.id,
                    name: nameController.text,
                    amount: double.tryParse(amountController.text),
                  );
                },
                child: const Text('Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
