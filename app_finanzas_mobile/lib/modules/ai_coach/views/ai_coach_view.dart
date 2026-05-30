// AI Coach view — light fintech redesign.
// Basado en los diseños de doc/diseno/ai Coach (Stitch: chat / onboarding /
// panel, mobile + desktop). Mapea AICoachController (messages, agentTodos,
// pendingApproval/HITL, isConfigured, isTyping).
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_service.dart';
import '../controllers/ai_coach_controller.dart';
import '../agent/agent_tools.dart';

// Paleta local (light only).
const _kBg = Color(0xFFF8FAFC);
const _kSurface = Colors.white;
const _kBorder = Color(0xFFEDEAF6);
const _kInputBorder = Color(0xFFE2E0F7);
const _kInk = Color(0xFF1A1C1C);
const _kInk2 = Color(0xFF4A4455);
const _kHint = Color(0xFF7B7487);
const _kViolet = AppTheme.primary; // 0xFF7C3AED
const _kAi = AppTheme.accentAI; // 0xFF8B5CF6
const _kVioletSoft = Color(0xFFEDE9FE);
const _kAmber = AppTheme.accentWarning;
const _kGreen = AppTheme.accentGreen;
const _kRed = AppTheme.accentRed;

class AICoachView extends StatelessWidget {
  const AICoachView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AICoachController>()
        ? Get.find<AICoachController>()
        : Get.put(AICoachController());

    return Container(
      color: _kBg,
      child: Obx(() {
        if (controller.isInitializing.value) {
          return const Center(
            child: CircularProgressIndicator(color: _kViolet),
          );
        }
        if (!controller.isConfigured.value) {
          return _OnboardingScreen(controller: controller);
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 1024) {
              return _DesktopChat(controller: controller);
            }
            return _MobileChat(controller: controller);
          },
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// AI ORB — identidad reutilizable
// ════════════════════════════════════════════════════════════════════════

class _AiOrb extends StatefulWidget {
  final double size;
  final bool pulsing;
  const _AiOrb({required this.size, this.pulsing = false});

  @override
  State<_AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<_AiOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.pulsing) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant _AiOrb old) {
    super.didUpdateWidget(old);
    if (widget.pulsing && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.pulsing && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final glow = widget.pulsing
            ? 0.25 + 0.20 * (0.5 + 0.5 * (_c.value * 2 - 1).abs())
            : 0.22;
        return Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kAi, _kViolet],
            ),
            boxShadow: [
              BoxShadow(
                color: _kViolet.withValues(alpha: glow),
                blurRadius: s * 0.5,
                spreadRadius: s * 0.05,
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: s * 0.5,
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ONBOARDING — API key no configurada
// ════════════════════════════════════════════════════════════════════════

class _OnboardingScreen extends StatefulWidget {
  final AICoachController controller;
  const _OnboardingScreen({required this.controller});

  @override
  State<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen> {
  final _keyCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final ok = await widget.controller.configureApiKey(_keyCtrl.text);
    if (ok) {
      SnackbarService.showSuccess('Coach activado', 'IA lista para ayudarte.');
    } else {
      SnackbarService.showError(
        'No se pudo conectar',
        'Verifica tu clave de Gemini e intenta de nuevo.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1024;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 32 : 20,
            vertical: 40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 560 : 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _AiOrb(size: wide ? 112 : 92, pulsing: true)),
                  const SizedBox(height: 24),
                  Text(
                    'Activa tu Coach financiero',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: wide ? 30 : 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: _kInk,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Conecta tu clave de Gemini para desbloquear análisis con '
                    'IA, sugerencias de ahorro y un asistente que actúa por ti.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: _kInk2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Expanded(
                        child: _ValueProp(
                          icon: Icons.auto_awesome,
                          color: _kViolet,
                          label: 'Análisis\ninteligente',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _ValueProp(
                          icon: Icons.bolt_rounded,
                          color: _kGreen,
                          label: 'Acciones\nautomáticas',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _ValueProp(
                          icon: Icons.verified_user_outlined,
                          color: Color(0xFF3B82F6),
                          label: 'Tú apruebas\ntodo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _kBorder),
                      boxShadow: [
                        BoxShadow(
                          color: _kViolet.withValues(alpha: 0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'CLAVE API DE GEMINI',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                            color: _kHint,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _kBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _kInputBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.key_rounded,
                                  size: 20, color: _kHint),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _keyCtrl,
                                  obscureText: _obscure,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _kInk,
                                  ),
                                  decoration: const InputDecoration(
                                    isCollapsed: true,
                                    border: InputBorder.none,
                                    hintText: 'AIza…',
                                    hintStyle: TextStyle(color: _kHint),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: _kHint,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.open_in_new_rounded,
                                size: 14, color: _kViolet),
                            const SizedBox(width: 6),
                            Flexible(
                              child: GestureDetector(
                                onTap: () => SnackbarService.showWarning(
                                  'Google AI Studio',
                                  'aistudio.google.com/app/apikey',
                                ),
                                child: const Text(
                                  '¿Cómo obtengo mi clave?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _kViolet,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 52,
                          child: Obx(
                            () => ElevatedButton(
                              onPressed:
                                  widget.controller.isConfiguringApi.value
                                      ? null
                                      : _connect,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kViolet,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                disabledBackgroundColor:
                                    _kViolet.withValues(alpha: 0.5),
                              ),
                              child: widget.controller.isConfiguringApi.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : const Text(
                                      'Conectar y empezar',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.lock_outline_rounded, size: 13, color: _kHint),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Tu clave se guarda cifrada y nunca se comparte.',
                          style: TextStyle(fontSize: 11, color: _kHint),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ValueProp extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _ValueProp({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: _kInk2,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// MOBILE CHAT
// ════════════════════════════════════════════════════════════════════════

class _MobileChat extends StatefulWidget {
  final AICoachController controller;
  const _MobileChat({required this.controller});

  @override
  State<_MobileChat> createState() => _MobileChatState();
}

class _MobileChatState extends State<_MobileChat> {
  final _scroll = ScrollController();
  bool _showTodos = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Column(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: _kSurface,
            border: Border(bottom: BorderSide(color: _kBorder)),
          ),
          child: Row(
            children: [
              const _AiOrb(size: 30),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coach',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kInk,
                    ),
                  ),
                  Obx(
                    () => Text(
                      c.isTyping.value ? 'escribiendo…' : 'En línea',
                      style: const TextStyle(fontSize: 11, color: _kHint),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Obx(() {
                final n = c.agentTodos.length;
                return _HeaderIconButton(
                  icon: Icons.checklist_rounded,
                  badge: n > 0 ? n.toString() : null,
                  onTap: () => setState(() => _showTodos = !_showTodos),
                );
              }),
              _HeaderIconButton(
                icon: Icons.refresh_rounded,
                onTap: c.refreshContext,
              ),
              _HeaderIconButton(
                icon: Icons.delete_outline_rounded,
                onTap: c.clearHistory,
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Obx(() {
                final msgs = c.messages;
                _autoScroll();
                if (msgs.isEmpty) {
                  return _WelcomeBody(controller: c);
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) => _MessageItem(msg: msgs[i]),
                );
              }),
              if (_showTodos)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _showTodos = false),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: SizedBox(
                          width: 300,
                          child: _AgentPanel(controller: c),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Obx(() {
          final p = c.pendingApproval.value;
          if (p == null) return const SizedBox.shrink();
          return _HitlCard(controller: c, approval: p);
        }),
        _InputBar(controller: widget.controller),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// DESKTOP CHAT
// ════════════════════════════════════════════════════════════════════════

class _DesktopChat extends StatefulWidget {
  final AICoachController controller;
  const _DesktopChat({required this.controller});

  @override
  State<_DesktopChat> createState() => _DesktopChatState();
}

class _DesktopChatState extends State<_DesktopChat> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: _kSurface,
                  border: Border(bottom: BorderSide(color: _kBorder)),
                ),
                child: Row(
                  children: [
                    const _AiOrb(size: 32),
                    const SizedBox(width: 12),
                    const Text(
                      'Coach financiero',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kVioletSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          c.currentModel.value
                              .replaceAll('gemini-', '')
                              .replaceAll('-', ' '),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _kViolet,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    _HeaderIconButton(
                      icon: Icons.refresh_rounded,
                      onTap: c.refreshContext,
                    ),
                    _HeaderIconButton(
                      icon: Icons.delete_outline_rounded,
                      onTap: c.clearHistory,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  final msgs = c.messages;
                  _autoScroll();
                  if (msgs.isEmpty) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: _WelcomeBody(controller: c),
                      ),
                    );
                  }
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        itemCount: msgs.length,
                        itemBuilder: (context, i) =>
                            _MessageItem(msg: msgs[i]),
                      ),
                    ),
                  );
                }),
              ),
              Obx(() {
                final p = c.pendingApproval.value;
                if (p == null) return const SizedBox.shrink();
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: _HitlCard(controller: c, approval: p),
                  ),
                );
              }),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: _InputBar(controller: c),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 320,
          decoration: const BoxDecoration(
            color: _kSurface,
            border: Border(left: BorderSide(color: _kBorder)),
          ),
          child: _AgentPanel(controller: c),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// WELCOME / EMPTY
// ════════════════════════════════════════════════════════════════════════

class _WelcomeBody extends StatelessWidget {
  final AICoachController controller;
  const _WelcomeBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    final suggestions = controller.dynamicSuggestions;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 24),
        const Center(child: _AiOrb(size: 64, pulsing: true)),
        const SizedBox(height: 18),
        const Text(
          '¡Hola! Soy tu coach financiero 💜',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _kInk,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pregúntame sobre tus finanzas o pídeme que actúe por ti.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: _kInk2),
        ),
        const SizedBox(height: 24),
        ...suggestions.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SuggestionCard(
              text: s,
              onTap: () => controller.sendMessage(s),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionCard({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kVioletSoft,
                ),
                child: const Icon(Icons.bolt_rounded,
                    size: 16, color: _kViolet),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 13.5, color: _kInk),
                ),
              ),
              const Icon(Icons.arrow_outward_rounded,
                  size: 16, color: _kHint),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// MESSAGE ITEM
// ════════════════════════════════════════════════════════════════════════

class _MessageItem extends StatelessWidget {
  final AIChatMessage msg;
  const _MessageItem({required this.msg});

  @override
  Widget build(BuildContext context) {
    if (msg.isToolCall) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ToolCallChip(msg: msg),
      );
    }
    if (msg.role == 'user') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: const BoxDecoration(
                  color: _kViolet,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: Text(
                  msg.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final isError = msg.isError;
    final isStreamingEmpty = msg.isStreaming && msg.content.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: _AiOrb(size: 26),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isError ? _kRed.withValues(alpha: 0.06) : _kSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: isError
                      ? _kRed.withValues(alpha: 0.25)
                      : _kBorder,
                ),
              ),
              child: isStreamingEmpty
                  ? const _TypingDots()
                  : MarkdownBody(
                      data: msg.content,
                      shrinkWrap: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isError ? _kRed : _kInk,
                        ),
                        strong: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _kInk,
                        ),
                        listBullet:
                            const TextStyle(fontSize: 14, color: _kInk),
                        code: TextStyle(
                          backgroundColor: _kVioletSoft,
                          color: _kViolet,
                          fontSize: 13,
                        ),
                        a: const TextStyle(color: _kViolet),
                        h1: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _kInk),
                        h2: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _kInk),
                        h3: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kInk),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 16,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = (_c.value + i * 0.2) % 1.0;
              final o = 0.3 + 0.7 * (1 - (t * 2 - 1).abs());
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kViolet.withValues(alpha: o),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _ToolCallChip extends StatelessWidget {
  final AIChatMessage msg;
  const _ToolCallChip({required this.msg});

  @override
  Widget build(BuildContext context) {
    final approved = msg.isToolApproved;
    Color stripe;
    Widget statusIcon;
    if (approved == null) {
      stripe = _kViolet;
      statusIcon = const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: _kViolet),
      );
    } else if (approved) {
      stripe = _kGreen;
      statusIcon =
          const Icon(Icons.check_circle_rounded, size: 16, color: _kGreen);
    } else {
      stripe = _kRed;
      statusIcon = const Icon(Icons.cancel_rounded, size: 16, color: _kRed);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kInputBorder),
        ),
        child: Row(
          children: [
            Container(width: 3, height: 28, color: stripe),
            const SizedBox(width: 10),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _kVioletSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.build_rounded,
                  size: 15, color: _kViolet),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg.content,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kInk,
                ),
              ),
            ),
            statusIcon,
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// HITL CARD
// ════════════════════════════════════════════════════════════════════════

class _HitlCard extends StatelessWidget {
  final AICoachController controller;
  final PendingApproval approval;
  const _HitlCard({required this.controller, required this.approval});

  @override
  Widget build(BuildContext context) {
    final label = AgentToolSpecs.displayLabel(approval.toolName);
    final args = approval.args.entries
        .where((e) => e.value != null && '${e.value}'.trim().isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kAmber.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: _kAmber.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: _kAmber, width: 4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded,
                    size: 18, color: _kAmber),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Aprobación requerida',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kInk,
                        ),
                      ),
                      Text(
                        'El Coach quiere ejecutar una acción',
                        style: TextStyle(fontSize: 12, color: _kHint),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                ),
                if (args.isNotEmpty) const SizedBox(height: 8),
                ...args.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            _humanizeKey(e.key),
                            style: const TextStyle(
                                fontSize: 12, color: _kHint),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${e.value}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: _kInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: controller.rejectHITL,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kInk2,
                        side: const BorderSide(color: _kInputBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Rechazar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: controller.approveHITL,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kViolet,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Aprobar y ejecutar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _humanizeKey(String k) {
    const map = {
      'amount': 'Monto',
      'concept': 'Concepto',
      'type': 'Tipo',
      'category_name': 'Categoría',
      'date': 'Fecha',
      'name': 'Nombre',
      'target_amount': 'Objetivo',
      'target_date': 'Fecha límite',
      'limit': 'Límite',
      'goal_name': 'Meta',
      'debt_name': 'Deuda',
      'subscription_name': 'Suscripción',
      'view': 'Vista',
      'id': 'ID',
    };
    return map[k] ?? k;
  }
}

// ════════════════════════════════════════════════════════════════════════
// AGENT PANEL
// ════════════════════════════════════════════════════════════════════════

class _AgentPanel extends StatelessWidget {
  final AICoachController controller;
  const _AgentPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kSurface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  const Text(
                    'Tareas del Coach',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kInk,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final n = controller.agentTodos.length;
                    if (n == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kVioletSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$n',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _kViolet,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Divider(height: 1, color: _kBorder),
            Expanded(
              child: Obx(() {
                final todos = controller.agentTodos.toList();
                if (todos.isEmpty) {
                  return _PanelContextSnapshot(controller: controller);
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: todos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _TodoRow(todo: todos[i]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  final AgentTodo todo;
  const _TodoRow({required this.todo});

  @override
  Widget build(BuildContext context) {
    Widget icon;
    Color textColor = _kInk;
    switch (todo.status) {
      case 'completed':
        icon = const Icon(Icons.check_circle_rounded,
            size: 18, color: _kGreen);
        textColor = _kHint;
        break;
      case 'in_progress':
        icon = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: _kViolet),
        );
        break;
      case 'failed':
        icon = const Icon(Icons.cancel_rounded, size: 18, color: _kRed);
        textColor = _kRed;
        break;
      default:
        icon = const Icon(Icons.radio_button_unchecked_rounded,
            size: 18, color: Color(0xFFCCC3D8));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 1), child: icon),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            todo.content,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: textColor,
              decoration: todo.status == 'completed'
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _PanelContextSnapshot extends StatelessWidget {
  final AICoachController controller;
  const _PanelContextSnapshot({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.dataset_outlined, size: 16, color: _kViolet),
                  SizedBox(width: 8),
                  Text(
                    'Contexto activo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kInk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  controller.contextSummary.value.isEmpty
                      ? 'Sin datos cargados aún.'
                      : controller.contextSummary.value,
                  style: const TextStyle(fontSize: 12.5, color: _kInk2),
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: _kHint),
                    const SizedBox(width: 6),
                    Text(
                      controller.currentModel.value
                          .replaceAll('gemini-', 'Gemini '),
                      style: const TextStyle(fontSize: 12, color: _kHint),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Las tareas del Coach aparecerán aquí cuando planifique un análisis.',
          style: TextStyle(fontSize: 12, color: _kHint, height: 1.4),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// INPUT BAR
// ════════════════════════════════════════════════════════════════════════

class _InputBar extends StatelessWidget {
  final AICoachController controller;
  const _InputBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints:
                    const BoxConstraints(minHeight: 48, maxHeight: 140),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _kInputBorder),
                ),
                child: TextField(
                  controller: controller.textController,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (v) => controller.sendMessage(v),
                  style: const TextStyle(fontSize: 14, color: _kInk),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Escribe a tu Coach…',
                    hintStyle: TextStyle(color: _kHint),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Obx(
              () => _SendButton(
                busy: controller.isTyping.value,
                onTap: () =>
                    controller.sendMessage(controller.textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;
  const _SendButton({required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: busy ? _kViolet.withValues(alpha: 0.5) : _kViolet,
          boxShadow: busy
              ? null
              : [
                  BoxShadow(
                    color: _kViolet.withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: busy
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.arrow_upward_rounded, color: Colors.white),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// SHARED
// ════════════════════════════════════════════════════════════════════════

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon, size: 22, color: _kHint),
          onPressed: onTap,
        ),
        if (badge != null)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: const BoxDecoration(
                color: _kViolet,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
