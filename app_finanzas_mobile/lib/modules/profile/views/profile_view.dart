import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundDark = Color(0xFF0B1121); // Almost black
    const Color cardColor = Color(0xFF1A1F36); // Dark blueish gray for cards
    const Color iconBackgroundColor = Color(0xFF0F1426); // Darker box for icons
    const Color onSurface = Color(0xFFF8FAFC);
    const Color onSurfaceVariant = Color(0xFF94A3B8);
    const Color primaryColor = Color(0xFF6366F1); // The blue action color
    const Color dangerColor = Color(0xFFF43F5E); // The red danger color

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        title: Text(
          AppL10n.of(context).profileTitle,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: MediaQuery.of(context).size.width < 800
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: primaryColor),
                onPressed: () => Get.back(),
              )
            : null,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value;
        final name = user?.firstName ?? 'Alex Rivers';
        final email = user?.email ?? 'alex.rivers@obsidian.io';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Shadow and Edit Badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1B3B30), // Greenish background like the image
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'A',
                        style: GoogleFonts.manrope(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Name and Pencil icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Subtitle
              Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),

              // Cards
              _buildReferenceCard(
                icon: Icons.person_outline_rounded,
                title: 'Información Personal',
                subtitle: 'Actualiza tu identidad y detalles de contacto',
                cardColor: cardColor,
                iconBgColor: iconBackgroundColor,
                textColor: onSurface,
                subtitleColor: onSurfaceVariant,
                onTap: () => _showEditNameDialog(context),
              ),
              const SizedBox(height: 16),
              _buildReferenceCard(
                icon: Icons.security_rounded,
                title: 'Seguridad',
                subtitle: 'Configura el acceso y la biometría',
                cardColor: cardColor,
                iconBgColor: iconBackgroundColor,
                textColor: onSurface,
                subtitleColor: onSurfaceVariant,
                onTap: () {
                  Get.toNamed('/security');
                },
              ),
              const SizedBox(height: 16),
              _buildReferenceCard(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                subtitle: 'Administra alertas y avisos del sistema',
                cardColor: cardColor,
                iconBgColor: iconBackgroundColor,
                textColor: onSurface,
                subtitleColor: onSurfaceVariant,
                onTap: () => Get.toNamed('/settings'),
              ),
              const SizedBox(height: 16),
              _buildReferenceCard(
                icon: Icons.settings_outlined,
                title: 'Preferencias',
                subtitle: 'Personaliza la aplicación',
                cardColor: cardColor,
                iconBgColor: iconBackgroundColor,
                textColor: onSurface,
                subtitleColor: onSurfaceVariant,
                onTap: () => Get.toNamed('/settings'),
              ),
              const SizedBox(height: 16),
              _buildReferenceCard(
                icon: Icons.extension_outlined,
                title: 'Integraciones',
                subtitle: 'Dispositivos y cuentas conectadas',
                cardColor: cardColor,
                iconBgColor: iconBackgroundColor,
                textColor: onSurface,
                subtitleColor: onSurfaceVariant,
                onTap: () => Get.toNamed('/settings'),
              ),
              const SizedBox(height: 40),

              // Danger Zone
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: backgroundDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: cardColor, // subtle border 
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zona de Peligro',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: dangerColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cierra sesión de tu cuenta o elimina todo el historial.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: controller.logout,
                      child: Text(
                        'Cerrar Sesión',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: dangerColor,
                        ),
                      ),
                    ),
                    // We could add Delete Account here as well
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final nameCtrl = TextEditingController(
      text: controller.user.value?.firstName ?? '',
    );
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1F36),
        title: const Text(
          'Editar Nombre',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre',
            labelStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                Get.back();
                controller.updateProfile(name);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color iconBgColor,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: const Color(0xFFC3C8D4), size: 24),
                ),
                const SizedBox(width: 16),
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron
                const SizedBox(width: 16),
                Icon(
                  Icons.chevron_right_rounded,
                  color: subtitleColor,
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
