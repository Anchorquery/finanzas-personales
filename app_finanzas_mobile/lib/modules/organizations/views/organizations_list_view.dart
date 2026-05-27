import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../controllers/organizations_controller.dart';
import 'package:app_finanzas_mobile/routes/app_routes.dart';
import 'package:app_finanzas_mobile/data/services/auth_service.dart';
import 'package:app_finanzas_mobile/core/widgets/navigation/custom_bottom_navigation_bar.dart';
import 'package:app_finanzas_mobile/core/utils/snackbar_service.dart';
import 'package:app_finanzas_mobile/core/widgets/empty_state.dart';
import 'package:app_finanzas_mobile/core/widgets/navigation/custom_bottom_nav_bar_item.dart';
import 'package:app_finanzas_mobile/l10n/gen/app_localizations.dart';

class OrganizationsListView extends GetView<OrganizationsController> {
  const OrganizationsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Compañías',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Fondo de gradiente difuminado inspirado en el diseño premium
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.indigo.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis Organizaciones',
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestiona tus entornos de trabajo',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.organizations.isEmpty) {
                      return PullableEmptyState(
                        onRefresh: controller.loadOrganizations,
                        icon: Icons.business_outlined,
                        message: AppL10n.of(context).organizationsEmpty,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.loadOrganizations,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: controller.organizations.length,
                        itemBuilder: (context, index) {
                          final org = controller.organizations[index];
                          final isActive = Get.find<AuthService>()
                                  .activeOrganizationId
                                  .value ==
                              org.id;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildOrgCard(context, org, isActive),
                          );
                        },
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Get.dialog(
                        const _CreateOrganizationDialog(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Crear Nueva Organización',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width >= 800
          ? null
          : CustomBottomNavigationBar(
        currentIndex: 4, // Settings/Organizaciones scope
        onTap: (index) {
          if (index == 0) {
            Get.offAllNamed('/home');
          } else {
             Get.offAllNamed('/home', arguments: {'initialIndex': index});
          }
        },
        items: const [
          CustomBottomNavBarItem(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
          ),
          CustomBottomNavBarItem(
            icon: Icons.analytics_outlined,
            label: 'Stats',
          ),
          CustomBottomNavBarItem(icon: Icons.add, isAddButton: true),
          CustomBottomNavBarItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Coach',
          ),
          CustomBottomNavBarItem(
            icon: Icons.settings_outlined,
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  Widget _buildOrgCard(BuildContext context, dynamic org, bool isActive) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? Colors.indigoAccent : Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              onTap: () => controller.switchOrganization(org.id),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    org.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                org.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                isActive ? 'Activa' : 'Entorno de trabajo',
                style: TextStyle(
                  color: isActive ? Colors.indigoAccent : Colors.white54,
                  fontSize: 12,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                    onPressed: () {
                      Get.toNamed(Routes.organizationDetails);
                    },
                  ),
                  if (isActive)
                    const Icon(Icons.check_circle, color: Colors.greenAccent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateOrganizationDialog extends StatefulWidget {
  const _CreateOrganizationDialog();

  @override
  State<_CreateOrganizationDialog> createState() =>
      _CreateOrganizationDialogState();
}

class _CreateOrganizationDialogState extends State<_CreateOrganizationDialog> {
  final _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      SnackbarService.showWarning('Error', 'Nombre requerido');
      return;
    }
    setState(() => _isCreating = true);
    try {
      await Get.find<OrganizationsController>().createOrganization(name);
      if (!mounted) return;
      Get.back();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      SnackbarService.showError('Error', 'No se pudo crear: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Nueva Organización',
          style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _nameController,
        style: const TextStyle(color: Colors.white),
        enabled: !_isCreating,
        decoration: const InputDecoration(
          labelText: 'Nombre de la organización',
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF6366F1)),
          ),
        ),
        autofocus: true,
        onSubmitted: (_) => _isCreating ? null : _submit(),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Get.back(),
          child:
              const Text('Cancelar', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            disabledBackgroundColor: Colors.white12,
          ),
          child: _isCreating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Crear', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
