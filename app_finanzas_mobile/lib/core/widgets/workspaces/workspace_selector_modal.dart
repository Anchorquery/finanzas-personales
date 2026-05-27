import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/workspaces/controllers/workspaces_controller.dart';
import '../../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import 'workspace_list_item.dart';

class WorkspaceSelectorModal extends StatelessWidget {
  const WorkspaceSelectorModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WorkspaceSelectorModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkspacesController>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle superior
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cambiar Espacio',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Lista de workspaces
            Obx(() {
              final workspaces = controller.visibleWorkspaces;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: workspaces
                      .map(
                        (workspace) => WorkspaceListItem(
                          workspace: workspace,
                          onTap: () {
                            if (workspace.isActive) {
                              Navigator.pop(context);
                              Get.toNamed(Routes.workspaceSettings);
                            } else {
                              controller.selectWorkspace(workspace.id);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            }),
            // Botón Crear Nuevo Espacio
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.toNamed(Routes.createWorkspace);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Crear Nuevo Espacio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
