import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_finanzas_mobile/routes/app_routes.dart';
import 'package:app_finanzas_mobile/modules/scan_receipt/views/upload_file_view.dart';
import 'package:app_finanzas_mobile/modules/scan_receipt/bindings/scan_receipt_binding.dart';
import 'package:app_finanzas_mobile/core/theme/app_theme.dart';

class AddTransactionModal extends StatelessWidget {
  const AddTransactionModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Añadir Transacción',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Elige cómo quieres registrar tus gastos',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Opciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildOption(
                    context,
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Escanear con IA',
                    subtitle: 'Auto-categorización instantánea',
                    hasBetaTag: true,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(Routes.scanReceipt);
                    },
                  ),
                  _buildOption(
                    context,
                    icon: Icons.cloud_upload_outlined,
                    title: 'Subir Archivo',
                    subtitle: 'Importar PDF, JPG o CSV',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to file upload view
                      Get.to(
                        () => const UploadFileView(),
                        binding: ScanReceiptBinding(),
                      );
                    },
                  ),
                  _buildOption(
                    context,
                    icon: Icons.edit_outlined,
                    title: 'Entrada Manual',
                    subtitle: 'Crear registro desde cero',
                    isHighlighted: true,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(Routes.createTransaction);
                      // O Routes.addTransaction si existe
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Footer text
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tus datos están encriptados de extremo a extremo',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool hasBetaTag = false,
    bool isHighlighted = false,
    required bool isDark,
    required VoidCallback onTap,
  }) {
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
              color: isHighlighted
                  ? AppTheme.primaryColor // Blue highlighted
                  : (isDark ? const Color(0xFF242738) : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Colors.white.withValues(alpha: 0.2)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isHighlighted
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isHighlighted
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          if (hasBetaTag) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BETA',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isHighlighted
                              ? Colors.white.withValues(alpha: 0.8)
                              : (isDark ? Colors.white60 : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isHighlighted ? Icons.arrow_forward : Icons.chevron_right,
                  color: isHighlighted
                      ? Colors.white
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
