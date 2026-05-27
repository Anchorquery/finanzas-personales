import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_finanzas_mobile/core/utils/currency_utils.dart';
import '../theme/app_theme.dart';
import '../utils/icon_utils.dart';
import 'custom_card.dart';
import 'package:app_finanzas_mobile/data/models/finance/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final amount = transaction.amount;
    final isOpeningBalance = transaction.type == 'opening_balance';
    final isIncome = transaction.type == 'income' || isOpeningBalance;
    final date = transaction.date;
    final category = isOpeningBalance
        ? 'Saldo inicial'
        : (transaction.category?.name ?? 'General');
    final iconName = transaction.category?.icon;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isIncome
                    ? AppTheme.accentColor.withValues(alpha: 0.1)
                    : AppTheme.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                // Use mapped icon if available, otherwise fallback to arrows
                isOpeningBalance
                    ? Icons.account_balance_wallet_rounded
                    : (iconName != null
                          ? IconUtils.getIconByName(iconName)
                          : (isIncome
                                ? Icons.arrow_downward
                                : Icons.arrow_upward)),
                color: isIncome ? AppTheme.accentColor : AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.concept,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$category • ${DateFormat('dd MMM').format(date)}"
                    "${transaction.userCreated != null ? ' • ${transaction.userCreated!.firstName}' : ''}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${isIncome ? '+' : '-'}${CurrencyUtils.formatInDisplayCurrency(amount, transaction.currency)}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isIncome ? AppTheme.accentColor : AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
