import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/workspace.dart';
import '../../auth/widgets/auth_scaffold.dart';
import '../controllers/setup_controller.dart';

/// Onboarding (4 pasos) — mobile + desktop 1:1 con diseños HTML.
///   0 — Bienvenida
///   1 — Workspace (tipo + nombre + moneda)
///   2 — Saldo inicial
///   3 — Superpotencias
class SetupView extends GetView<SetupController> {
  const SetupView({super.key});

  static const int _desktopBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _desktopBreakpoint;
          return Obx(() {
            switch (controller.onboardingStep.value) {
              case 0:
                return isWide
                    ? _WelcomeDesktop(controller: controller)
                    : _WelcomeMobile(controller: controller);
              case 1:
                return isWide
                    ? _WorkspaceDesktop(controller: controller)
                    : _WorkspaceMobile(controller: controller);
              case 2:
                return isWide
                    ? _BalanceDesktop(controller: controller)
                    : _BalanceMobile(controller: controller);
              case 3:
                return isWide
                    ? _PowersDesktop(controller: controller)
                    : _PowersMobile(controller: controller);
              default:
                return const SizedBox.shrink();
            }
          });
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// STEP 0 — BIENVENIDA
// ════════════════════════════════════════════════════════════════════════

class _WelcomeMobile extends StatelessWidget {
  final SetupController controller;
  const _WelcomeMobile({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0x33CCC3D8)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF630ED4).withValues(alpha: 0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEDE9FE),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.10),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'D',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '¡Hola!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1C1C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Hero
                const _OrbitalHero(size: 280),
                const SizedBox(height: 24),
                // Text
                const Text(
                  'Tu vida financiera, organizada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.5,
                    color: Color(0xFF1A1C1C),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Te tomará menos de 2 minutos configurar tu espacio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Step pills
                _StepPills(current: 0, total: 4),
                const SizedBox(height: 24),
                // CTA
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: controller.nextOnboarding,
                    icon: const Text(''), // spacer
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Empezar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: controller.finishSetup,
                    child: const Text(
                      'Ya tengo cuenta configurada — saltar',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeDesktop extends StatelessWidget {
  final SetupController controller;
  const _WelcomeDesktop({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFCCC3D8)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // LEFT — primary container with orbits
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 640),
                        color: AppTheme.primary,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Decorative orbits
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.20,
                                child: Center(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      _Orbit(size: 500),
                                      _Orbit(size: 350),
                                      _Orbit(size: 200),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Top-left logo
                            Positioned(
                              top: 24,
                              left: 24,
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons
                                          .account_balance_wallet_rounded,
                                      color: AppTheme.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Finanzas Personales',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Center content
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.20),
                                        blurRadius: 40,
                                        offset: const Offset(0, 20),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: Colors.white,
                                    size: 96,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'Gestión de activos con IA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 48),
                                  child: Text(
                                    'Visualiza tu capital a través de una lente de precisión y modernidad.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xCCFFFFFF),
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // RIGHT — content area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top: step pills + step text
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: const [
                                _StepPills(current: 0, total: 4, narrow: true),
                                Text(
                                  'Paso 1 de 4',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Chip "BIENVENIDO A BORDO"
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC7C3FE),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.auto_awesome,
                                        color: Color(0xFF514F81), size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'BIENVENIDO A BORDO',
                                      style: TextStyle(
                                        fontSize: 11,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF514F81),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '¡Hola!',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: Color(0xFF1A1C1C),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tu vida financiera, organizada.',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(
                              width: 380,
                              child: Text(
                                'Te tomará menos de 2 minutos configurar tu espacio de trabajo y conectar tus cuentas principales.',
                                style: TextStyle(
                                  fontSize: 17,
                                  height: 1.5,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // CTAs
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: controller.nextOnboarding,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'Empezar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded,
                                        size: 18),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: controller.finishSetup,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1A1C1C),
                                  side: const BorderSide(
                                      color: Color(0xFFCCC3D8)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Configurar más tarde',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Divider(
                                color: Color(0xFFEDEAF6),
                                thickness: 1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Únete a miles de profesionales que confían en nuestra infraestructura.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// STEP 1 — WORKSPACE
// ════════════════════════════════════════════════════════════════════════

class _WorkspaceMobile extends StatelessWidget {
  final SetupController controller;
  const _WorkspaceMobile({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step pills (start aligned)
              _StepPills(current: 1, total: 4),
              const SizedBox(height: 32),
              // Header
              const Text(
                '¿Para qué vas a usar Finanzas Personales?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: -0.3,
                  color: Color(0xFF1A1C1C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Podrás crear más workspaces después.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Cards stack
              Obx(
                () => Column(
                  children: [
                    _TypeCardRow(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal',
                      subtitle: 'Mis finanzas individuales',
                      accent: AppTheme.primary,
                      selected: controller.selectedWorkspaceType.value ==
                          WorkspaceType.personal,
                      onTap: () => controller.selectedWorkspaceType.value =
                          WorkspaceType.personal,
                    ),
                    const SizedBox(height: 16),
                    _TypeCardRow(
                      icon: Icons.people_outline_rounded,
                      title: 'Familiar',
                      subtitle: 'Comparte con tu familia',
                      accent: AppTheme.accentGreen,
                      selected: controller.selectedWorkspaceType.value ==
                          WorkspaceType.family,
                      onTap: () => controller.selectedWorkspaceType.value =
                          WorkspaceType.family,
                    ),
                    const SizedBox(height: 16),
                    _TypeCardRow(
                      icon: Icons.business_center_outlined,
                      title: 'Negocio',
                      subtitle:
                          'Lleva las cuentas de tu emprendimiento',
                      accent: AppTheme.accentWarning,
                      selected: controller.selectedWorkspaceType.value ==
                          WorkspaceType.business,
                      onTap: () => controller.selectedWorkspaceType.value =
                          WorkspaceType.business,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Workspace name
              const _SmallLabel('NOMBRE DEL WORKSPACE'),
              const SizedBox(height: 8),
              _SetupTextInput(
                controller: controller.workspaceNameController,
                hint: 'Ej: Principal',
              ),
              const SizedBox(height: 24),
              // Currency
              const _SmallLabel('MONEDA PRINCIPAL'),
              const SizedBox(height: 8),
              _CurrencyPill(controller: controller),
              const SizedBox(height: 40),
              // Footer
              _PrevNextRow(
                onBack: controller.previousOnboarding,
                onNext: controller.nextOnboarding,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceDesktop extends StatelessWidget {
  final SetupController controller;
  const _WorkspaceDesktop({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top app bar
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.80),
            border: const Border(
              bottom: BorderSide(color: Color(0x14000000)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Finanzas Personales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const Spacer(),
              const Text(
                '¿Necesitas ayuda?',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Soporte',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  children: [
                    // Step indicator centered
                    Column(
                      children: const [
                        Text(
                          'PASO 2 DE 4',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7B7487),
                          ),
                        ),
                        SizedBox(height: 8),
                        _StepPills(current: 1, total: 4, narrow: true),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Title
                    const Text(
                      '¿Para qué vas a usar Finanzas Personales?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        letterSpacing: -1,
                        color: Color(0xFF1A1C1C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 640,
                      child: Text(
                        'Personaliza tu experiencia seleccionando el tipo de cuenta que mejor se adapte a tus necesidades financieras actuales.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // 3-col cards
                    Obx(
                      () => Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _TypeCardCol(
                              icon: Icons.person_outline_rounded,
                              title: 'Personal',
                              subtitle:
                                  'Gestión de gastos diarios, ahorros individuales y metas de inversión.',
                              selected:
                                  controller.selectedWorkspaceType.value ==
                                      WorkspaceType.personal,
                              onTap: () =>
                                  controller.selectedWorkspaceType.value =
                                      WorkspaceType.personal,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _TypeCardCol(
                              icon: Icons.groups_outlined,
                              title: 'Familiar',
                              subtitle:
                                  'Cuentas compartidas, control de gastos del hogar y planificación de ahorros grupales.',
                              selected:
                                  controller.selectedWorkspaceType.value ==
                                      WorkspaceType.family,
                              onTap: () =>
                                  controller.selectedWorkspaceType.value =
                                      WorkspaceType.family,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _TypeCardCol(
                              icon: Icons.corporate_fare_outlined,
                              title: 'Negocios',
                              subtitle:
                                  'Facturación, nóminas, gestión tributaria y tesorería corporativa.',
                              selected:
                                  controller.selectedWorkspaceType.value ==
                                      WorkspaceType.business,
                              onTap: () =>
                                  controller.selectedWorkspaceType.value =
                                      WorkspaceType.business,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Workspace name + currency centered
                    SizedBox(
                      width: 420,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SmallLabel('NOMBRE DEL WORKSPACE'),
                          const SizedBox(height: 8),
                          _SetupTextInput(
                            controller: controller.workspaceNameController,
                            hint: 'Ej: Principal',
                          ),
                          const SizedBox(height: 24),
                          const _SmallLabel('MONEDA PRINCIPAL DE TRABAJO'),
                          const SizedBox(height: 8),
                          _CurrencyPill(controller: controller, square: true),
                          const SizedBox(height: 32),
                          _PrevNextRow(
                            onBack: controller.previousOnboarding,
                            onNext: controller.nextOnboarding,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Footer security
        Padding(
          padding: const EdgeInsets.all(16),
          child: Opacity(
            opacity: 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified_user_outlined,
                    size: 14, color: AppTheme.textSecondary),
                SizedBox(width: 6),
                Text(
                  'Tus datos están protegidos por encriptación de grado bancario AES-256.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// STEP 2 — SALDO INICIAL
// ════════════════════════════════════════════════════════════════════════

class _BalanceMobile extends StatelessWidget {
  final SetupController controller;
  const _BalanceMobile({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top header
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              bottom: BorderSide(color: Color(0x33CCC3D8)),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'Finanzas Personales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepPills(current: 2, total: 4),
                const SizedBox(height: 8),
                const Text(
                  'Paso 3 de 4',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '¿Cuánto tienes ahora mismo?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.3,
                    color: Color(0xFF1A1C1C),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Es tu punto de partida. Podrás añadir más cuentas después.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Type chips
                const _SmallLabel('TIPO DE CUENTA'),
                const SizedBox(height: 8),
                _TypeChipsRow(controller: controller),
                const SizedBox(height: 24),
                // Name
                const _SmallLabel('NOMBRE DE LA CUENTA'),
                const SizedBox(height: 8),
                _SetupTextInput(
                  controller: controller.accountNameController,
                  hint: 'Ej: Billetera, BBVA…',
                ),
                const SizedBox(height: 24),
                // Balance card
                _BalanceAmountCard(controller: controller),
              ],
            ),
          ),
        ),
        // Fixed bottom actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            border: const Border(
              top: BorderSide(color: Color(0x14000000)),
            ),
          ),
          child: _PrevNextRow(
            onBack: controller.previousOnboarding,
            onNext: controller.nextOnboarding,
          ),
        ),
      ],
    );
  }
}

class _BalanceDesktop extends StatelessWidget {
  final SetupController controller;
  const _BalanceDesktop({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              // Step indicator
              Column(
                children: const [
                  Text(
                    'PASO 3 DE 4',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  _StepPills(current: 2, total: 4, narrow: true),
                ],
              ),
              const SizedBox(height: 48),
              // Glass card
              Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F0FB)),
                ),
                child: Column(
                  children: [
                    const Text(
                      '¿Cuánto tienes ahora mismo?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        letterSpacing: -0.5,
                        color: Color(0xFF1A1C1C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 500,
                      child: Text(
                        'Configura tu saldo inicial para empezar a rastrear tus movimientos con precisión.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Big numeric input
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _currencySymbol(
                                controller.selectedCurrency.value),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                              color: AppTheme.primary.withValues(alpha: 0.40),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IntrinsicWidth(
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 280),
                              child: TextField(
                                controller:
                                    controller.initialBalanceController,
                                textAlign: TextAlign.center,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]')),
                                ],
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1,
                                  color: AppTheme.primary,
                                ),
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: '0,00',
                                  hintStyle: TextStyle(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.20),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Grid 2 cols
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SmallLabel('NOMBRE DE LA CUENTA'),
                              const SizedBox(height: 8),
                              _SetupTextInput(
                                controller: controller.accountNameController,
                                hint: 'Ej. Mi Ahorro Personal',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SmallLabel('TIPO DE CUENTA'),
                              const SizedBox(height: 8),
                              _TypeSegmented(controller: controller),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Actions
                    _PrevNextRow(
                      onBack: controller.previousOnboarding,
                      onNext: controller.nextOnboarding,
                      backLabel: 'Atrás',
                      backIcon: Icons.arrow_back_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Opacity(
                opacity: 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.verified_user_outlined,
                        size: 14, color: AppTheme.textSecondary),
                    SizedBox(width: 6),
                    Text(
                      'Conexión cifrada de grado bancario',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// STEP 3 — SUPERPOTENCIAS
// ════════════════════════════════════════════════════════════════════════

class _PowersMobile extends StatelessWidget {
  final SetupController controller;
  const _PowersMobile({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top header
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              bottom: BorderSide(color: Color(0x33CCC3D8)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Finanzas Personales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepPills(current: 3, total: 4),
                const SizedBox(height: 24),
                const Text(
                  'Listo. Esto es lo que puedes hacer:',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.3,
                    color: Color(0xFF1A1C1C),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu nueva vida financiera comienza ahora con estas herramientas exclusivas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _FeatureCardRow(
                  icon: Icons.psychology_rounded,
                  iconBg: Color(0xFFEDE9FE),
                  iconColor: AppTheme.primary,
                  title: 'Coach financiero 24/7',
                  subtitle:
                      'Te sugiere ahorros, alerta excesos y cuida tus metas en tiempo real.',
                  glow: true,
                ),
                const SizedBox(height: 16),
                _FeatureCardRow(
                  icon: Icons.document_scanner_outlined,
                  iconBg: Color(0xFFD1FAE5),
                  iconColor: AppTheme.accentGreen,
                  title: 'Captura gastos en 2 segundos',
                  subtitle:
                      'Foto al ticket y listo. Clasificamos el gasto automáticamente.',
                ),
                const SizedBox(height: 16),
                _FeatureCardRow(
                  icon: Icons.auto_graph_rounded,
                  iconBg: Color(0xFFFEF3C7),
                  iconColor: AppTheme.accentWarning,
                  title: 'Entiende a dónde se va tu dinero',
                  subtitle:
                      'Gráficos semanales que revelan patrones de los que no eras consciente.',
                ),
                const SizedBox(height: 24),
                // Indigo ribbon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B4B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentGreen,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGreen
                                  .withValues(alpha: 0.7),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tu primer consejo aparecerá automáticamente en el dashboard según tus movimientos.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Fixed bottom CTA
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            border: const Border(
              top: BorderSide(color: Color(0x14000000)),
            ),
          ),
          child: SizedBox(
            height: 56,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.finishSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: AppTheme.primary.withValues(alpha: 0.2),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Ir a mi Dashboard',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PowersDesktop extends StatelessWidget {
  final SetupController controller;
  const _PowersDesktop({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    // Step indicator
                    Column(
                      children: const [
                        Text(
                          'PASO 4 / 4',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                        SizedBox(height: 8),
                        _StepPills(current: 3, total: 4, narrow: true),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Listo. Esto es lo que puedes hacer:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        letterSpacing: -1,
                        color: Color(0xFF1A1C1C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 640,
                      child: Text(
                        'Tus superpoderes financieros ya están activos. Configura tu flujo de trabajo ideal ahora mismo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Bento grid 3 cols
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        Expanded(
                          child: _BentoFeature(
                            icon: Icons.psychology_rounded,
                            title: 'AI Coach',
                            subtitle:
                                'Optimiza tus ahorros con consejos personalizados basados en tus patrones de gasto.',
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _BentoFeature(
                            icon: Icons.document_scanner_outlined,
                            title: 'Scan Receipts',
                            subtitle:
                                'Sube tus facturas y deja que nuestra IA extraiga datos fiscales automáticamente.',
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _BentoFeature(
                            icon: Icons.insights_rounded,
                            title: 'Smart Insights',
                            subtitle:
                                'Visualiza proyecciones de flujo de caja y detecta anomalías antes que te afecten.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      height: 56,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.finishSetup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Text(
                                  'Ir a mi Dashboard',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Puedes configurar estos módulos más tarde en Ajustes.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Bottom green pulsing ribbon
        Container(
          height: 56,
          color: const Color(0xFF181445),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentGreen,
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppTheme.accentGreen.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'SISTEMA CONECTADO CON ÉXITO — PROCESANDO DATOS EN TIEMPO REAL',
                style: TextStyle(
                  color: Color(0xFFE3DFFF),
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// SHARED COMPONENTS
// ════════════════════════════════════════════════════════════════════════

class _StepPills extends StatelessWidget {
  final int current;
  final int total;
  final bool narrow;
  const _StepPills({
    required this.current,
    required this.total,
    this.narrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i <= current;
        return Container(
          width: narrow ? 28 : 36,
          height: narrow ? 4 : 6,
          margin: EdgeInsets.only(right: i == total - 1 ? 0 : 8),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : const Color(0xFFEDEAF6),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _OrbitalHero extends StatelessWidget {
  final double size;
  const _OrbitalHero({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.10),
              ),
            ),
            Container(
              width: size * 0.50,
              height: size * 0.50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.30),
                    blurRadius: 32,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
            Container(
              width: size * 0.86,
              height: size * 0.86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.20),
                ),
              ),
            ),
            Positioned(
              top: size * 0.05,
              child: _DotOrbit(color: AppTheme.accentGreen, size: 14),
            ),
            Positioned(
              bottom: size * 0.10,
              right: size * 0.18,
              child: _DotOrbit(color: const Color(0xFFFF6B6B), size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotOrbit extends StatelessWidget {
  final Color color;
  final double size;
  const _DotOrbit({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.40),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}

class _Orbit extends StatelessWidget {
  final double size;
  const _Orbit({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  final String text;
  const _SmallLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF7B7487),
        ),
      ),
    );
  }
}

class _SetupTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _SetupTextInput({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E0F7)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Color(0xFF1A1C1C),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF7B7487),
            fontSize: 14.5,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

class _TypeCardRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCardRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTheme.primary : const Color(0xFFEDEAF6),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.10),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1C1C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeCardCol extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCardCol({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF1F0FB) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTheme.primary : const Color(0xFFF1F0FB),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? AppTheme.primary
                      : const Color(0xFFC7C3FE),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF514F81),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (selected) ...[
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Icon(Icons.check_circle_rounded,
                        size: 18, color: AppTheme.primary),
                    SizedBox(width: 4),
                    Text(
                      'Seleccionado',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  final SetupController controller;
  final bool square;
  const _CurrencyPill({required this.controller, this.square = false});

  static const _options = {
    'USD': 'USD — Dólar Estadounidense',
    'EUR': 'EUR — Euro',
    'VES': 'VES — Bolívar Venezolano',
    'COP': 'COP — Peso Colombiano',
    'MXN': 'MXN — Peso Mexicano',
    'ARS': 'ARS — Peso Argentino',
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(square ? 12 : 99),
          border: Border.all(color: const Color(0xFFE2E0F7)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedCurrency.value,
            isExpanded: true,
            icon: const Icon(
              Icons.expand_more_rounded,
              color: Color(0xFF7B7487),
            ),
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1C1C),
            ),
            dropdownColor: Colors.white,
            items: _options.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) controller.selectedCurrency.value = v;
            },
          ),
        ),
      );
    });
  }
}

class _TypeChipsRow extends StatelessWidget {
  final SetupController controller;
  const _TypeChipsRow({required this.controller});

  static const _types = [
    ('cash', '💵', 'Efectivo'),
    ('bank', '🏦', 'Banco'),
    ('credit_card', '💳', 'Tarjeta'),
    ('investment', '📈', 'Inversión'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final (value, emoji, label) = _types[i];
          return Obx(() {
            final selected = controller.accountType.value == value;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.accountType.value = value;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: selected
                          ? AppTheme.primary
                          : const Color(0xFFEDEAF6),
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color:
                                  AppTheme.primary.withValues(alpha: 0.20),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _TypeSegmented extends StatelessWidget {
  final SetupController controller;
  const _TypeSegmented({required this.controller});

  static const _options = [
    ('cash', Icons.payments_outlined, 'Efectivo'),
    ('bank', Icons.account_balance_outlined, 'Banco'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E0F7)),
      ),
      child: Obx(() {
        return Row(
          children: _options.map((opt) {
            final (value, icon, label) = opt;
            final selected = controller.accountType.value == value;
            return Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => controller.accountType.value = value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color: selected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}

class _BalanceAmountCard extends StatelessWidget {
  final SetupController controller;
  const _BalanceAmountCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F0FB)),
      ),
      child: Column(
        children: [
          const Text(
            'BALANCE ACTUAL',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7B7487),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _currencySymbol(controller.selectedCurrency.value),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 6),
              IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: TextField(
                    controller: controller.initialBalanceController,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.]')),
                    ],
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      color: Color(0xFF1A1C1C),
                    ),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: '0.00',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Puedes dejarlo en 0 si empiezas desde cero.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCardRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool glow;

  const _FeatureCardRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F0FB)),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _BentoFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCC3D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrevNextRow extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String backLabel;
  final String nextLabel;
  final IconData? backIcon;
  const _PrevNextRow({
    required this.onBack,
    required this.onNext,
    this.backLabel = 'Atrás',
    // ignore: unused_element_parameter
    this.nextLabel = 'Continuar',
    this.backIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onBack,
              icon: backIcon != null
                  ? Icon(backIcon, size: 16)
                  : const SizedBox.shrink(),
              label: Text(
                backLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: BorderSide(
                    color: AppTheme.primary.withValues(alpha: 0.30)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: AppTheme.primary.withValues(alpha: 0.25),
              ),
              child: Text(
                nextLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _currencySymbol(String code) => switch (code) {
      'USD' => r'$',
      'EUR' => '€',
      'VES' => 'Bs.',
      'COP' => r'$',
      'MXN' => r'$',
      'ARS' => r'$',
      _ => code,
    };
