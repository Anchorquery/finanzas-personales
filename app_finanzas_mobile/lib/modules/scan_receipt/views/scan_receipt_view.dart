import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_finanzas_mobile/core/theme/app_theme.dart';
import 'package:app_finanzas_mobile/modules/scan_receipt/controllers/scan_receipt_controller.dart';
import 'package:app_finanzas_mobile/modules/scan_receipt/views/upload_file_view.dart';
import 'package:app_finanzas_mobile/routes/app_routes.dart';

class ScanReceiptView extends GetView<ScanReceiptController> {
  const ScanReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    // En web, la cámara no está disponible — mostrar pantalla de subida directamente
    if (kIsWeb) {
      return const UploadFileView();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        // Cargando API key
        if (controller.isApiKeyLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentAI),
          );
        }

        // Sin API key configurada
        if (!controller.isApiKeyReady.value) {
          return _buildNoApiKeyState();
        }

        if (!controller.isCameraInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // Camera Preview
            SizedBox.expand(child: CameraPreview(controller.cameraController)),

            // Overlay with cutout
            CustomPaint(painter: OverlayPainter(), child: Container()),

            // Top Content
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Escaneando con Gemini IA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Back Button
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),

            // Corner Decorations
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.6,
                child: CustomPaint(painter: CornerPainter()),
              ),
            ),

            // Bottom Content
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Alinea el recibo dentro del marco',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Gallery Button (Now Navigates to UploadFileView)
                        GestureDetector(
                          onTap: () => Get.to(() => const UploadFileView()),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Shutter Button
                        GestureDetector(
                          onTap: controller.takePicture,
                          child: Container(
                            width: 80,
                            height: 80,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),

                        // Flash Button
                        Obx(
                          () => IconButton(
                            onPressed: controller.toggleFlash,
                            icon: Icon(
                              controller.isFlashOn.value
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              color: Colors.white,
                              size: 30,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Mode Selector (Auto/Manual)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildModeButton('Auto', true),
                        const SizedBox(width: 20),
                        _buildModeButton('Manual', false),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Processing Loading Overlay
            if (controller.isProcessing.value)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildNoApiKeyState() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón cerrar
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            const Spacer(),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentAI.withValues(alpha: 0.2),
                    const Color(0xFF6D28D9).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.accentAI.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: AppTheme.accentAI,
                size: 40,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Escaneo de Recibos\nno está configurado',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.3,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Para escanear recibos con IA necesitas configurar tu API key de Google Gemini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
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
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Volver',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, bool isSelected) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

class OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Define the cutout logic
    // We want a clear window in the middle
    final cutoutWidth = size.width * 0.85;
    final cutoutHeight = size.height * 0.6;
    final cutoutLeft = (size.width - cutoutWidth) / 2;
    final cutoutTop = (size.height - cutoutHeight) / 2;

    final cutoutRect = Rect.fromLTWH(
      cutoutLeft,
      cutoutTop,
      cutoutWidth,
      cutoutHeight,
    );
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(cutoutRect, const Radius.circular(20)),
      );

    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final length = 40.0;

    final path = Path();

    // Top Left
    path.moveTo(0, length);
    path.lineTo(0, 0);
    path.lineTo(length, 0);

    // Top Right
    path.moveTo(size.width - length, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, length);

    // Bottom Right
    path.moveTo(size.width, size.height - length);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - length, size.height);

    // Bottom Left
    path.moveTo(length, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height - length);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
