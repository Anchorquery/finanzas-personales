import 'package:flutter/material.dart';
import 'package:app_finanzas_mobile/core/utils/currency_utils.dart';
import 'package:app_finanzas_mobile/core/theme/app_theme.dart';
import 'package:app_finanzas_mobile/core/utils/icon_utils.dart';
import 'package:app_finanzas_mobile/data/models/finance/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amount = transaction.amount;
    final isOpeningBalance = transaction.type == 'opening_balance';
    final isIncome = transaction.type == 'income' || isOpeningBalance;
    final category = isOpeningBalance
        ? 'Saldo inicial'
        : (transaction.category?.name ?? 'General');
    final iconName = transaction.category?.icon;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.inputFillLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isOpeningBalance
                      ? Icons.account_balance_wallet_rounded
                      : (iconName != null
                          ? IconUtils.getIconByName(iconName)
                          : (isIncome
                              ? Icons.arrow_downward
                              : Icons.arrow_upward)),
                  color: isIncome ? AppTheme.accentGreen : AppTheme.accentRed,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.concept,
                    style: TextStyle(
                                            fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.backgroundDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$category${transaction.userCreated != null ? ' • ${transaction.userCreated!.firstName}' : ''}",
                    style: TextStyle(
                                            fontSize: 13,
                      color: isDark ? AppTheme.textSecondary : AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${isIncome ? '+' : '-'}${CurrencyUtils.formatInDisplayCurrency(amount, transaction.currency)}",
              style: TextStyle(
                                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isIncome ? AppTheme.accentGreen : AppTheme.accentRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
