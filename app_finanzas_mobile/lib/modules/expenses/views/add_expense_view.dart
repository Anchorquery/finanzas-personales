import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/directus_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/expenses_controller.dart';
import '../../workspaces/controllers/workspaces_controller.dart';

class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final ExpensesController controller = Get.find();
  final DirectusService _directusService = Get.find();

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _conceptController = TextEditingController();
  final _descriptionController = TextEditingController();

  Category? _selectedCategory;
  Debt? _selectedDebt;
  DateTime _selectedDate = DateTime.now();
  File? _receiptImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      SnackbarService.showError("Campo requerido", "Por favor selecciona una categoría");
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? receiptId;
      if (_receiptImage != null) {
        receiptId = await _directusService.uploadFile(_receiptImage!);
      }

      final workspaceId = Get.find<WorkspacesController>().activeWorkspace?.id;
      if (workspaceId == null) throw Exception("No sequence workspace selected");

      final transactionAmount = double.parse(_amountController.text);
      final transactionConcept = _conceptController.text;
      
      await _directusService.createTransaction(
        amount: transactionAmount,
        concept: transactionConcept,
        date: _selectedDate.toIso8601String().split('T')[0],
        type: 'expense',
        categoryId: _selectedCategory!.id,
        workspaceId: workspaceId,
        receiptImageId: receiptId,
        debtId: _selectedDebt?.id,
      );

      // If linked to a debt, update the debt's remaining amount
      if (_selectedDebt != null) {
        final newRemaining = _selectedDebt!.remainingAmount - transactionAmount;
        await _directusService.updateDebt(_selectedDebt!.id, {
          'remaining_amount': newRemaining < 0 ? 0 : newRemaining,
          'status': (newRemaining <= 0) ? 'PAGADO' : 'PENDIENTE',
        });
      }

      controller.loadExpenses();
      Get.back();
      SnackbarService.showSuccess("Éxito", "Gasto registrado correctamente");
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo guardar el gasto: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppL10n.of(context).addExpenseTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountField(),
                    const SizedBox(height: 32),
                    _buildTextField(_conceptController, 'Concepto', Icons.edit_note, true),
                    const SizedBox(height: 20),
                    _buildCategorySelector(),
                    const SizedBox(height: 20),
                    _buildDebtSelector(),
                    const SizedBox(height: 20),
                    _buildDatePicker(),
                    const SizedBox(height: 20),
                    _buildTextField(_descriptionController, 'Descripción (Opcional)', Icons.description_outlined, false),
                    const SizedBox(height: 32),
                    _buildImagePicker(),
                    const SizedBox(height: 48),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Monto', style: TextStyle(color: Colors.white54, fontSize: 14)),
          TextFormField(
            controller: _amountController,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.errorColor, fontSize: 48, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixText: '\$ ',
              prefixStyle: TextStyle(color: AppTheme.errorColor, fontSize: 48),
            ),
            validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool required) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: AppTheme.accentColor),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: required ? (val) => val == null || val.isEmpty ? 'Requerido' : null : null,
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<Category>(
          isExpanded: true,
          hint: const Text('Categoría', style: TextStyle(color: Colors.white54)),
          value: _selectedCategory,
          dropdownColor: const Color(0xFF2C2C2C),
          items: controller.categories.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(cat.name, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      )),
    );
  }

  Widget _buildDebtSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<Debt?>(
          isExpanded: true,
          hint: const Text('Vincular a deuda (Opcional)', style: TextStyle(color: Colors.white54)),
          value: _selectedDebt,
          dropdownColor: const Color(0xFF2C2C2C),
          items: [
            const DropdownMenuItem<Debt?>(
              value: null,
              child: Text('Sin deuda', style: TextStyle(color: Colors.white54)),
            ),
            ...controller.debts.map((debt) {
              return DropdownMenuItem<Debt?>(
                value: debt,
                child: Text(debt.name, style: const TextStyle(color: Colors.white)),
              );
            }),
          ],
          onChanged: (val) => setState(() => _selectedDebt = val),
        ),
      )),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.accentColor),
            const SizedBox(width: 16),
            Text(
              DateFormat('yyyy-MM-dd').format(_selectedDate),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: InkWell(
        onTap: _pickImage,
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12, style: BorderStyle.solid),
          ),
          child: _receiptImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_receiptImage!, fit: BoxFit.cover),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 32),
                    SizedBox(height: 8),
                    Text('Subir recibo (Opcional)', style: TextStyle(color: Colors.white54)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: _saveExpense,
        child: const Text('GUARDAR GASTO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }
}
