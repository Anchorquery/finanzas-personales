import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/security_controller.dart';

class SecurityView extends GetView<SecurityController> {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color surfaceContainer = Color(0xFF0F1930);
    const Color onSurface = Color(0xFFDEE5FF);
    const Color onSurfaceVariant = Color(0xFFA3AAC4);

    return Scaffold(
      backgroundColor: const Color(0xFF060E20),
      appBar: AppBar(
        title: Text(
          AppL10n.of(context).securityTitle,
          style: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Credenciales',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: const Icon(Icons.lock_outline_rounded,
                        color: AppTheme.primaryColor),
                    title: Text(
                      'Cambiar contraseña',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Se enviará un enlace a tu correo electrónico',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: onSurfaceVariant,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: onSurfaceVariant),
                    onTap: controller.changePassword,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Sesiones',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: const Icon(Icons.logout_rounded,
                        color: Colors.redAccent),
                    title: Text(
                      'Cerrar todas las sesiones',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Cierra sesión en todos los dispositivos',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: onSurfaceVariant,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: onSurfaceVariant),
                    onTap: controller.closeAllSessions,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Nota sobre funciones futuras
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppTheme.primaryColor.withValues(alpha: 0.6)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'La autenticación biométrica y 2FA estarán disponibles próximamente.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
