import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/directus_service.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';
import '../controllers/expenses_controller.dart';
import '../controllers/transaction_items_controller.dart';

class AddTransactionItemsView extends StatefulWidget {
  const AddTransactionItemsView({super.key});

  @override
  State<AddTransactionItemsView> createState() => _AddTransactionItemsViewState();
}

class _AddTransactionItemsViewState extends State<AddTransactionItemsView> {
  final TransactionItemsController itemsController = Get.find();
  final ExpensesController expensesController = Get.find();
  final DirectusService _directusService = Get.find();
  
  final List<TransactionItem> _items = [];
  final _conceptController = TextEditingController(text: "Mercado");
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: "1");
  final _priceController = TextEditingController();
  
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Try to find a 'Mercado' category
    final mercadoCat = expensesController.categories.firstWhereOrNull(
      (c) => c.name.toLowerCase().contains('mercado')
    );
    if (mercadoCat != null) {
      _selectedCategoryId = mercadoCat.id;
    } else if (expensesController.categories.isNotEmpty) {
      _selectedCategoryId = expensesController.categories.first.id;
    }
  }

  @override
  void dispose() {
    _conceptController.dispose();
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addItem() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _priceController.text.isEmpty) return;

    final qty = double.tryParse(_qtyController.text) ?? 0.0;
    final unitPrice = double.tryParse(_priceController.text) ?? 0.0;
    if (qty <= 0) {
      SnackbarService.showWarning(
          'Error', 'La cantidad debe ser mayor que cero');
      return;
    }
    if (unitPrice <= 0) {
      SnackbarService.showWarning(
          'Error', 'El precio debe ser mayor que cero');
      return;
    }

    setState(() {
      _items.add(TransactionItem(
        id: '',
        name: name,
        quantity: qty,
        unitPrice: unitPrice,
        totalPrice: qty * unitPrice,
        transactionId: '',
      ));

      _nameController.clear();
      _qtyController.text = '1';
      _priceController.clear();
    });
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;
    if (_items.isEmpty) {
      SnackbarService.showError("Vacío", "Añade al menos un producto");
      return;
    }

    if (_selectedCategoryId == null) {
      SnackbarService.showError("Error", "Selecciona una categoría");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final workspaceId = Get.find<WorkspacesController>().activeWorkspaceRx.value?.id;
      final total = _items.fold(0.0, (sum, item) => sum + item.totalPrice);

      await _directusService.createTransaction(
        amount: total,
        concept: _conceptController.text,
        date: _selectedDate.toIso8601String(),
        type: 'expense',
        categoryId: _selectedCategoryId!,
        workspaceId: workspaceId,
        items: _items.map((i) => i.toJson()).toList(),
      );
      
      itemsController.loadTransactionsWithItems();
      expensesController.loadExpenses();
      _directusService.notifyDataChanged();
      if (!mounted) return;
      Get.back();
      SnackbarService.showSuccess("Éxito", "Transacción registrada con artículos");
    } catch (e) {
      SnackbarService.showError("Error", "No se pudo guardar: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Registro con Artículos'),
        backgroundColor: Colors.transparent,
      ),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                _buildAddItemForm(),
                Expanded(child: _buildItemsList()),
                _buildFooter(),
              ],
            ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _conceptController,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              labelText: 'Concepto General',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            ),
          ),
          const SizedBox(height: 16),
          // Category selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedCategoryId,
                hint: const Text('Categoría', style: TextStyle(color: Colors.white54)),
                dropdownColor: const Color(0xFF2C2C2C),
                items: expensesController.categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Date picker
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Artículos', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  Get.snackbar("Escanear", "Funcionalidad de escaneo OCR se integrará en la siguiente fase");
                },
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text('ESCANEAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Nombre del artículo',
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Cant.',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Precio Unit.',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: _addItem,
                icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(color: Colors.white)),
                    Text('${item.quantity} x ${itemsController.formatCurrency(item.unitPrice)}', 
                         style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                itemsController.formatCurrency(item.totalPrice),
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white24, size: 20),
                onPressed: () => setState(() => _items.removeAt(index)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    final total = _items.fold(0.0, (sum, item) => sum + item.totalPrice);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL ESTIMADO', style: TextStyle(color: Colors.white54, fontSize: 14)),
              Text(
                itemsController.formatCurrency(total),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'GUARDAR CON ARTÍCULOS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
