import 'dart:ui';

import 'package:app_finanzas_mobile/core/utils/snackbar_service.dart';
import 'package:app_finanzas_mobile/core/utils/validators.dart';
import 'package:app_finanzas_mobile/data/services/auth_service.dart';
import 'package:app_finanzas_mobile/data/services/directus_service.dart';
import 'package:app_finanzas_mobile/modules/home/controllers/home_controller.dart';
import 'package:app_finanzas_mobile/modules/organizations/controllers/organizations_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganizationDetailsView extends StatefulWidget {
  const OrganizationDetailsView({super.key});

  @override
  State<OrganizationDetailsView> createState() =>
      _OrganizationDetailsViewState();
}

class _OrganizationDetailsViewState extends State<OrganizationDetailsView> {
  final OrganizationsController controller =
      Get.find<OrganizationsController>();
  final AuthService authService = Get.find<AuthService>();
  final DirectusService directus = Get.find<DirectusService>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _geminiKeyController = TextEditingController();
  final TextEditingController _inviteEmailController = TextEditingController();

  String _selectedRole = 'member';

  static const Color _bg = Color(0xFF071126);
  static const Color _panel = Color(0xFF17233F);
  static const Color _panelSoft = Color(0xFF101A33);
  static const Color _panelDeep = Color(0xFF0C1530);
  static const Color _stroke = Color(0xFF24345D);
  static const Color _textDim = Color(0xFFA8B3D4);
  static const Color _textMuted = Color(0xFF7F8CB4);
  static const Color _accent = Color(0xFF7F91FF);
  static const Color _accentStrong = Color(0xFF5A6FFF);
  static const Color _success = Color(0xFF92FFD2);
  static const Color _danger = Color(0xFFFF6B86);
  static const Color _brand = Color(0xFF185637);

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    await controller.loadOrganizations();

    final currentOrg = _currentOrganization;
    if (currentOrg != null) {
      _nameController.text = currentOrg.name;
    }

    final orgId = authService.activeOrganizationId.value;
    if (orgId.isEmpty) {
      return;
    }

    final settings = await directus.getOrganizationSettings(orgId);
    if (settings != null) {
      _geminiKeyController.text = settings['gemini_api_key']?.toString() ?? '';
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _geminiKeyController.dispose();
    _inviteEmailController.dispose();
    super.dispose();
  }

  dynamic get _currentOrganization {
    final orgId = authService.activeOrganizationId.value;
    return controller.organizations.firstWhereOrNull((org) => org.id == orgId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_bg, Color(0xFF08142C), _bg],
                ),
              ),
            ),
          ),
          Obx(() {
            final currentOrg = _currentOrganization;
            final members = controller.members;
            final invites = controller.pendingInvitations;

            final visibleMembers = members.take(2).toList();
            final seatsUsed = members.length;
            const int seatsLimit = 10;

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(),
                          const SizedBox(height: 20),
                          _buildHero(currentOrg?.name ?? 'Organization'),
                          const SizedBox(height: 28),
                          _buildPrimaryCard(
                            icon: Icons.corporate_fare_rounded,
                            title: 'Organization Identity',
                            subtitle: 'Update brand identity and legal details',
                            onTap: _showProfileSheet,
                          ),
                          const SizedBox(height: 16),
                          _buildMemberManagementCard(
                            seatsUsed: seatsUsed,
                            seatsLimit: seatsLimit,
                            members: visibleMembers,
                            invites: invites,
                          ),
                          const SizedBox(height: 16),
                          _buildPrimaryCard(
                            icon: Icons.shield_outlined,
                            title: 'Roles & Permissions',
                            subtitle:
                                'Org members live here. Workspace access is assigned per workspace.',
                            onTap: _showPermissionsSheet,
                          ),
                          const SizedBox(height: 16),
                          _buildPrimaryCard(
                            icon: Icons.credit_card_rounded,
                            title: 'Billing',
                            subtitle: currentOrg == null
                                ? 'No billing profile connected yet'
                                : 'Managed by ${currentOrg.name} • Plan visibility only for now',
                            onTap: _showBillingSheet,
                          ),
                          const SizedBox(height: 16),
                          _buildPrimaryCard(
                            icon: Icons.hub_outlined,
                            title: 'Integrations',
                            subtitle: _geminiKeyController.text.trim().isEmpty
                                ? 'Connect Gemini and external services'
                                : 'Gemini API configured and ready',
                            onTap: _showIntegrationsSheet,
                          ),
                          const SizedBox(height: 28),
                          _buildDangerZone(
                            currentOrg?.name ?? 'this organization',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width < 800) _buildBottomDock(),
                ],
              ),
            );
          }),
          Obx(() {
            if (controller.isLoading.value) {
              return Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.28),
                  child: const Center(
                    child: CircularProgressIndicator(color: _accent),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _roundIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Get.back(),
        ),
        const Expanded(
          child: Text(
            'Organization',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }

  Widget _buildHero(String name) {
    return Column(
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 126,
                height: 126,
                decoration: BoxDecoration(
                  color: _brand,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _brand.withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _initialsFromName(name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: 8,
                child: GestureDetector(
                  onTap: _showProfileSheet,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [_accent, _accentStrong],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _accentStrong.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            GestureDetector(
              onTap: _showProfileSheet,
              child: const Icon(Icons.edit_outlined, color: _accent, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Premium Enterprise Tier',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textDim,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              _cardIcon(icon),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _textDim,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: _textMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberManagementCard({
    required int seatsUsed,
    required int seatsLimit,
    required List<Map<String, dynamic>> members,
    required List<Invitation> invites,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _cardIcon(Icons.groups_2_outlined),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Member Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$seatsUsed active seats used of $seatsLimit',
                      style: const TextStyle(color: _textDim, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (members.isEmpty)
            _emptyMembersState(invites)
          else
            ...members.map(_buildMemberRow),
          if (invites.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...invites.take(2).map(_buildInviteRow),
          ],
          const SizedBox(height: 18),
          _buildGradientButton(text: 'Invite Member', onTap: _showInviteDialog),
        ],
      ),
    );
  }

  Widget _emptyMembersState(List<Invitation> invites) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _stroke.withValues(alpha: 0.65)),
      ),
      child: Text(
        invites.isEmpty
            ? 'No organization members yet. Invite the first person to collaborate.'
            : 'No active members yet. You still have ${invites.length} invitation(s) pending.',
        style: const TextStyle(color: _textDim, fontSize: 13, height: 1.4),
      ),
    );
  }

  Widget _buildMemberRow(Map<String, dynamic> member) {
    final user = member['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final role = (member['role']?.toString() ?? 'member').toLowerCase();
    final firstName = user['first_name']?.toString() ?? '';
    final lastName = user['last_name']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';
    final name = '$firstName $lastName'.trim().isEmpty
        ? (email.isEmpty ? 'Miembro' : email)
        : '$firstName $lastName'.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _memberAvatar(name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatRole(role),
                  style: const TextStyle(color: _textDim, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _success.withValues(alpha: 0.55),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteRow(Invitation invite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _stroke.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mail_outline_rounded, color: _accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Invitation pending',
                  style: TextStyle(color: _textDim, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmRevokeInvitation(invite.id, invite.email),
            icon: const Icon(Icons.close_rounded, color: _textMuted),
            splashRadius: 18,
            tooltip: 'Revocar invitación',
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRevokeInvitation(String id, String email) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1A2540),
        title: const Text('Revocar invitación',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Revocar la invitación a $email?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Revocar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.revokeInvitation(id);
    }
  }

  Widget _buildDangerZone(String orgName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _panelDeep,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _danger.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danger Zone',
            style: TextStyle(
              color: _danger,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Archive or delete this organization and its history.',
            style: TextStyle(color: _textDim, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: () => _showComingSoon(
              'Delete Organization',
              'Deletion flow for $orgName is not wired yet. This screen now exposes the correct placement for that action.',
            ),
            style: TextButton.styleFrom(
              foregroundColor: _danger,
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              'Delete Organization',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDock() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1630),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _dockItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'VAULT',
                isSelected: false,
                onTap: () => Get.offAllNamed('/home'),
              ),
            ),
            Expanded(
              child: _dockItem(
                icon: Icons.trending_up_rounded,
                label: 'TRENDS',
                isSelected: false,
                onTap: () => Get.offAllNamed(
                  '/home',
                  arguments: {'initialIndex': HomeController.statsIndex},
                ),
              ),
            ),
            Expanded(
              child: _dockItem(
                icon: Icons.pie_chart_outline_rounded,
                label: 'BUDGETS',
                isSelected: false,
                onTap: () => Get.offAllNamed(
                  '/home',
                  arguments: {'initialIndex': HomeController.budgetsIndex},
                ),
              ),
            ),
            Expanded(
              child: _dockItem(
                icon: Icons.settings_rounded,
                label: 'SETTINGS',
                isSelected: true,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dockItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [_accent, _accentStrong],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : _textMuted, size: 21),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : _textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: _accent, size: 22),
    );
  }

  Widget _memberAvatar(String name) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF243C76), Color(0xFF172648)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          _initialsFromName(name),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accent, _accentStrong],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: _accentStrong.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileSheet() {
    Get.bottomSheet(
      _sheetScaffold(
        title: 'Organization Profile',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetLabel('Organization name'),
            _sheetTextField(
              controller: _nameController,
              hint: 'Luminescent Corp',
              icon: Icons.business_rounded,
            ),
            const SizedBox(height: 18),
            _sheetLabel('Gemini API Key'),
            _sheetTextField(
              controller: _geminiKeyController,
              hint: 'AIza...',
              icon: Icons.key_rounded,
              obscure: true,
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Members belong to the organization. Workspace-level access should be assigned inside each workspace, not by re-inviting people.',
                style: TextStyle(color: _textDim, fontSize: 12.5, height: 1.45),
              ),
            ),
            const SizedBox(height: 24),
            _buildGradientButton(
              text: 'Save Organization',
              onTap: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  SnackbarService.showWarning(
                      'Error', 'El nombre no puede estar vacío');
                  return;
                }
                await controller.saveSettings(
                  name: name,
                  geminiKey: _geminiKeyController.text.trim(),
                );
                Get.back();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showPermissionsSheet() {
    Get.bottomSheet(
      _sheetScaffold(
        title: 'Roles & Permissions',
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoLine(
              title: 'Organization roles',
              body:
                  'Define who belongs to the company: owner, admin, editor, member.',
            ),
            SizedBox(height: 14),
            _InfoLine(
              title: 'Workspace access',
              body:
                  'A workspace should only decide which organization members can see or operate there.',
            ),
            SizedBox(height: 14),
            _InfoLine(
              title: 'Recommended model',
              body:
                  'Invite once at organization level. Assign visibility and capabilities per workspace afterwards.',
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void _showBillingSheet() {
    _showComingSoon(
      'Billing',
      'Billing should remain organization-wide. Workspace billing usually becomes noise unless you need internal cost allocation.',
    );
  }

  void _showIntegrationsSheet() {
    Get.bottomSheet(
      _sheetScaffold(
        title: 'Integrations',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: _accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _geminiKeyController.text.trim().isEmpty
                          ? 'Gemini is not configured yet.'
                          : 'Gemini API key is configured for this organization.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Integrations are organization-scoped here because they usually serve all workspaces. Workspace-specific toggles can be layered later only when necessary.',
              style: TextStyle(color: _textDim, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void _showInviteDialog() {
    _inviteEmailController.clear();
    _selectedRole = 'member';

    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _stroke.withValues(alpha: 0.7)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invite Member',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                _sheetLabel('Email'),
                _sheetTextField(
                  controller: _inviteEmailController,
                  hint: 'correo@empresa.com',
                  icon: Icons.mail_outline_rounded,
                ),
                const SizedBox(height: 18),
                _sheetLabel('Role'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  dropdownColor: _panelSoft,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _panelSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'member', child: Text('Member')),
                  ],
                  onChanged: (value) {
                    _selectedRole = value ?? 'member';
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: _textDim),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGradientButton(
                        text: 'Send',
                        onTap: () async {
                          final email = _inviteEmailController.text.trim();
                          if (email.isEmpty) {
                            SnackbarService.showWarning(
                                'Error', 'Correo requerido');
                            return;
                          }
                          if (!Validators.isValidEmail(email)) {
                            SnackbarService.showWarning(
                                'Error', 'Correo electrónico inválido');
                            return;
                          }
                          await controller.inviteMember(email, _selectedRole);
                          if (!context.mounted) return;
                          Get.back();
                        },
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

  Widget _sheetScaffold({required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _stroke,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textMuted),
        prefixIcon: Icon(icon, color: _textMuted),
        filled: true,
        fillColor: _panelSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _sheetLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _textDim,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showComingSoon(String title, String message) {
    Get.bottomSheet(
      _sheetScaffold(
        title: title,
        child: Text(
          message,
          style: const TextStyle(color: _textDim, fontSize: 14, height: 1.5),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  String _initialsFromName(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) {
      return 'O';
    }

    return parts.map((part) => part.characters.first.toUpperCase()).join();
  }

  String _formatRole(String role) {
    switch (role) {
      case 'owner':
        return 'Owner';
      case 'admin':
        return 'Admin';
      case 'editor':
        return 'Editor';
      default:
        return 'Member';
    }
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _OrganizationDetailsViewState._panelSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: _OrganizationDetailsViewState._textDim,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
