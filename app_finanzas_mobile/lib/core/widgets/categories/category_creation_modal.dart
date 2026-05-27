import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/snackbar_service.dart';
import '../../../data/services/directus_service.dart';
import '../../../modules/workspaces/controllers/workspaces_controller.dart';
import '../../../modules/transactions/controllers/transactions_controller.dart';

class CategoryCreationModal extends StatefulWidget {
  const CategoryCreationModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategoryCreationModal(),
    );
  }

  @override
  State<CategoryCreationModal> createState() => _CategoryCreationModalState();
}

class _CategoryCreationModalState extends State<CategoryCreationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _directusService = Get.find<DirectusService>();
  final _workspacesController = Get.find<WorkspacesController>();
  // We assume TransactionsController might not be in context if opened from settings
  // But for now it's mainly for Add Transaction
  TransactionsController? get _transactionsController {
    if (Get.isRegistered<TransactionsController>()) {
      return Get.find<TransactionsController>();
    }
    return null;
  }

  String _selectedType = 'expense';
  Color _selectedColor = const Color(0xFF2196F3);
  String _selectedIcon = 'category';
  bool _isLoading = false;

  final List<Color> _colors = [
    const Color(0xFFF44336), // Red
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF2196F3), // Blue
    const Color(0xFF009688), // Teal
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
  ];

  final List<String> _icons = [
    'category',
    'restaurant',
    'directions_car',
    'home',
    'shopping_bag',
    'medical_services',
    'school',
    'movie',
    'flight',
    'pets',
    'sports_esports',
    'fitness_center',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check validation of workspace
    final workspace = _workspacesController.activeWorkspace;
    if (workspace == null) {
      SnackbarService.showError(
        'Error',
        'Debes seleccionar un espacio de trabajo primero',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _directusService.createCategory(
        name: _nameController.text.trim(),
        type: _selectedType,
        color: '#${_selectedColor.toARGB32().toRadixString(16).substring(2)}',
        icon: _selectedIcon,
        workspaceId: workspace.id,
      );

      // Refresh categories in TransactionsController
      _transactionsController?.loadCategories();

      Get.back(); // Close modal
      SnackbarService.showSuccess('Éxito', 'Categoría creada');
    } catch (e) {
      SnackbarService.showError('Error', 'No se pudo crear la categoría: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildIcon(String iconName, bool isSelected) {
    IconData iconData = Icons.category;
    switch (iconName) {
      case 'restaurant':
        iconData = Icons.restaurant;
        break;
      case 'directions_car':
        iconData = Icons.directions_car;
        break;
      case 'home':
        iconData = Icons.home;
        break;
      case 'shopping_bag':
        iconData = Icons.shopping_bag;
        break;
      case 'medical_services':
        iconData = Icons.medical_services;
        break;
      case 'school':
        iconData = Icons.school;
        break;
      case 'movie':
        iconData = Icons.movie;
        break;
      case 'flight':
        iconData = Icons.flight;
        break;
      case 'pets':
        iconData = Icons.pets;
        break;
      case 'sports_esports':
        iconData = Icons.sports_esports;
        break;
      case 'fitness_center':
        iconData = Icons.fitness_center;
        break;
    }

    return Icon(
      iconData,
      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
      size: 28,
    );
  }

  Widget _buildTypeSegment(String type, String label, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nueva Categoría',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type Selector
              Row(
                children: [
                  Expanded(
                    child: _buildTypeSegment('expense', 'Gasto', Colors.red),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeSegment('income', 'Ingreso', Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Color Selector
              Text('Color', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Icon Selector
              Text('Ícono', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final iconName = _icons[index];
                    final isSelected = _selectedIcon == iconName;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = iconName),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: _buildIcon(iconName, isSelected),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear Categoría'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
