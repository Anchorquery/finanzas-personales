import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/directus_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';
import '../controllers/debts_controller.dart';

class AddDebtView extends StatefulWidget {
  const AddDebtView({super.key});

  @override
  State<AddDebtView> createState() => _AddDebtViewState();
}

class _AddDebtViewState extends State<AddDebtView> {
  final DebtsController controller = Get.find();
  final DirectusService _directusService = Get.find();
  
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _interestController = TextEditingController(text: "0");
  
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  Future<void> _saveDebt() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _amountController.text.isEmpty) {
      SnackbarService.showError("Error", "Completa los campos obligatorios");
      return;
    }
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      SnackbarService.showError(
          "Error", "El monto debe ser mayor que cero.");
      return;
    }
    final interest = double.tryParse(_interestController.text) ?? 0.0;
    if (interest < 0) {
      SnackbarService.showError(
          "Error", "El interés no puede ser negativo.");
      return;
    }
    if (_dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      SnackbarService.showError("Error", "La fecha ya pasó.");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final workspaceId =
          Get.find<WorkspacesController>().activeWorkspaceRx.value?.id;

      final debt = Debt(
        id: '',
        name: name,
        totalAmount: amount,
        remainingAmount: amount,
        interestRate: interest,
        dueDate: _dueDate,
        status: 'PENDIENTE',
        workspaceId: workspaceId ?? '',
      );

      await _directusService.createDebt(debt);
      
      controller.loadDebts();
      Get.back();
      SnackbarService.showSuccess("Éxito", "Deuda registrada correctamente");
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo guardar: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Nueva Deuda'),
        backgroundColor: Colors.transparent,
      ),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Información General'),
                  const SizedBox(height: 16),
                  _buildTextField(_nameController, 'Nombre de la deuda', Icons.label_outline),
                  const SizedBox(height: 16),
                  _buildTextField(_amountController, 'Monto Total', Icons.attach_money, isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField(_interestController, 'Interés (%)', Icons.percent, isNumber: true),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Fecha de vencimiento'),
                  const SizedBox(height: 16),
                  _buildDatePicker(),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveDebt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('REGISTRAR DEUDA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (date != null) setState(() => _dueDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
            const SizedBox(width: 16),
            Text(
              DateFormat('dd MMMM yyyy').format(_dueDate),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
