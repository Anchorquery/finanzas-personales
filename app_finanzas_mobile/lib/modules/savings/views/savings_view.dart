import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/models/finance/saving.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/savings_controller.dart';
import 'savings_detail_view.dart';

class SavingsView extends GetView<SavingsController> {
  const SavingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                if (MediaQuery.of(context).size.width < 800)
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Scaffold.maybeOf(ctx)?.openDrawer(),
                    ),
                  ),
                Expanded(
                  child: Text(
                    AppL10n.of(context).savingsTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  onPressed: controller.createGoal,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadSavings,
              backgroundColor: AppTheme.surfaceDark,
              color: AppTheme.primaryColor,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildTotalSavingsCard(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppL10n.of(context).savingsActiveGoals,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Obx(
                            () => Text(
                              AppL10n.of(context).savingsGoalsCount(controller.savings.length),
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.isLoading.value &&
                        controller.savings.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 120),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      );
                    }

                    if (controller.savings.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                          child: _buildEmptyState(),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final saving = controller.savings[index];
                          return _buildSavingGoalCard(saving);
                        }, childCount: controller.savings.length),
                      ),
                    );
                  }),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: const Text(
                        'INSIGHTS & TIPS',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _buildInsightCard(
                            title: 'Reto Semanal',
                            subtitle:
                                'Ahorra \$10 extras hoy y obten una medalla.',
                            icon: Icons.emoji_events_rounded,
                            color: AppTheme.accentAI,
                          ),
                          _buildInsightCard(
                            title: 'Tip de Ahorro',
                            subtitle:
                                'Evita gastos hormiga esta semana y ahorra un 5%.',
                            icon: Icons.lightbulb_outline_rounded,
                            color: Colors.orangeAccent,
                          ),
                          _buildInsightCard(
                            title: 'Proyeccion',
                            subtitle:
                                'Vas en camino a cumplir 3 metas antes de junio.',
                            icon: Icons.auto_graph_rounded,
                            color: Colors.greenAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16, bottom: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSavingsCard() {
    return Obx(() {
      final total = controller.savings.fold<double>(
        0,
        (sum, item) => sum + item.currentAmount,
      );
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Ahorrado',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyUtils.formatInDisplayCurrency(total, controller.currency),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final count = controller.savings.length;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$count meta${count != 1 ? 's' : ''} activa${count != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(
              Icons.savings_outlined,
              size: 64,
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes metas de ahorro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Empieza a ahorrar para tus suenos\ncreando tu primera meta ahora.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.createGoal,
            icon: const Icon(Icons.add),
            label: const Text('Crear Meta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingGoalCard(Saving saving) {
    final progress = (saving.currentAmount / saving.targetAmount).clamp(
      0.0,
      1.0,
    );
    final percent = (progress * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: () => Get.to(() => SavingsDetailView(saving: saving)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      saving.icon ?? '💰',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        saving.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Faltan \$${(saving.targetAmount - saving.currentAmount).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'de \$${saving.targetAmount.toInt()}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOutCubic,
                      height: 8,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, Color(0xFF64B5F6)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${saving.currentAmount.toStringAsFixed(0)} ahorrados',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.addFunds(saving.id, saving.name),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Aportar',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}
