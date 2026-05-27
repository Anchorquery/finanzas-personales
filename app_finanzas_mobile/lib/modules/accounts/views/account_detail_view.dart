import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../../data/services/directus_service.dart';
import '../controllers/account_detail_controller.dart';

class AccountDetailView extends StatelessWidget {
  const AccountDetailView({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final tag = 'account-detail-${account.id}';
    final controller = Get.isRegistered<AccountDetailController>(tag: tag)
        ? Get.find<AccountDetailController>(tag: tag)
        : Get.put(AccountDetailController(account: account), tag: tag);

    return GetBuilder<AccountDetailController>(
      tag: tag,
      init: controller,
      global: false,
      builder: (_) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            title: Text(account.name),
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadTransactions,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeaderCard(controller),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Movimientos'),
                  const SizedBox(height: 12),
                  if (controller.transactions.isEmpty)
                    _buildEmptyState()
                  else
                    ...controller.historyGroups.expand(
                      (group) => [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            group.label,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ...group.items.map(
                          (tx) => TransactionTile(transaction: tx),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeaderCard(AccountDetailController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance actual',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyUtils.formatInDisplayCurrency(
              account.currentBalance,
              account.currency,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricChip(
                'Saldo inicial',
                CurrencyUtils.formatInDisplayCurrency(
                  account.initialBalance,
                  account.currency,
                ),
              ),
              _metricChip(
                'Ingresos',
                CurrencyUtils.formatInDisplayCurrency(
                  controller.totalIncome,
                  account.currency,
                ),
              ),
              _metricChip(
                'Gastos',
                CurrencyUtils.formatInDisplayCurrency(
                  controller.totalExpense,
                  account.currency,
                ),
              ),
              _metricChip(
                'Apertura',
                account.createdAt != null
                    ? DateFormat(
                        'd MMM yyyy',
                        'es_ES',
                      ).format(account.createdAt!)
                    : 'No disponible',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Esta cuenta no tiene movimientos todavia.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
