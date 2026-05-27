import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_finanzas_mobile/core/theme/app_theme.dart';
import '../controllers/invitations_controller.dart';

class InvitationsView extends GetView<InvitationsController> {
  const InvitationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    '¡Hola!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tienes invitaciones para unirte a equipos de trabajo.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                      }
                      
                      if (controller.invitations.isEmpty) {
                        return _buildEmptyState();
                      }
                      
                      return ListView.builder(
                        itemCount: controller.invitations.length,
                        itemBuilder: (context, index) {
                          final invite = controller.invitations[index];
                          return _buildInviteCard(invite);
                        },
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: controller.goToSetup,
                      child: const Text(
                        'Prefiero crear mi propia organización',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(dynamic invite) {
    final orgName = invite.organization?.name ?? 'Organización Desconocida';
    final role = invite.role ?? 'Miembro';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                      child: const Icon(Icons.business_rounded, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Invitación de equipo',
                            style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            orgName,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Has sido invitado como ${role == 'admin' ? 'Administrador' : 'Miembro'} para colaborar en las finanzas de esta organización.',
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirmReject(controller, invite),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white10),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Rechazar', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.acceptInvitation(invite),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Aceptar',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mail_outline_rounded, size: 60, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          const Text(
            'No hay invitaciones pendientes',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReject(
      InvitationsController controller, dynamic invite) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Rechazar invitación',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Rechazar esta invitación? La organización no podrá restaurarla automáticamente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Rechazar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.rejectInvitation(invite);
    }
  }
}
