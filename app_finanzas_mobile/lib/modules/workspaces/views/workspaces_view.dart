import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/workspaces_controller.dart';

class WorkspacesView extends GetView<WorkspacesController> {
  const WorkspacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.of(context).workspacesTitle)),
      body: Obx(() {
        if (controller.status.value.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeWorkspace = controller.activeWorkspace;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workspace actual
              if (activeWorkspace != null) ...[
                const Text(
                  'Workspace Actual',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF34D399),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: activeWorkspace.iconBackgroundColor.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          activeWorkspace.icon,
                          color: activeWorkspace.iconBackgroundColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeWorkspace.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeWorkspace.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
              // Botón para cambiar workspace
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => controller.showWorkspaceSelector(context),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text(
                    'Cambiar Workspace',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Lista de todos los workspaces
              const Text(
                'Todos los Workspaces',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.visibleWorkspaces.length,
                  itemBuilder: (context, index) {
                    final workspace = controller.visibleWorkspaces[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: workspace.iconBackgroundColor.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            workspace.icon,
                            color: workspace.iconBackgroundColor,
                          ),
                        ),
                        title: Text(
                          workspace.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(workspace.description),
                        trailing: workspace.isActive
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF34D399),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
