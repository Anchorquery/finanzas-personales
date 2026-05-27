import 'package:app_finanzas_mobile/l10n/gen/app_localizations.dart';
import 'package:app_finanzas_mobile/modules/workspaces/controllers/members_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MembersView extends StatelessWidget {
  const MembersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MembersController());

    const backgroundColor = Color(0xFF0B1328);
    const cardColor = Color(0xFF16213A);
    const cardSoft = Color(0xFF111A30);
    const primaryBlue = Color(0xFF6D7DFF);
    const textWhite = Colors.white;
    const textGrey = Color(0xFFA6B2D3);
    const textMuted = Color(0xFF7C89AD);
    const success = Color(0xFF91FFD1);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          AppL10n.of(context).membersTitle.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: textWhite,
      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardSoft,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: primaryBlue.withValues(alpha: 0.16),
                      ),
                    ),
                    child: const Text(
                      'Los miembros pertenecen a la organizacion. Este workspace solo hereda ese equipo y luego define que personas pueden operar aqui.',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildVisibilityCard(
                    controller,
                    cardColor,
                    cardSoft,
                    primaryBlue,
                    textWhite,
                    textGrey,
                    textMuted,
                  ),
                  const SizedBox(height: 20),
                  _buildInviteCard(
                    controller,
                    primaryBlue,
                    cardColor,
                    textWhite,
                    textGrey,
                    textMuted,
                  ),
                  const SizedBox(height: 24),
                  _buildMembersList(
                    controller,
                    primaryBlue,
                    cardColor,
                    textWhite,
                    textGrey,
                    textMuted,
                    success,
                  ),
                ],
              ),
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withValues(alpha: 0.18),
                child: const Center(
                  child: CircularProgressIndicator(color: primaryBlue),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCard(
    MembersController controller,
    Color primaryBlue,
    Color cardColor,
    Color textWhite,
    Color textGrey,
    Color textMuted,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_add_alt_1_rounded,
                color: primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Invitar a la organizacion',
                style: TextStyle(
                  color: textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'La invitacion agrega al miembro a la organizacion. Este workspace luego reutiliza ese equipo.',
            style: TextStyle(color: textGrey, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: controller.inviteEmailController,
            style: TextStyle(color: textWhite),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              hintText: 'correo@ejemplo.com',
              hintStyle: TextStyle(color: textMuted, fontSize: 14),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: textMuted,
                size: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 10,
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isInviting.value
                  ? null
                  : controller.sendInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: controller.isInviting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Enviar invitacion',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityCard(
    MembersController controller,
    Color cardColor,
    Color cardSoft,
    Color primaryBlue,
    Color textWhite,
    Color textGrey,
    Color textMuted,
  ) {
    final isOrganizationWide = controller.accessScope.value == 'organization';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VISIBILIDAD DEL WORKSPACE',
            style: TextStyle(
              color: textGrey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          _scopeTile(
            title: 'Publico para toda la organizacion',
            body:
                'Cualquier miembro de la organizacion puede entrar a este workspace.',
            selected: isOrganizationWide,
            onTap: () => controller.updateAccessScope('organization'),
            primaryBlue: primaryBlue,
            cardSoft: cardSoft,
            textWhite: textWhite,
            textGrey: textGrey,
          ),
          const SizedBox(height: 10),
          _scopeTile(
            title: 'Restringido a miembros seleccionados',
            body: 'Solo las personas marcadas aqui podran usar este workspace.',
            selected: !isOrganizationWide,
            onTap: () => controller.updateAccessScope('restricted'),
            primaryBlue: primaryBlue,
            cardSoft: cardSoft,
            textWhite: textWhite,
            textGrey: textGrey,
          ),
          if (!isOrganizationWide) ...[
            const SizedBox(height: 14),
            Text(
              'Selecciona miembros con acceso',
              style: TextStyle(
                color: textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _scopeTile({
    required String title,
    required String body,
    required bool selected,
    required VoidCallback onTap,
    required Color primaryBlue,
    required Color cardSoft,
    required Color textWhite,
    required Color textGrey,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? primaryBlue
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? primaryBlue : textGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 12,
                      height: 1.4,
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

  Widget _buildMembersList(
    MembersController controller,
    Color primaryBlue,
    Color cardColor,
    Color textWhite,
    Color textGrey,
    Color textMuted,
    Color success,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MIEMBROS DE LA ORGANIZACION (${controller.members.length})',
            style: TextStyle(
              color: textGrey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          if (controller.members.isEmpty)
            Text(
              'No hay miembros activos todavia.',
              style: TextStyle(color: textMuted, fontSize: 13),
            )
          else
            ...controller.members.map((member) {
              final displayName = member.firstName.trim().isEmpty
                  ? member.email
                  : member.firstName.trim();
              final isOwner = controller.isWorkspaceOwner(member);
              final hasAccess = controller.hasWorkspaceAccess(member);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111A30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryBlue.withValues(alpha: 0.18),
                      child: Text(
                        displayName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              color: textWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            member.email,
                            style: TextStyle(color: textGrey, fontSize: 12),
                          ),
                          if (controller.accessScope.value == 'restricted') ...[
                            const SizedBox(height: 6),
                            Text(
                              isOwner
                                  ? 'Owner always has access'
                                  : (hasAccess ? 'Con acceso' : 'Sin acceso'),
                              style: TextStyle(
                                color: hasAccess ? primaryBlue : textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (controller.accessScope.value == 'organization')
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: success.withValues(alpha: 0.45),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      )
                    else
                      Switch(
                        value: hasAccess,
                        onChanged: isOwner
                            ? null
                            : (value) => controller.toggleMemberAccess(
                                member.id,
                                value,
                              ),
                        activeThumbColor: primaryBlue,
                      ),
                  ],
                ),
              );
            }),
          if (controller.invitations.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'INVITACIONES PENDIENTES (${controller.invitations.length})',
              style: TextStyle(
                color: textGrey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            ...controller.invitations.map(
              (invite) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111A30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: primaryBlue.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invite.email,
                            style: TextStyle(
                              color: textWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pendiente - ${invite.role}',
                            style: TextStyle(color: textGrey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.revokeInvitation(invite.id),
                      icon: Icon(Icons.close_rounded, color: textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
