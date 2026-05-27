import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/transactions/numeric_pad.dart';
import '../../../core/widgets/workspaces/workspace_selector_modal.dart';
import '../../../core/widgets/categories/category_creation_modal.dart';
import '../../workspaces/controllers/workspaces_controller.dart';
import '../controllers/transactions_controller.dart';

import '../../../core/utils/icon_utils.dart';
import '../../../core/widgets/transactions/voice_input_sheet.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../data/models/finance/transaction_template.dart';
import '../controllers/templates_controller.dart';

class AddTransactionView extends GetView<TransactionsController> {
  const AddTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final workspacesController = Get.find<WorkspacesController>();
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    const accentGreen = AppTheme.accentGreen;
    final cardColor = Theme.of(context).cardTheme.color ?? AppTheme.surfaceDark;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Get.back(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  Obx(() => Text(
                    controller.editingId.value != null
                        ? 'Editar Transacción'
                        : 'Nueva Transacción',
                    style: TextStyle(
                      color:
                          Theme.of(context).textTheme.titleLarge?.color ??
                          Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                  IconButton(
                    tooltip: 'Dictar transacción',
                    icon: const Icon(Icons.mic_none_rounded,
                        color: AppTheme.accentAI),
                    onPressed: () => VoiceInputSheet.show(context),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          AppTheme.accentAI.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),

            // Amount Display
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        r'$',
                        style: TextStyle(
                          fontSize: 32,
                          color: accentGreen,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => Text(
                          controller.amountString.value == '0'
                              ? '0'
                              : controller.amountString.value,
                          style: TextStyle(
                            fontSize: 62,
                            fontWeight: FontWeight.bold,
                            color: accentGreen,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Ingresando monto',
                          style: TextStyle(
                            color: accentGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => GestureDetector(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _showNoteInput(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    controller.note.value.isEmpty
                                        ? Icons.add_circle_outline
                                        : Icons.edit_note,
                                    size: 14,
                                    color: accentGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    controller.note.value.isEmpty
                                        ? 'Añadir nota'
                                        : controller.note.value,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => controller.pickImage(),
                            icon: const Icon(
                              Icons.attach_file,
                              size: 20,
                              color: Colors.white70,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.05,
                              ),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.selectedImage.value != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(controller.selectedImage.value!.path),
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => controller.removeImage(),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),

            // Scrollable form part to prevent overflow
            // Form part
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  // Categories Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CATEGORÍA',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showCategorySelector(context),
                          child: const Text(
                            'Ver todas',
                            style: TextStyle(color: accentGreen, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 85,
                    child: Obx(() {
                      if (controller.isLoadingCategories.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: accentGreen),
                        );
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.categories.length,
                        itemBuilder: (context, index) {
                          final cat = controller.categories[index];
                          final isSelected =
                              controller.selectedCategoryId.value == cat.id;
                          return GestureDetector(
                            onTap: () =>
                                controller.selectedCategoryId.value = cat.id,
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? accentGreen
                                          : cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: accentGreen.withValues(
                                                  alpha: 0.3,
                                                ),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Icon(
                                      cat.icon != null
                                          ? IconUtils.getIconByName(cat.icon!)
                                          : Icons.category,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cat.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white38,
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Date & Workspace cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSelectorCard(
                            label: 'FECHA',
                            value: Obx(
                              () => Text(
                                DateFormat(
                                  'E, d MMM',
                                  'es',
                                ).format(controller.selectedDate.value),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            icon: Icons.calendar_today_outlined,
                            onTap: () => _showDatePicker(context),
                            cardColor: cardColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSelectorCard(
                            label: 'WORKSPACE',
                            value: Obx(() {
                              final active =
                                  workspacesController.activeWorkspaceRx.value;
                              return Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      active?.name ?? 'Personal',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            icon: Icons.keyboard_arrow_down,
                            onTap: () => _showWorkspaceSelector(context),
                            cardColor: cardColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Numeric Keyboard
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: NumericPad(
                      onNumberPressed: (val) => controller.appendDigit(val),
                      onDeletePressed: () => controller.deleteDigit(),
                      onClearPressed: () => controller.clearAmount(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitTransaction(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: bgColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? CircularProgressIndicator(color: bgColor)
                        : Text(
                            controller.editingId.value != null
                                ? 'Actualizar Transacción'
                                : 'Guardar Transacción',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            // Save as template (only on create)
            Obx(() {
              if (controller.editingId.value != null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton.icon(
                  onPressed: () => _saveAsTemplate(context),
                  icon: const Icon(Icons.star_border_rounded,
                      color: Colors.white54, size: 18),
                  label: const Text('Guardar como plantilla rápida',
                      style: TextStyle(color: Colors.white54)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _saveAsTemplate(BuildContext context) {
    final amount = double.tryParse(controller.amountString.value) ?? 0.0;
    if (amount <= 0) {
      SnackbarService.showWarning(
          'Plantilla', 'Captura un monto válido primero.');
      return;
    }
    final labelCtrl = TextEditingController(
      text: controller.note.value.isEmpty
          ? (controller.selectedCategory?.name ?? 'Plantilla')
          : controller.note.value,
    );
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Nueva plantilla rápida',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: labelCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Etiqueta',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                labelCtrl.dispose();
                Get.back();
              },
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final label = labelCtrl.text.trim();
              if (label.isEmpty) return;
              if (!Get.isRegistered<TemplatesController>()) {
                Get.put(TemplatesController());
              }
              final cat = controller.selectedCategory;
              final wsId = Get.find<WorkspacesController>().activeWorkspace?.id;
              if (wsId == null) {
                Get.back();
                return;
              }
              Get.find<TemplatesController>().add(
                TransactionTemplate(
                  id: TemplatesController.newId(),
                  label: label,
                  amount: amount,
                  type: controller.selectedType.value,
                  workspaceId: wsId,
                  concept: controller.note.value.isEmpty
                      ? null
                      : controller.note.value,
                  categoryId: cat?.id,
                  categoryName: cat?.name,
                ),
              );
              labelCtrl.dispose();
              Get.back();
              SnackbarService.showSuccess('Plantilla',
                  'Guardada — aparecerá en accesos rápidos.');
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorCard({
    required String label,
    required Widget value,
    required IconData icon,
    required VoidCallback onTap,
    required Color cardColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: value),
                Icon(icon, color: Colors.white38, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkspaceSelector(BuildContext context) {
    Get.bottomSheet(
      const WorkspaceSelectorModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showCategorySelector(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF16251E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Categoría',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppTheme.accentGreen),
              ),
              title: const Text('Crear nueva categoría'),
              onTap: () {
                Get.back(); // Close selector
                Get.bottomSheet(
                  const CategoryCreationModal(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Obx(
                () => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final cat = controller.categories[index];
                    final isSelected =
                        controller.selectedCategoryId.value == cat.id;
                    return InkWell(
                      onTap: () {
                        controller.selectedCategoryId.value = cat.id;
                        Get.back();
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.accentGreen.withValues(alpha: 0.2)
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.shade100),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: AppTheme.accentGreen,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              cat.icon != null
                                  ? IconUtils.getIconByName(cat.icon!)
                                  : Icons.category,
                              color: isSelected
                                  ? AppTheme.accentGreen
                                  : (isDark ? Colors.white70 : Colors.black54),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteInput(BuildContext context) {
    Get.bottomSheet(
      _NoteInputSheet(
        initial: controller.note.value,
        onChanged: (v) => controller.note.value = v,
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final firstDate = DateTime(2020);
    final lastDate = DateTime(2030);
    var initial = controller.selectedDate.value;
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date != null) {
      controller.selectedDate.value = date;
    }
  }
}

class _NoteInputSheet extends StatefulWidget {
  const _NoteInputSheet({required this.initial, required this.onChanged});
  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_NoteInputSheet> createState() => _NoteInputSheetState();
}

class _NoteInputSheetState extends State<_NoteInputSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: widget.initial.length),
      );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF16251E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Añadir Nota o Concepto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ej. Compra de supermercado...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => Get.back(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Listo'),
            ),
          ],
        ),
      ),
    );
  }
}
