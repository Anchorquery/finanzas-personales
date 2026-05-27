import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/snackbar_service.dart';
import '../../accounts/views/account_detail_view.dart';
import 'currency_settings_view.dart';
import '../controllers/workspace_settings_controller.dart';

class WorkspaceSettingsView extends GetView<WorkspaceSettingsController> {
  const WorkspaceSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Definición de colores según la imagen
    const backgroundColor = Color(0xFF0F172A);
    const cardColor = Color(0xFF1E293B);
    const primaryBlue = Color(0xFF3B82F6);
    const textWhite = Colors.white;
    const textGrey = Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'CONFIGURACIÓN',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: textWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: primaryBlue),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Obx(() {
        final ws = controller.workspace.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // 1. Workspace Header (Icon + Name + ID)
              _buildWorkspaceHeader(ws, primaryBlue, textWhite, textGrey),

              const SizedBox(height: 30),

              // 2. Members Section (Link)
              _buildMembersSection(primaryBlue, cardColor, textWhite, textGrey),

              const SizedBox(height: 15),

              // 3. Currency Section (Link)
              _buildCurrencySection(
                primaryBlue,
                cardColor,
                textWhite,
                textGrey,
              ),

              const SizedBox(height: 30),

              // 4. AI Preferences
              _buildSectionTitle('PREFERENCIAS IA', textGrey),
              const SizedBox(height: 10),
              _buildAiPreferences(cardColor, textWhite, textGrey, primaryBlue),

              const SizedBox(height: 30),

              // 5. General Section
              _buildSectionTitle('GENERAL', textGrey),
              const SizedBox(height: 10),
              _buildGeneralSection(cardColor, textWhite, textGrey, ws),

              const SizedBox(height: 30),

              _buildSectionTitle('CUENTAS', textGrey),
              const SizedBox(height: 10),
              _buildAccountsSection(cardColor, textWhite, textGrey),

              const SizedBox(height: 40),

              // 6. Delete Button
              _buildDeleteButton(),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWorkspaceHeader(
    dynamic ws,
    Color primaryKey,
    Color textWhite,
    Color textGrey,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showEditWorkspaceDialog(Get.context!, ws),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(ws.icon, color: Colors.white, size: 36),
              ),
              Positioned(
                bottom: -5,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 3,
                    ),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _showEditWorkspaceDialog(Get.context!, ws),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ws.name,
                style: TextStyle(
                  color: textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.edit,
                color: textGrey.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'WORKSPACE ID: #${ws.id.toString().toUpperCase().substring(0, 6)}',
          style: TextStyle(
            color: textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  void _showEditWorkspaceDialog(BuildContext context, dynamic ws) {
    final nameController = TextEditingController(text: ws.name);
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Editar Espacio',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre del espacio',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3B82F6)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                SnackbarService.showWarning('Error', 'Nombre requerido');
                return;
              }
              controller.updateWorkspaceName(name);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(
    Color primaryBlue,
    Color cardColor,
    Color textWhite,
    Color textGrey,
  ) {
    return Obx(() {
      final members = controller.orgMembers;
      final wsMembers = controller.workspaceMembers;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Miembros del Workspace',
                  style: TextStyle(
                    color: textWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${wsMembers.length} miembros',
                  style: TextStyle(color: textGrey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lista de miembros de la org con indicador de acceso
            ...members.map((member) {
              final user = member['user'];
              if (user == null) return const SizedBox.shrink();
              final userId = user['id']?.toString() ?? '';
              final name = user['first_name']?.toString() ?? 'Usuario';
              final email = user['email']?.toString() ?? '';
              final hasAccess = wsMembers.contains(userId);
              final isOwner = userId == controller.workspace.value.userId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryBlue.withValues(alpha: 0.2),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(name, style: TextStyle(color: textWhite, fontSize: 14)),
                              if (isOwner) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryBlue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Dueño', style: TextStyle(color: primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          Text(email, style: TextStyle(color: textGrey, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (!isOwner)
                      Switch(
                        value: hasAccess,
                        activeTrackColor: primaryBlue,
                        onChanged: (value) {
                          if (value) {
                            controller.addMemberToWorkspace(userId);
                          } else {
                            controller.removeMemberFromWorkspace(userId);
                          }
                        },
                      ),
                  ],
                ),
              );
            }),
            if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Invita miembros desde la organización para compartir este workspace',
                  style: TextStyle(color: textGrey, fontSize: 13),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildCurrencySection(
    Color primaryBlue,
    Color cardColor,
    Color textWhite,
    Color textGrey,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF334155).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.currency_exchange, color: textGrey),
        ),
        title: Text(
          'Moneda y Tasas (Venezuela)',
          style: TextStyle(
            color: textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Obx(
          () => Text(
            '${controller.selectedCurrency.value} / VES',
            style: TextStyle(color: textGrey, fontSize: 12),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: textGrey, size: 20),
        onTap: () => Get.to(
          () => const CurrencySettingsView(),
          arguments: controller.workspace.value,
        ),
      ),
    );
  }

  Widget _buildAiPreferences(
    Color cardColor,
    Color textWhite,
    Color textGrey,
    Color activeColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildToggleTile(
            title: 'Análisis Predictivo',
            subtitle: 'Insights mensuales automáticos',
            icon: Icons.auto_awesome,
            iconColor: const Color(0xFF8B5CF6), // Purple
            value: controller.aiPredictiveAnalysis.value,
            onChanged: (val) =>
                controller.updateAIPreference('ai_predictive_analysis', val),
            textWhite: textWhite,
            textGrey: textGrey,
            activeColor: activeColor,
          ),
          Divider(
            color: textGrey.withValues(alpha: 0.1),
            height: 1,
            indent: 60,
          ),
          _buildToggleTile(
            title: 'Categorización IA',
            subtitle: 'Etiquetar gastos nuevos',
            icon: Icons.smart_toy_outlined,
            iconColor: const Color(0xFF6366F1), // Indigo
            value: controller.aiCategorization.value,
            onChanged: (val) =>
                controller.updateAIPreference('ai_categorization', val),
            textWhite: textWhite,
            textGrey: textGrey,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(
    Color cardColor,
    Color textWhite,
    Color textGrey,
    dynamic ws,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF334155).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.attach_money, color: textGrey),
        ),
        title: Text(
          'Moneda Principal',
          style: TextStyle(
            color: textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${controller.selectedCurrency.value} (\$)',
              style: TextStyle(color: textGrey, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: textGrey, size: 20),
          ],
        ),
        onTap: () => _showCurrencyPicker(Get.context!),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.deleteWorkspace,
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Eliminar Espacio'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: BorderSide(
                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.05),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Esta acción no se puede deshacer. Se perderán todos los datos financieros y configuraciones de IA asociadas.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAccountsSection(
    Color cardColor,
    Color textWhite,
    Color textGrey,
  ) {
    return Obx(() {
      if (controller.accounts.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'No hay cuentas configuradas en este workspace.',
            style: TextStyle(color: textGrey, fontSize: 13),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: controller.accounts.map((account) {
            final isLast = controller.accounts.last.id == account.id;
            return InkWell(
              onTap: () => Get.to(() => AccountDetailView(account: account)),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isLast
                          ? Colors.transparent
                          : textGrey.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: textGrey,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: TextStyle(
                              color: textWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Saldo inicial: ${CurrencyUtils.formatAmount(account.initialBalance, account.currency)}',
                            style: TextStyle(
                              color: textGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Saldo actual: ${CurrencyUtils.formatAmount(account.currentBalance, account.currency)}',
                            style: TextStyle(color: textGrey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Apertura: ${controller.formatDate(account.createdAt)}',
                            style: TextStyle(color: textGrey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: textGrey, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor, // Added icon color
    required bool value,
    required Function(bool) onChanged,
    required Color textWhite,
    required Color textGrey,
    required Color activeColor,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF334155).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textWhite,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: textGrey, fontSize: 13)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: activeColor,
      activeTrackColor: activeColor.withValues(alpha: 0.4),
      inactiveThumbColor: textGrey,
      inactiveTrackColor: const Color(0xFF334155),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    // Reusing logic but styling for dark theme
    final currencies = ['USD', 'EUR', 'GBP', 'MXN', 'COP', 'CLP', 'ARS'];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Moneda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final c = currencies[index];
                  return ListTile(
                    title: Text(c, style: const TextStyle(color: Colors.white)),
                    trailing: controller.selectedCurrency.value == c
                        ? const Icon(Icons.check, color: Color(0xFF3B82F6))
                        : null,
                    onTap: () {
                      controller.updateCurrency(c);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
