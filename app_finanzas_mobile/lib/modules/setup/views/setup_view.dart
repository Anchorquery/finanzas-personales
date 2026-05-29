import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/workspace.dart';
import '../../auth/widgets/auth_field.dart';
import '../../auth/widgets/auth_scaffold.dart';
import '../controllers/setup_controller.dart';

/// Onboarding de 4 pasos:
///   0 — Bienvenida
///   1 — Workspace (tipo + nombre + moneda)
///   2 — Saldo inicial (tipo cuenta + nombre + monto)
///   3 — Superpotencias
class SetupView extends GetView<SetupController> {
  const SetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          return Obx(() {
            final step = controller.onboardingStep.value;
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 32 : 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StepHeader(step: step),
                      const SizedBox(height: 28),
                      _StepBody(step: step, controller: controller),
                      const SizedBox(height: 28),
                      _StepFooter(step: step, controller: controller),
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

// ─── HEADER (logo + step pills) ─────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int step;
  const _StepHeader({required this.step});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Finanzas Personales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.primary,
              ),
            ),
            const Spacer(),
            Text(
              'Paso ${step + 1} de ${SetupController.onboardingTotal}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isDark ? Colors.white60 : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: List.generate(SetupController.onboardingTotal, (i) {
            final active = i <= step;
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: i == 3 ? 0 : 8),
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.primary
                      : (isDark
                          ? Colors.white12
                          : const Color(0xFFEDEAF6)),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── BODY ────────────────────────────────────────────────────────────────────

class _StepBody extends StatelessWidget {
  final int step;
  final SetupController controller;
  const _StepBody({required this.step, required this.controller});

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return const _WelcomeStep();
      case 1:
        return _WorkspaceStep(controller: controller);
      case 2:
        return _BalanceStep(controller: controller);
      case 3:
        return const _PowersStep();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── STEP 0: Bienvenida ─────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.10),
                ),
              ),
              Container(
                width: 140,
                height: 140,
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
              // Orbits
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.20),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                child: _OrbitDot(color: AppTheme.accentGreen, size: 14),
              ),
              const Positioned(
                bottom: 22,
                right: 40,
                child: _OrbitDot(color: Color(0xFFFF6B6B), size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Tu vida financiera, organizada.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF1A1C1C),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Te tomará menos de 2 minutos configurar tu espacio.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.5,
            color: isDark ? Colors.white60 : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _OrbitDot extends StatelessWidget {
  final Color color;
  final double size;
  const _OrbitDot({required this.color, required this.size});

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

// ─── STEP 1: Workspace ──────────────────────────────────────────────────────

class _WorkspaceStep extends StatelessWidget {
  final SetupController controller;
  const _WorkspaceStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '¿Para qué vas a usar Finanzas Personales?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: isDark ? Colors.white : const Color(0xFF1A1C1C),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Podrás crear más workspaces después.',
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? Colors.white60 : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => Column(
            children: [
              _TypeCard(
                icon: Icons.person_outline_rounded,
                title: 'Personal',
                subtitle: 'Mis finanzas individuales',
                accent: AppTheme.primary,
                selected: controller.selectedWorkspaceType.value ==
                    WorkspaceType.personal,
                onTap: () => controller.selectedWorkspaceType.value =
                    WorkspaceType.personal,
              ),
              const SizedBox(height: 12),
              _TypeCard(
                icon: Icons.groups_2_outlined,
                title: 'Familiar',
                subtitle: 'Comparte con tu familia',
                accent: AppTheme.accentGreen,
                selected: controller.selectedWorkspaceType.value ==
                    WorkspaceType.family,
                onTap: () => controller.selectedWorkspaceType.value =
                    WorkspaceType.family,
              ),
              const SizedBox(height: 12),
              _TypeCard(
                icon: Icons.business_center_outlined,
                title: 'Negocio',
                subtitle: 'Lleva las cuentas de tu emprendimiento',
                accent: AppTheme.accentWarning,
                selected: controller.selectedWorkspaceType.value ==
                    WorkspaceType.business,
                onTap: () => controller.selectedWorkspaceType.value =
                    WorkspaceType.business,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        AuthField(
          label: 'Nombre del workspace',
          controller: controller.workspaceNameController,
          icon: Icons.workspaces_outline,
          hint: 'Ej: Principal, Casa, Empresa…',
        ),
        const SizedBox(height: 18),
        Text(
          'MONEDA PRINCIPAL',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : AppTheme.textHint,
          ),
        ),
        const SizedBox(height: 8),
        _CurrencyDropdown(controller: controller, isDark: isDark),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? (selected
                    ? AppTheme.primary.withValues(alpha: 0.12)
                    : const Color(0x12FFFFFF))
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppTheme.primary
                  : (isDark
                      ? const Color(0x14FFFFFF)
                      : const Color(0xFFEDEAF6)),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1A1C1C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? Colors.white60
                            : AppTheme.textSecondary,
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

class _CurrencyDropdown extends StatelessWidget {
  final SetupController controller;
  final bool isDark;
  const _CurrencyDropdown({required this.controller, required this.isDark});

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
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF13161F) : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isDark
                ? const Color(0x22FFFFFF)
                : const Color(0xFFE2E0F7),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedCurrency.value,
            isExpanded: true,
            dropdownColor: isDark
                ? AppTheme.surfaceDark
                : Colors.white,
            icon: Icon(
              Icons.expand_more_rounded,
              color: isDark ? Colors.white60 : AppTheme.textHint,
            ),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1A1C1C),
            ),
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

// ─── STEP 2: Saldo inicial ──────────────────────────────────────────────────

class _BalanceStep extends StatelessWidget {
  final SetupController controller;
  const _BalanceStep({required this.controller});

  static const _types = [
    ('cash', '💵', 'Efectivo'),
    ('bank', '🏦', 'Banco'),
    ('credit_card', '💳', 'Tarjeta'),
    ('investment', '📈', 'Inversión'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '¿Cuánto tienes ahora mismo?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: isDark ? Colors.white : const Color(0xFF1A1C1C),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Es tu punto de partida. Podrás añadir más cuentas después.',
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? Colors.white60 : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'TIPO DE CUENTA',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : AppTheme.textHint,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
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
                        color: selected
                            ? AppTheme.primary
                            : (isDark ? const Color(0x12FFFFFF) : Colors.white),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primary
                              : (isDark
                                  ? const Color(0x22FFFFFF)
                                  : const Color(0xFFEDEAF6)),
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Text(emoji,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.white70
                                      : AppTheme.textSecondary),
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
        ),
        const SizedBox(height: 18),
        AuthField(
          label: 'Nombre de la cuenta',
          controller: controller.accountNameController,
          icon: Icons.account_balance_wallet_outlined,
          hint: 'Ej: Billetera, BBVA…',
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF13161F) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? const Color(0x14FFFFFF)
                  : const Color(0xFFEDEAF6),
            ),
          ),
          child: Column(
            children: [
              Text(
                'BALANCE ACTUAL',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : AppTheme.textHint,
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
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: TextField(
                        controller: controller.initialBalanceController,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]')),
                        ],
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.2,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1C1C),
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
              Text(
                'Puedes dejarlo en 0 si empiezas desde cero.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? Colors.white60 : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _currencySymbol(String code) => switch (code) {
        'USD' => r'$',
        'EUR' => '€',
        'VES' => 'Bs.',
        'COP' => r'$',
        'MXN' => r'$',
        'ARS' => r'$',
        _ => code,
      };
}

// ─── STEP 3: Superpotencias ─────────────────────────────────────────────────

class _PowersStep extends StatelessWidget {
  const _PowersStep();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Listo. Esto es lo que puedes hacer:',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: isDark ? Colors.white : const Color(0xFF1A1C1C),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu nueva vida financiera comienza ahora con estas herramientas.',
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? Colors.white60 : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 22),
        _FeatureCard(
          icon: Icons.psychology_rounded,
          color: AppTheme.primary,
          title: 'Coach financiero 24/7',
          subtitle:
              'Te sugiere ahorros, alerta excesos y cuida tus metas en tiempo real.',
          glow: true,
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.document_scanner_outlined,
          color: AppTheme.accentGreen,
          title: 'Captura gastos en 2 segundos',
          subtitle:
              'Foto al ticket y listo. Clasificamos el gasto automáticamente.',
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.auto_graph_rounded,
          color: AppTheme.accentWarning,
          title: 'Entiende a dónde se va tu dinero',
          subtitle:
              'Gráficos semanales que revelan patrones de los que no eras consciente.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x22FFFFFF)),
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
                      color:
                          AppTheme.accentGreen.withValues(alpha: 0.7),
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
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool glow;

  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x12FFFFFF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0x14FFFFFF)
              : const Color(0xFFEDEAF6),
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF1A1C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: isDark
                        ? Colors.white60
                        : AppTheme.textSecondary,
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

// ─── FOOTER (Atrás + CTA) ───────────────────────────────────────────────────

class _StepFooter extends StatelessWidget {
  final int step;
  final SetupController controller;
  const _StepFooter({required this.step, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFirst = step == 0;
    final isLast = step == SetupController.onboardingTotal - 1;

    final ctaLabel = isFirst
        ? 'Empezar'
        : (isLast ? 'Ir a mi Dashboard' : 'Continuar');

    return Row(
      children: [
        if (!isFirst)
          OutlinedButton(
            onPressed: controller.previousOnboarding,
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  isDark ? Colors.white70 : AppTheme.textSecondary,
              side: BorderSide(
                color: isDark
                    ? const Color(0x22FFFFFF)
                    : const Color(0xFFEDEAF6),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Atrás',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        const Spacer(),
        Obx(
          () => SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      if (isLast) {
                        controller.finishSetup();
                      } else {
                        controller.nextOnboarding();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor:
                    AppTheme.primary.withValues(alpha: 0.5),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ctaLabel,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
