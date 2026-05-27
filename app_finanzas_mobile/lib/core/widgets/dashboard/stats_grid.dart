import 'package:flutter/material.dart';
import 'package:app_finanzas_mobile/core/theme/app_theme.dart';
import 'package:app_finanzas_mobile/core/utils/currency_utils.dart';

class StatsGrid extends StatelessWidget {
  final double income;
  final double expenses;
  final double incomeTrendPercentage;
  final double expenseTrendPercentage;
  final String currency;

  const StatsGrid({
    super.key,
    required this.income,
    required this.expenses,
    required this.incomeTrendPercentage,
    required this.expenseTrendPercentage,
    this.currency = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Ingresos',
            amount: income,
            icon: Icons.arrow_downward,
            color: AppTheme.accentGreen,
            trendPercentage: incomeTrendPercentage,
            currency: currency,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Gastos',
            amount: expenses,
            icon: Icons.arrow_upward,
            color: AppTheme.accentRed,
            trendPercentage: expenseTrendPercentage,
            currency: currency,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final double trendPercentage;
  final String currency;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.trendPercentage,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = trendPercentage >= 0;
    final trendColor = isPositive ? AppTheme.accentGreen : AppTheme.accentRed;
    final trendLabel =
        '${isPositive ? '+' : ''}${trendPercentage.toStringAsFixed(1)}% vs mes ant.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2030) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        // Sombras visibles solo en modo claro
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : Colors.grey[600], // slate-400
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyUtils.formatInDisplayCurrency(amount, currency),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trendLabel,
            style: TextStyle(
              color: trendColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
