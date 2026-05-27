import 'package:flutter/material.dart';
import 'package:app_finanzas_mobile/core/utils/currency_utils.dart';
import '../theme/app_theme.dart';
import 'custom_card.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: AppTheme.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Balance Total",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyUtils.formatInDisplayCurrency(balance, 'USD'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                "Ingresos",
                income,
                Icons.arrow_downward,
                AppTheme.accentColor,
              ),
              _buildStat(
                "Gastos",
                expense,
                Icons.arrow_upward,
                AppTheme.errorColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, double amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              CurrencyUtils.formatInDisplayCurrency(amount, 'USD'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
