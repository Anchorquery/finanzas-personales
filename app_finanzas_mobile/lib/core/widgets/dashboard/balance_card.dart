import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:app_finanzas_mobile/core/theme/app_theme.dart';
import 'package:app_finanzas_mobile/core/utils/currency_utils.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double percentage;
  final String currency;
  final String? secondaryCurrency;
  final double? exchangeRate;
  final String? rateSource;
  final String? breakdown;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.percentage,
    this.currency = 'USD',
    this.secondaryCurrency,
    this.exchangeRate,
    this.rateSource,
    this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // xl
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardGradientStart,
            AppTheme.cardGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative shapes
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 50,
                  sigmaY: 50,
                ), // Blur effect
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentBlue.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo Total',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        // Toggle de moneda de visualización
                        Obx(() => Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: CurrencyUtils.displayCurrencies.map((c) {
                              final isSelected = CurrencyUtils.displayCurrency.value == c;
                              return GestureDetector(
                                onTap: () => CurrencyUtils.setDisplayCurrency(c),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryColor.withValues(alpha: 0.8)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    c,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                percentage >= 0 ? Icons.trending_up : Icons.trending_down,
                                color: percentage >= 0
                                    ? AppTheme.accentGreen
                                    : AppTheme.accentRed,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: percentage >= 0
                                      ? AppTheme.accentGreen
                                      : AppTheme.accentRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Obx(() {
                  final displayCur = CurrencyUtils.displayCurrency.value;
                  final showEquivalence = displayCur != currency;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CurrencyUtils.formatInDisplayCurrency(balance, currency),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (showEquivalence) ...[
                        const SizedBox(height: 2),
                        Text(
                          CurrencyUtils.formatAmount(balance, currency),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        rateSource ?? 'Actualizado hace un momento',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      if (breakdown != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          breakdown!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
