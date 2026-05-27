import 'package:flutter/material.dart';
import 'package:app_finanzas_mobile/core/utils/currency_utils.dart';
import '../theme/app_theme.dart';
import 'custom_card.dart';

class BudgetCard extends StatelessWidget {
  final Map<String, dynamic> budget;
  final VoidCallback onTap;

  const BudgetCard({super.key, required this.budget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = budget['name'];
    final limit = budget['budget'] as double;
    final spent = budget['spent'] as double;
    double percent = budget['percent'] as double; // Changed to mutable double

    Color progressColor = AppTheme.accentColor;
    if (percent > 1.0) {
      percent = 1.0; // Cap percent at 1.0 for display purposes
      progressColor = AppTheme.errorColor;
    } else if (percent > 0.8) {
      // Added curly braces for linting
      progressColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${CurrencyUtils.formatInDisplayCurrency(spent, 'USD')} / ${CurrencyUtils.formatInDisplayCurrency(limit, 'USD')}",
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.7,
                    ), // Reverted to original as 'color' is not defined
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent > 1.0 ? 1.0 : percent,
                backgroundColor: Colors.white10,
                color: progressColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${(percent * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
