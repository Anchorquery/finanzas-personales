import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/add_income_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/dashed_rect_painter.dart';
import '../../../core/widgets/transactions/numeric_pad.dart';

class AddIncomeView extends GetView<AddIncomeController> {
  const AddIncomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildAmountDisplay(),
                          _buildNumericBoard(),
                          const SizedBox(height: 32),
                          _buildCategorySelector(),
                          const SizedBox(height: 32),
                          _buildDetailsCard(context),
                          const SizedBox(height: 32),
                          _buildAttachmentSection(),
                          const SizedBox(height: 32),
                          _buildAccountToggle(),
                          const SizedBox(height: 48),
                          _buildSaveButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ),
          Text(
            AppL10n.of(context).addIncomeTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 60), // Spacer to center title
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Center(
      child: Column(
        children: [
          const Text(
            'AMOUNT',
            style: TextStyle(
              color: AppTheme.primaryColor,
              letterSpacing: 2,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 15),
              Obx(() {
                final amount = controller.amountString.value;
                return GestureDetector(
                  onTap: () => controller.isKeyboardVisible.toggle(),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        amount,
                        style: TextStyle(
                          color: amount == '0' || amount == '0.00'
                              ? const Color(0xFF2D3E3A)
                               : Colors.white.withValues(alpha: 0.9),
                          fontSize: 84,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -2,
                        ),
                      ),
                      // Cursor line
                      Container(
                        width: 2,
                        height: 60,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: controller.isKeyboardVisible.value
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          boxShadow: controller.isKeyboardVisible.value
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 10,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: controller.isKeyboardVisible.value ? 0 : 20,
              child: const SizedBox.shrink(),
            ),
          ),
          Obx(
            () => TextButton(
              onPressed: () => controller.isKeyboardVisible.toggle(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                controller.isKeyboardVisible.value
                    ? 'Hide Keyboard'
                    : 'Tap to Edit',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: Obx(() {
            if (controller.categories.isEmpty) {
              return const Center(
                child: Text(
                  'Cargando categorías...',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: controller.categories.map((category) {
                  final isSelected =
                      controller.selectedCategoryId.value == category.id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          controller.selectedCategoryId.value = category.id;
                        },
                        borderRadius: BorderRadius.circular(25),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getIconData(category.icon),
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                category.name,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          // Date Row
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            title: 'Date',
            onTap: () => _showDatePicker(context),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.inputFillDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Obx(
                () => Text(
                  DateFormat(
                    'EEEE, MMM d',
                    'en',
                  ).format(controller.selectedDate.value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.white.withValues(alpha: 0.05),
            height: 1,
            indent: 54,
          ),
          // Note/Concept Row
          _buildDetailRow(
            icon: Icons.description_rounded,
            title: '',
            onTap: () => _showNoteSheet(context),
            trailing: Expanded(
              child: Obx(
                () => Text(
                  controller.note.value.isEmpty
                      ? 'What is this income for?'
                      : controller.note.value,
                  style: TextStyle(
                    color: controller.note.value.isEmpty
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF06100E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.5),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 15,
                ),
              ),
              const Spacer(),
            ],
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Anexar Factura o Recibo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Optional',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDashedUploadBox(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDashedUploadBox(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        Obx(() {
          if (controller.selectedImage.value != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    Image.file(
                      controller.selectedImage.value!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => controller.selectedImage.value = null,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildDashedUploadBox({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedRectPainter(
          color: Colors.white.withValues(alpha: 0.1),
          gap: 4,
        ),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                title: 'Personal',
                isActive: controller.isPersonal.value,
                onTap: () => controller.isPersonal.value = true,
              ),
            ),
            Expanded(
              child: _buildToggleButton(
                title: 'Business',
                isActive: !controller.isPersonal.value,
                onTap: () => controller.isPersonal.value = false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumericBoard() {
    return Obx(
      () => Visibility(
        visible: controller.isKeyboardVisible.value,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NumericPad(
            onNumberPressed: (val) => controller.updateAmount(val),
            onDeletePressed: () => controller.deleteLastDigit(),
            onClearPressed: () => controller.amountString.value = '0',
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.submitIncome(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 8,
            shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
          ),
          child: controller.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Guardar Ingreso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Implementation of helper dialogs and source picking - keeping logic from before
  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) controller.selectedDate.value = picked;
  }

  void _showNoteSheet(BuildContext context) {
    final textController = TextEditingController(text: controller.note.value);
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Note',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: textController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the income...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                filled: true,
                fillColor: AppTheme.inputFillDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  controller.note.value = textController.text;
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) controller.selectedImage.value = File(image.path);
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'salary':
      case 'payments':
        return Icons.payments_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'sell':
        return Icons.sell_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
