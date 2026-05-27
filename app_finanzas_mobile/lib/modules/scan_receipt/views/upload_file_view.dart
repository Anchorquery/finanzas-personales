import 'dart:ui';
import 'package:app_finanzas_mobile/modules/scan_receipt/controllers/scan_receipt_controller.dart';
import 'package:app_finanzas_mobile/core/theme/app_theme.dart';
import 'package:app_finanzas_mobile/l10n/gen/app_localizations.dart';
import 'package:app_finanzas_mobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadFileView extends GetView<ScanReceiptController> {
  const UploadFileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark, // Dark background from mockup
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppL10n.of(context).scanReceiptTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),
      body: Obx(() {
        if (controller.isApiKeyLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentAI),
          );
        }
        if (!controller.isApiKeyReady.value) {
          return _buildNoApiKeyState(context);
        }
        return _buildContent(context);
      }),
      bottomSheet: Obx(() => controller.isApiKeyReady.value
          ? Container(
              color: AppTheme.backgroundDark,
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.pickImageFromGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor:
                        const Color(0xFF7C3AED).withValues(alpha: 0.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Procesar con Gemini',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildNoApiKeyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.accentAI.withValues(alpha: 0.2),
                  const Color(0xFF6D28D9).withValues(alpha: 0.2),
                ]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.accentAI.withValues(alpha: 0.4),
                    width: 1.5),
              ),
              child: const Icon(Icons.document_scanner_rounded,
                  color: AppTheme.accentAI, size: 36),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin API key configurada',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'Configura tu API key de Gemini para analizar recibos automáticamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.settings),
                icon: const Icon(Icons.settings_rounded, size: 18),
                label: const Text('Ir a Configuración'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentAI,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Cargar Recibo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sube tus documentos financieros. Gemini analizará los gastos automáticamente.',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Upload Area
            GestureDetector(
              onTap: controller.pickImageFromGallery,
              child: CustomPaint(
                painter: DashedBorderPainter(),
                child: Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark, // Surface dark
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF2B4BEE,
                              ).withValues(alpha: 0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          color: Color(0xFF60A5FA), // Light blue
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Toca para seleccionar',
                        style: TextStyle(
                          color: Color(0xFF60A5FA),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Soporta JPG, PNG, PDF',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1B2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Text(
                          'Explorar Archivos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Processing Indicator
            Obx(() {
              if (controller.isProcessing.value) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161325),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF8B5CF6),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Analizando detalles del recibo...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Identificando comercio y total',
                                style: TextStyle(
                                  color: const Color(0xFF8B5CF6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: null, // Indeterminate - actual Gemini processing
                          backgroundColor: Color(0xFF1F1D2B),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF8B5CF6),
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PROCESANDO',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 32),

            // Recent Uploads
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RECIBOS RECIENTES',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: controller.recentUploads.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = controller.recentUploads[index];
                  return _buildRecentUploadItem(item);
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      );
  }

  Widget _buildRecentUploadItem(Map<String, dynamic> item) {
    Color iconColor;
    IconData iconData;

    try {
      iconColor = Color(item['color'] ?? 0xFFFFFFFF);
    } catch (_) {
      iconColor = Colors.white;
    }

    if (item['icon'] == 'coffee') {
      iconData = Icons.coffee;
    } else if (item['icon'] == 'car') {
      iconData = Icons.directions_car;
    } else if (item['icon'] == 'shopping_bag') {
      iconData = Icons.shopping_bag;
    } else {
      iconData = Icons.receipt;
    }

    final isProcessing = item['status'] == 'Processing...';

    return GestureDetector(
      onTap: () => controller.onUploadItemTap(item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark, // Surface dark
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isProcessing
                    ? const Color(0xFF1F2937)
                    : Color(0xFF2D2A26), // Mocking BG colors
                borderRadius: BorderRadius.circular(12),
                image: isProcessing
                    ? null
                    : null, // Could add actual image preview here
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isProcessing ? Colors.amber : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isProcessing
                            ? 'Processing...'
                            : 'Analyzed • ${item['amount']}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isProcessing)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey,
                ),
              )
            else
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF3B82F6) // Blue 500
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(24),
        ),
      );

    // Create dashed path
    final dashPath = Path();
    final dashWidth = 8.0;
    final dashSpace = 6.0;
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
