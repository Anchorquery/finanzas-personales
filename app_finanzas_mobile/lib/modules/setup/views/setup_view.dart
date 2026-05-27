import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/setup_controller.dart';
import '../../../data/models/workspace.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';

class SetupView extends GetView<SetupController> {
  const SetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundDark,
              AppTheme.backgroundDark.withValues(alpha: 0.8),
              const Color(0xFF1E293B),
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildStepContent(),
                  ),
                ),
                _buildFooter(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final stepLabels = [
      'Organización',
      'Área de Trabajo',
      'Saldo Inicial',
      'Ingresos Esperados',
      'Categorías',
      'Presupuestos',
      'Invitaciones',
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            AppL10n.of(context).setupTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Paso ${controller.currentStep.value + 1} de ${SetupController.totalSteps} — ${stepLabels[controller.currentStep.value]}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(SetupController.totalSteps, (index) {
              final isPast = index < controller.currentStep.value;
              final isCurrent = index == controller.currentStep.value;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isPast || isCurrent
                        ? AppTheme.primaryColor
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (controller.currentStep.value) {
      case 0:
        return _stepOrganization();
      case 1:
        return _stepWorkspace();
      case 2:
        return _stepAccount();
      case 3:
        return _stepIncomePlans();
      case 4:
        return _stepTemplate();
      case 5:
        return _stepBudgetPlans();
      case 6:
        return _stepInvitations();
      default:
        return const SizedBox.shrink();
    }
  }

  // PASO 0: Organización
  Widget _stepOrganization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'Tu Organización',
          'Define el nombre de tu hogar o empresa.',
        ),
        const SizedBox(height: 32),
        _buildTextField(
          controller: controller.orgNameController,
          label: 'Nombre de la Organización',
          icon: Icons.business,
        ),
        const SizedBox(height: 40),
        const Text(
          'Configuración IA',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => SwitchListTile(
            title: const Text(
              'Habilitar Funciones IA',
              style: TextStyle(color: Colors.white),
            ),
            value: controller.aiEnabled.value,
            onChanged: (val) => controller.aiEnabled.value = val,
            activeThumbColor: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.geminiKeyController,
          label: 'Gemini API Key (Opcional)',
          icon: Icons.vpn_key,
          isPassword: true,
        ),
      ],
    );
  }

  // PASO 1: Workspace
  Widget _stepWorkspace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'Área de Trabajo',
          'Elige cómo organizarás tus cuentas.',
        ),
        const SizedBox(height: 32),
        _buildTextField(
          controller: controller.workspaceNameController,
          label: 'Nombre del Workspace',
          icon: Icons.workspaces_outline,
        ),
        const SizedBox(height: 24),
        const Text(
          'Tipo de Workspace',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Wrap(
            spacing: 12,
            children: WorkspaceType.values.map((type) {
              final isSelected = controller.selectedWorkspaceType.value == type;
              return ChoiceChip(
                label: Text(type.name.toUpperCase()),
                selected: isSelected,
                onSelected: (_) =>
                    controller.selectedWorkspaceType.value = type,
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Moneda Principal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(
          () => DropdownButtonFormField<String>(
            initialValue: controller.selectedCurrency.value,
            dropdownColor: AppTheme.backgroundDark,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Moneda', Icons.payments_outlined),
            items: [
              'USD',
              'VES',
              'EUR',
              'COP',
            ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => controller.selectedCurrency.value = val!,
          ),
        ),
      ],
    );
  }

  // PASO 2: Saldo Inicial
  Widget _stepAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'Saldo Inicial',
          '¿Cuánto dinero tienes actualmente? Este paso es obligatorio.',
        ),
        const SizedBox(height: 32),
        _buildTextField(
          controller: controller.accountNameController,
          label: 'Nombre de la Cuenta *',
          icon: Icons.account_balance_wallet_outlined,
          hint: 'Ej: Efectivo, Banco...',
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: controller.initialBalanceController,
          label: 'Saldo Actual *',
          icon: Icons.numbers,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          hint: '0.00',
        ),
      ],
    );
  }

  // PASO 3: Ingresos Esperados
  Widget _stepIncomePlans() {
    final cur = controller.selectedCurrency.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'Ingresos Esperados',
          'Ingresos que recibes mensualmente (Obligatorio agregar al menos uno).',
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildTextField(
                controller: controller.incomeNameController,
                label: 'Nombre del ingreso',
                icon: Icons.label_outline,
                hint: 'Ej: Salario',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: controller.incomeAmountController,
                label: 'Monto mensual ($cur)',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.addIncomePlan,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Obx(() {
          if (controller.incomePlans.isEmpty) {
            return _buildEmptyState(
              icon: Icons.money_off,
              message: 'Añade tu fuente de ingresos para continuar.',
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: controller.incomePlans.length,
            itemBuilder: (context, index) {
              final plan = controller.incomePlans[index];
              return ListTile(
                title: Text(
                  plan.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${plan.amount} $cur',
                  style: const TextStyle(color: AppTheme.accentGreen),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => controller.removeIncomePlan(index),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  // PASO 4: Plantilla de Categorías
  Widget _stepTemplate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'Plantilla',
          'Elige un conjunto de categorías iniciales.',
        ),
        const SizedBox(height: 32),
        _buildTemplateCard(
          'Estándar',
          'Más común: Comida, Hogar...',
          'standard',
          Icons.person,
        ),
        _buildTemplateCard(
          'Estudiante',
          'Enfoque educación y ocio.',
          'student',
          Icons.school,
        ),
        _buildTemplateCard(
          'Negocio',
          'Gastos operativos.',
          'business',
          Icons.work,
        ),
      ],
    );
  }

  // PASO 5: Presupuestos de Gasto
  Widget _stepBudgetPlans() {
    final cur = controller.selectedCurrency.value;
    final suggested = controller.suggestedBudgetPlans;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'Límites de Gasto',
          'Puedes dejarlos vacíos y usar los montos sugeridos según tu ingreso base.',
        ),
        const SizedBox(height: 24),
        ...controller.budgetPlans.keys.map((cat) {
          final hint = (suggested[cat] ?? 0).toStringAsFixed(2);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              onChanged: (val) => controller.updateBudget(cat, val),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                '$cat ($cur)',
                Icons.shopping_bag_outlined,
              ).copyWith(hintText: hint),
            ),
          );
        }),
      ],
    );
  }

  // PASO 6: Invitaciones
  Widget _stepInvitations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'Invita a tu equipo',
          'Comparte este espacio con otros integrantes. (Opcional)',
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.inviteEmailController,
                label: 'Email',
                icon: Icons.person_add,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: controller.addInvitation,
              icon: const Icon(Icons.send, color: AppTheme.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Obx(
          () => Column(
            children: controller.invitedEmails
                .map(
                  (e) => ListTile(
                    title: Text(e, style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white54),
                      onPressed: () => controller.removeInvitation(e),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // --- WIDGETS AUX ---
  Widget _buildStepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      prefixIcon: Icon(icon, color: AppTheme.primaryColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
    );
  }

  Widget _buildTemplateCard(
    String title,
    String desc,
    String value,
    IconData icon,
  ) {
    return Obx(() {
      final isSelected = controller.selectedTemplate.value == value;
      return GestureDetector(
        onTap: () => controller.selectTemplate(value),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.white38,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        children: [
          Icon(icon, color: Colors.white24, size: 40),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final isLast =
        controller.currentStep.value == SetupController.totalSteps - 1;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (controller.currentStep.value > 0)
            TextButton(
              onPressed: controller.previousStep,
              child: const Text(
                'Atrás',
                style: TextStyle(color: Colors.white60),
              ),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : (isLast ? controller.finishSetup : controller.nextStep),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(isLast ? 'Finalizar' : 'Siguiente'),
          ),
        ],
      ),
    );
  }
}
