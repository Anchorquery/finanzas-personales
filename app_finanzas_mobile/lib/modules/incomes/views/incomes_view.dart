import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/directus_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routes/app_routes.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/incomes_controller.dart';

class IncomesView extends GetView<IncomesController> {
  const IncomesView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<IncomesController>()) {
      Get.put(IncomesController());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context, isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentGreen,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchIncomes,
                  color: AppTheme.accentGreen,
                  backgroundColor: AppTheme.surfaceDark,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildTotalIncomeHeader(),
                        const SizedBox(height: 24),
                        _buildQuickSummary(),
                        if (controller.pendingIncomePlans.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          _buildPlannedIncomes(),
                        ],
                        const SizedBox(height: 28),
                        _buildSourcesCard(),
                        const SizedBox(height: 28),
                        _buildHistoryHeader(),
                        const SizedBox(height: 12),
                        _buildHistoryFilters(),
                        const SizedBox(height: 18),
                        _buildHistoryList(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'incomes_fab',
        onPressed: () => Get.toNamed(Routes.addIncome),
        backgroundColor: AppTheme.accentGreen,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          if (!isWide)
            IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 28,
              ),
              onPressed: () => Get.find<HomeController>().scaffoldKey.currentState?.openDrawer(),
            ),
          Expanded(
            child: Text(
              AppL10n.of(context).incomesTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (!isWide) const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTotalIncomeHeader() {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final change = controller.percentageChange.value;
    final isPos = change >= 0;
    final hasReceivedIncome = controller.totalMonthlyIncome.value > 0;
    final displayedTotal = hasReceivedIncome
        ? controller.totalMonthlyIncome.value
        : controller.expectedMonthlyIncome.value;
    final headerLabel = hasReceivedIncome
        ? 'Recibido este mes'
        : 'Esperado este mes';

    return Center(
      child: Column(
        children: [
          Text(
            headerLabel,
            style: const TextStyle(color: Colors.white60, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(displayedTotal),
            style: const TextStyle(
              color: AppTheme.accentGreen,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (hasReceivedIncome)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isPos ? AppTheme.accentGreen : AppTheme.accentRed)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPos ? Icons.trending_up : Icons.trending_down,
                    color: isPos ? AppTheme.accentGreen : AppTheme.accentRed,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${change.toStringAsFixed(1)}% vs mes pasado',
                    style: TextStyle(
                      color: isPos ? AppTheme.accentGreen : AppTheme.accentRed,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            const Text(
              'Aun no has registrado ingresos recibidos este mes.',
              style: TextStyle(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildQuickSummary() {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Filtrado',
            value: formatter.format(controller.filteredIncomeTotal),
            caption: controller.selectedRangeLabel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Movimientos',
            value: controller.filteredIncomeCount.toString(),
            caption:
                'prom. ${formatter.format(controller.filteredAverageIncome)}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Principal',
            value: controller.topSourceLabel,
            caption: formatter.format(controller.topSourceAmount),
            compact: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String caption,
    bool compact = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 15 : 18,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannedIncomes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingresos Esperados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 112,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.pendingIncomePlans.length,
            itemBuilder: (context, index) {
              final plan = controller.pendingIncomePlans[index];
              final isRegistering = controller.registeringPlanIds.contains(
                plan.id,
              );
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            plan.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white38,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '\$${plan.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.accentGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 32,
                          child: TextButton(
                            onPressed: isRegistering
                                ? null
                                : () => controller.markAsReceived(plan),
                            style: TextButton.styleFrom(
                              backgroundColor: AppTheme.accentGreen.withValues(
                                alpha: isRegistering ? 0.05 : 0.1,
                              ),
                              minimumSize: const Size(64, 32),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              isRegistering ? '...' : 'Recibir',
                              style: TextStyle(
                                color: isRegistering
                                    ? Colors.white38
                                    : AppTheme.accentGreen,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSourcesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Desglose por Fuente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                controller.selectedRangeLabel,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (controller.sourceBreakdown.isEmpty)
            const Text(
              'Sin datos este mes.',
              style: TextStyle(color: Colors.white38),
            )
          else
            ...controller.sourceBreakdown.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return const Text(
      'Historial',
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildHistoryFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRangeChip('Mes', IncomeRangeFilter.month),
              const SizedBox(width: 8),
              _buildRangeChip('3M', IncomeRangeFilter.threeMonths),
              const SizedBox(width: 8),
              _buildRangeChip('Año', IncomeRangeFilter.year),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.availableSources
                .map(
                  (source) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildSourceChip(source),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeChip(String label, IncomeRangeFilter range) {
    final isSelected = controller.selectedRange.value == range;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.setRange(range),
      backgroundColor: AppTheme.surfaceDark,
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.25),
      side: BorderSide(
        color: isSelected
            ? AppTheme.primaryColor
            : Colors.white.withValues(alpha: 0.06),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white60,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  Widget _buildSourceChip(String source) {
    final isSelected = controller.selectedSource.value == source;
    return ChoiceChip(
      label: Text(source),
      selected: isSelected,
      onSelected: (_) => controller.setSource(source),
      backgroundColor: AppTheme.surfaceDark,
      selectedColor: AppTheme.accentGreen.withValues(alpha: 0.18),
      side: BorderSide(
        color: isSelected
            ? AppTheme.accentGreen
            : Colors.white.withValues(alpha: 0.06),
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.accentGreen : Colors.white60,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  Widget _buildHistoryList() {
    if (controller.filteredIncomes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'No hay ingresos para los filtros seleccionados.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: controller.historyGroups
          .map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.label,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...group.items.map(_buildIncomeTile),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildIncomeTile(Transaction tx) {
    final formatter = DateFormat('d MMM yyyy', 'es_ES');
    final source = tx.category?.name ?? 'Otros';
    final appliedBy = tx.userCreated?.firstName;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showIncomeDetail(tx),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.concept,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$source · ${formatter.format(tx.date)}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    if (appliedBy != null && appliedBy.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Aplicado por $appliedBy',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+\$${tx.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white24,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIncomeDetail(Transaction tx) {
    final directus = Get.find<DirectusService>();
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormatter = DateFormat('d MMMM yyyy', 'es_ES');
    final appliedBy = tx.userCreated?.firstName.isNotEmpty == true
        ? tx.userCreated!.firstName
        : (tx.userCreated?.email.isNotEmpty == true
              ? tx.userCreated!.email
              : 'Usuario no disponible');
    final receiptUrl = tx.receiptImageId != null
        ? '${directus.serverUrl}/assets/${tx.receiptImageId}'
        : null;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Detalle del ingreso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Concepto', tx.concept),
            _buildDetailRow('Monto', currencyFormatter.format(tx.amount)),
            _buildDetailRow(
              'Fecha',
              _capitalize(dateFormatter.format(tx.date)),
            ),
            _buildDetailRow('Fuente', tx.category?.name ?? 'Otros'),
            _buildDetailRow('Aplicado por', appliedBy),
            if (receiptUrl != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Comprobante adjunto',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showReceiptPreview(receiptUrl),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Image.network(
                        receiptUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white.withValues(alpha: 0.04),
                            alignment: Alignment.center,
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No se pudo cargar el archivo adjunto.',
                                style: TextStyle(color: Colors.white38),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) {
                            return child;
                          }

                          return Container(
                            color: Colors.white.withValues(alpha: 0.04),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              color: AppTheme.accentGreen,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (receiptUrl != null)
                  _buildActionButton(
                    label: 'Ver archivo',
                    icon: Icons.open_in_full_rounded,
                    onTap: () => _showReceiptPreview(receiptUrl),
                  ),
                _buildActionButton(
                  label: 'Editar',
                  icon: Icons.edit_outlined,
                  onTap: () {
                    Get.back();
                    Future.microtask(() => _showEditIncomeSheet(tx));
                  },
                ),
                _buildActionButton(
                  label: 'Anular',
                  icon: Icons.delete_outline,
                  danger: true,
                  onTap: () {
                    Get.back();
                    _confirmDeleteIncome(tx);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? AppTheme.accentRed : AppTheme.primaryColor;
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  void _showReceiptPreview(String receiptUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(
                  receiptUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.surfaceDark,
                      padding: const EdgeInsets.all(24),
                      child: const Text(
                        'No se pudo abrir el archivo adjunto.',
                        style: TextStyle(color: Colors.white38),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(99),
                child: InkWell(
                  onTap: Get.back,
                  borderRadius: BorderRadius.circular(99),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditIncomeSheet(Transaction tx) {
    final amountController = TextEditingController(
      text: tx.amount.toStringAsFixed(2),
    );
    final conceptController = TextEditingController(text: tx.concept);
    final selectedDate = ValueNotifier<DateTime>(tx.date);
    final isSaving = ValueNotifier<bool>(false);
    String? selectedCategoryId =
        tx.category?.id ?? controller.incomeCategories.firstOrNull?.id;
    File? selectedReceiptFile;
    var effectiveReceiptId = tx.receiptImageId;
    final picker = ImagePicker();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          final previewUrl = selectedReceiptFile != null
              ? selectedReceiptFile!.path
              : (effectiveReceiptId != null
                    ? '${Get.find<DirectusService>().serverUrl}/assets/$effectiveReceiptId'
                    : null);
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Editar ingreso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: conceptController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Concepto'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Monto'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(selectedCategoryId),
                    initialValue: selectedCategoryId,
                    dropdownColor: AppTheme.surfaceDark,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Fuente'),
                    items: controller.incomeCategories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => selectedCategoryId = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate.value = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: _inputDecoration('Fecha'),
                      child: Text(
                        DateFormat(
                          'd MMMM yyyy',
                          'es_ES',
                        ).format(selectedDate.value),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (picked == null) return;
                      setModalState(() {
                        selectedReceiptFile = File(picked.path);
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: _inputDecoration('Comprobante'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedReceiptFile != null
                                ? 'Nuevo archivo seleccionado'
                                : (effectiveReceiptId != null
                                      ? 'Comprobante actual adjunto'
                                      : 'Tocar para adjuntar captura o archivo'),
                            style: const TextStyle(color: Colors.white),
                          ),
                          if (previewUrl != null) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: selectedReceiptFile != null
                                    ? Image.file(
                                        selectedReceiptFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        previewUrl,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (isSaving.value) return;
                        final amount = double.tryParse(amountController.text);
                        final categoryId = selectedCategoryId;
                        if (amount == null ||
                            amount <= 0 ||
                            categoryId == null) {
                          return;
                        }

                        setModalState(() => isSaving.value = true);
                        try {
                          var receiptImageId = effectiveReceiptId;
                          if (selectedReceiptFile != null) {
                            receiptImageId = await Get.find<DirectusService>()
                                .uploadFile(selectedReceiptFile!);
                          }

                          await controller.updateIncome(
                            transaction: tx,
                            amount: amount,
                            concept: conceptController.text.trim().isEmpty
                                ? tx.concept
                                : conceptController.text.trim(),
                            date: selectedDate.value,
                            categoryId: categoryId,
                            receiptImageId: receiptImageId,
                          );

                          if (Get.isBottomSheetOpen ?? false) {
                            Get.back();
                          }
                        } finally {
                          if (Get.isBottomSheetOpen ?? false) {
                            setModalState(() => isSaving.value = false);
                          } else {
                            isSaving.value = false;
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isSaving,
                        builder: (context, saving, _) {
                          if (saving) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            );
                          }

                          return const Text('Guardar cambios');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    ).whenComplete(() {
      amountController.dispose();
      conceptController.dispose();
      selectedDate.dispose();
      isSaving.dispose();
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _confirmDeleteIncome(Transaction tx) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text(
          'Anular ingreso',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta accion eliminara el ingreso del historial. Deseas continuar?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteIncome(tx);
            },
            child: const Text(
              'Anular',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
