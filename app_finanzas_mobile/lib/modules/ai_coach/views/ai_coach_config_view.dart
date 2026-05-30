import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/ai_coach_controller.dart';

/// Pantalla de activación del Coach: conectar API key de Gemini + elegir modelo.
/// Responsive: tarjeta centrada 360px (mobile) / 560px (desktop).
class AICoachConfigView extends StatefulWidget {
  const AICoachConfigView({super.key, this.onConfigured, this.embedded = false});

  /// Callback tras conectar con éxito. Si es null, hace Get.back().
  final VoidCallback? onConfigured;

  /// true cuando se renderiza dentro de otra vista (sin Scaffold propio).
  final bool embedded;

  @override
  State<AICoachConfigView> createState() => _AICoachConfigViewState();
}

class _AICoachConfigViewState extends State<AICoachConfigView>
    with SingleTickerProviderStateMixin {
  late final AICoachController controller;
  final _keyController = TextEditingController();
  final _obscure = ValueNotifier<bool>(true);
  final _hasText = ValueNotifier<bool>(false);
  late final AnimationController _pulseCtrl;
  String _model = AICoachController.flashModel;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AICoachController>();
    _model = controller.currentModel.value;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _keyController.addListener(
        () => _hasText.value = _keyController.text.trim().isNotEmpty);
  }

  @override
  void dispose() {
    _keyController.dispose();
    _obscure.dispose();
    _hasText.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) {
      _keyController.text = text;
      _keyController.selection =
          TextSelection.collapsed(offset: text.length);
    }
  }

  Future<void> _connect() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return;
    FocusScope.of(context).unfocus();
    final ok = await controller.configureApiKey(key, model: _model);
    if (!mounted) return;
    if (ok) {
      if (widget.onConfigured != null) {
        widget.onConfigured!();
      } else {
        Get.back();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo conectar. Revisa tu clave.'),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    final maxW = isWide ? 560.0 : 380.0;

    final content = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOrb(),
              const SizedBox(height: 28),
              Text(
                'Activa tu Coach financiero',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: isWide ? 32 : 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Conecta tu clave de Gemini para desbloquear análisis '
                'con IA, sugerencias de ahorro y un asistente que actúa por ti.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: isWide ? 18 : 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              _buildCard(isWide),
              const SizedBox(height: 24),
              _buildConnectButton(),
              const SizedBox(height: 16),
              _buildSecurityFooter(),
            ],
          ),
        ),
      ),
    );

    if (widget.embedded) return content;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
        ),
      ),
      body: content,
    );
  }

  Widget _buildOrb() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, child) {
        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // pulsing rings
              for (var i = 0; i < 2; i++)
                _ring(i),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 44),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ring(int index) {
    final progress = (_pulseCtrl.value + index * 0.5) % 1.0;
    final scale = 0.8 + progress * 0.7;
    final opacity = (1 - progress) * 0.5;
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: opacity),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(bool isWide) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 28 : 22),
      decoration: BoxDecoration(
        color: dark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.06)
              : AppTheme.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 30,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('CLAVE API DE GEMINI'),
          const SizedBox(height: 8),
          _buildKeyField(cs, dark),
          const SizedBox(height: 20),
          _label('MODELO DE IA'),
          const SizedBox(height: 8),
          _buildModelSelector(dark),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );

  Widget _buildKeyField(ColorScheme cs, bool dark) {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscure,
      builder: (_, obscure, child) => TextField(
        controller: _keyController,
        obscureText: obscure,
        autocorrect: false,
        enableSuggestions: false,
        style: TextStyle(color: cs.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'sk-...',
          prefixIcon: const Icon(Icons.key_rounded,
              color: AppTheme.textHint, size: 18),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Pegar',
                icon: const Icon(Icons.content_paste_rounded,
                    size: 18, color: AppTheme.textHint),
                onPressed: _paste,
              ),
              IconButton(
                tooltip: obscure ? 'Mostrar' : 'Ocultar',
                icon: Icon(
                  obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 18,
                  color: AppTheme.textHint,
                ),
                onPressed: () => _obscure.value = !obscure,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelSelector(bool dark) {
    return Row(
      children: [
        Expanded(
          child: _ModelChip(
            icon: Icons.bolt_rounded,
            label: 'Flash',
            sub: '(rápido)',
            selected: _model == AICoachController.flashModel,
            onTap: () =>
                setState(() => _model = AICoachController.flashModel),
            dark: dark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModelChip(
            icon: Icons.psychology_rounded,
            label: 'Pro',
            sub: '(potente)',
            selected: _model == AICoachController.proModel,
            onTap: () => setState(() => _model = AICoachController.proModel),
            dark: dark,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _hasText,
      builder: (_, hasText, child) => Obx(() {
        final loading = controller.isConfiguringApi.value;
        final enabled = hasText && !loading;
        return Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: enabled ? _connect : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: loading
                        ? const [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                          ]
                        : const [
                            Text(
                              'Conectar y empezar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 18),
                          ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSecurityFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded,
            size: 13, color: AppTheme.textHint),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Tu clave se guarda cifrada y nunca se comparte.',
            style: TextStyle(color: AppTheme.textHint, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ModelChip extends StatelessWidget {
  const _ModelChip({
    required this.icon,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
    required this.dark,
  });

  final IconData icon;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? AppTheme.inputFillDark : AppTheme.inputFillLight;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : (dark
                    ? AppTheme.inputBorderDark
                    : AppTheme.inputBorderLight),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppTheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              sub,
              style: TextStyle(
                color: AppTheme.textHint,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
