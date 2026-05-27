import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/budgets_controller.dart';
import '../../home/controllers/home_controller.dart';

class BudgetsView extends GetView<BudgetsController> {
  const BudgetsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryColor),
                    );
                  }

                  if (controller.budgets.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.loadBudgets(showErrors: true),
                    color: AppTheme.primaryColor,
                    backgroundColor: AppTheme.surfaceDark,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), // Extra bottom padding for FAB/NavBar
                      itemCount: controller.budgets.length,
                      itemBuilder: (context, index) {
                        return _buildBudgetCard(controller.budgets[index]);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            heroTag: 'add_budget_fab',
            onPressed: controller.showAddBudgetDialog,
            backgroundColor: AppTheme.primaryColor,
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          if (!isWide)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
              onPressed: () => Get.find<HomeController>().scaffoldKey.currentState?.openDrawer(),
            ),
          Expanded(
            child: Text(
              AppL10n.of(context).budgetsTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (!isWide) const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // Note: this method runs without context. Empty state text remains static
    // until reachable via BuildContext (caller may upgrade to ctx-aware later).
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Styled central icon with luminous aura
            TweenAnimationBuilder(
              duration: const Duration(seconds: 2),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15 * value),
                        blurRadius: 50 * value,
                        spreadRadius: 15 * value,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 90,
                    color: Colors.white.withValues(alpha: 0.2 + (0.1 * value)),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            // Inspirational Title
            const Text(
              "Control total de tus finanzas",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            // Persuasive Subtitle
            const Text(
              "Define límites mensuales por categoría para evitar gastos innecesarios y alcanzar tus metas de ahorro más rápido.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 56),
            // Premium CTA Button with gradient feel
            Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: controller.showAddBudgetDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Crear mi primer presupuesto",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Subtle helper text
            Text(
              "Configuración rápida en menos de 1 minuto",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(dynamic budget) {
    final bool isOverBudget = budget.percent > 100;
    
    // Dynamic color logic based on percentage
    final Color progressColor = budget.percent >= 90
        ? AppTheme.accentRed
        : budget.percent >= 70
            ? AppTheme.accentWarning
            : AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  budget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_note_rounded,
                      size: 26,
                      color: Colors.white38,
                    ),
                    onPressed: () => controller.editBudget(
                      budget.id,
                      budget.limit,
                      budget.name,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 22,
                      color: Colors.white24,
                    ),
                    onPressed: () => controller.deleteBudget(
                      budget.id,
                      budget.name,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Gastado",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyUtils.formatInDisplayCurrency(budget.spent, controller.currency),
                    style: TextStyle(
                      color: isOverBudget ? AppTheme.accentRed : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'de ${CurrencyUtils.formatInDisplayCurrency(budget.limit, controller.currency)}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (budget.percent / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        progressColor,
                        progressColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${budget.percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (isOverBudget)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '¡EXCEDIDO!',
                    style: TextStyle(
                      color: AppTheme.accentRed,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

