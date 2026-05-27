import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/savings_controller.dart';

class CreateSavingGoalView extends StatefulWidget {
  const CreateSavingGoalView({super.key});

  @override
  State<CreateSavingGoalView> createState() => _CreateSavingGoalViewState();
}

class _CreateSavingGoalViewState extends State<CreateSavingGoalView> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final controller = Get.find<SavingsController>();
  
  String _selectedIcon = '💰';
  DateTime? _selectedDate;
  
  final List<String> _icons = ['💰', '🏠', '🚗', '✈️', '📈', '🎓', '🎁', '🏥'];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppL10n.of(context).createSavingTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSectionLabel("CHOOSE AN ICON"),
                const SizedBox(height: 16),
                _buildIconSelector(),
                
                const SizedBox(height: 32),
                _buildSectionLabel("Goal Name"),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _nameController,
                  hint: "e.g. Trip to Paris",
                ),
                
                const SizedBox(height: 24),
                _buildSectionLabel("Target Amount"),
                const SizedBox(height: 12),
                _buildAmountField(),
                
                const SizedBox(height: 24),
                _buildSectionLabel("Target Date"),
                const SizedBox(height: 12),
                _buildDatePicker(),
                
                const SizedBox(height: 120), // Space for bottom button
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: _buildCreateButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildIconSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _icons.length,
        itemBuilder: (context, index) {
          final icon = _icons[index];
          final isSelected = _selectedIcon == icon;
          return GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.2) : AppTheme.surfaceDark,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: AppTheme.primaryColor, width: 2) : Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Text(
              "\$",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          hintText: "0.00",
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              _selectedDate == null ? "Select Target Date" : DateFormat('MMMM yyyy').format(_selectedDate!),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 8,
          shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
        ),
        child: const Text(
          "Create Goal",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceDark,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: AppTheme.backgroundDark),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitForm() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text);
    
    if (name.isEmpty) {
      Get.snackbar("Error", "Please enter a name for your goal", 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    
    if (amount == null || amount <= 0) {
      Get.snackbar("Error", "Please enter a valid target amount", 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // El icono y fecha por ahora son decorativos según el esquema actual de Directus,
    // pero se pasan a la lógica del controlador si este decidiera guardarlos en campos extra.
    controller.submitCreateGoal(
      name: name,
      amount: amount,
      icon: _selectedIcon,
      targetDate: _selectedDate,
    );
  }
}
