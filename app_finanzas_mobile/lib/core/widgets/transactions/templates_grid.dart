import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/finance/transaction_template.dart';
import '../../../modules/transactions/controllers/templates_controller.dart';

/// Horizontal grid of saved quick-action templates.
/// Tap → 1-tap register. Long-press → delete confirm.
class TemplatesGrid extends StatelessWidget {
  const TemplatesGrid({
    super.key,
    this.onTapTemplate,
    this.maxItems = 8,
  });

  /// If provided, called instead of auto-registering — used to pre-fill form.
  final void Function(TransactionTemplate)? onTapTemplate;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TemplatesController>()) {
      Get.put(TemplatesController());
    }
    final controller = Get.find<TemplatesController>();

    return Obx(() {
      final items = controller.templates.take(maxItems).toList();
      if (items.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          separatorBuilder: (ctx, idx) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final t = items[i];
            return _TemplateChip(
              template: t,
              onTap: () {
                if (onTapTemplate != null) {
                  onTapTemplate!(t);
                } else {
                  controller.quickRegister(t);
                }
              },
              onLongPress: () => _confirmDelete(context, controller, t),
            );
          },
        ),
      );
    });
  }

  void _confirmDelete(
      BuildContext context, TemplatesController c, TransactionTemplate t) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Eliminar plantilla',
            style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "${t.label}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              c.remove(t.id);
              Get.back();
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
    required this.template,
    required this.onTap,
    required this.onLongPress,
  });

  final TransactionTemplate template;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isIncome = template.type == 'income';
    final accent = isIncome ? AppTheme.accentGreen : AppTheme.accentRed;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(template.icon ?? (isIncome ? '↑' : '↓'),
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    template.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '\$${template.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
