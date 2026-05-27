import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/invitations_controller.dart';
import '../../../core/theme/app_theme.dart';

class InvitationsView extends GetView<InvitationsController> {
  const InvitationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Invitaciones Pendientes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Has sido invitado a colaborar en las siguientes organizaciones.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.invitations.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.invitations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No tienes invitaciones pendientes.',
                            style: TextStyle(color: Colors.white38),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: controller.goToSetup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Configurar mi propia cuenta'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.invitations.length,
                    itemBuilder: (context, index) {
                      final invitation = controller.invitations[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Icon(Icons.business, color: Colors.white),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        invitation.organization?.name ?? 'Organización',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        'Te invitaron como Miembro',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _confirmReject(invitation),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white70,
                                      side: const BorderSide(color: Colors.white24),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Rechazar'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => controller.acceptInvitation(invitation),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Aceptar'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: controller.goToSetup,
                  child: const Text(
                    'Omitir y configurar mi propia cuenta',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReject(dynamic invitation) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Rechazar invitación',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Rechazar esta invitación?',
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
      await controller.rejectInvitation(invitation);
    }
  }
}
