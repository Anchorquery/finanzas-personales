import 'package:flutter/material.dart';
import '../../../data/models/workspace.dart';
import '../../theme/app_theme.dart';

class WorkspaceListItem extends StatelessWidget {
  final Workspace workspace;
  final VoidCallback onTap;

  const WorkspaceListItem({
    super.key,
    required this.workspace,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: workspace.isActive
                  ? (isDark ? const Color(0xFF1A3A3A) : const Color(0xFFECFDF5))
                  : (isDark ? AppTheme.surfaceDark : Colors.white),
              border: Border.all(
                color: workspace.isActive
                    ? AppTheme.accentGreen
                    : (isDark
                          ? const Color(0xFF2D303E)
                          : const Color(0xFFE5E7EB)),
                width: workspace.isActive ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Icono del workspace
                Container(
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Contenido del workspace
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workspace.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workspace.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppTheme.textSecondary
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Indicador derecho
                if (workspace.isActive)
                  Icon(
                    Icons.settings_outlined,
                    color: AppTheme.accentGreen,
                    size: 24,
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? AppTheme.textSecondary : Colors.black38,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
