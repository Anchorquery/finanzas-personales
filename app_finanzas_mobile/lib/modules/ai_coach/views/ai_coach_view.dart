import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routes/app_routes.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/ai_coach_controller.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────

class _C {
  static const userBubbleStart = Color(0xFF3B5BFF);
  static const userBubbleEnd = Color(0xFF2B4BEE);
  static const aiBubbleColor = Color(0xFF192236);
  static const aiBubbleBorder = Color(0x14FFFFFF);
  static const aiAvatarStart = Color(0xFF8B5CF6);
  static const aiAvatarEnd = Color(0xFF6D28D9);
  static const toolCallBg = Color(0xFF111827);
  static const inputBg = Color(0xFF0D1523);
  static const headerBg = Color(0xCC0F172A);
}

// ─── Main view ────────────────────────────────────────────────────────────────

class AICoachView extends StatefulWidget {
  const AICoachView({super.key});

  @override
  State<AICoachView> createState() => _AICoachViewState();
}

class _AICoachViewState extends State<AICoachView>
    with SingleTickerProviderStateMixin {
  late final AICoachController controller;
  final ScrollController _scrollController = ScrollController();
  final _showScrollToBottom = ValueNotifier<bool>(false);
  final _inputFocusNode = FocusNode();
  final _inputFocused = ValueNotifier<bool>(false);

  late final AnimationController _avatarCtrl;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AICoachController>();

    _avatarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scrollController.addListener(_onScroll);
    _inputFocusNode.addListener(() {
      _inputFocused.value = _inputFocusNode.hasFocus;
    });

    ever(controller.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

    // HITL: show approval dialog whenever pendingApproval is set
    ever(controller.pendingApproval, (approval) {
      if (approval != null && mounted) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _showHITLDialog(approval));
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final dist =
        _scrollController.position.maxScrollExtent - _scrollController.offset;
    _showScrollToBottom.value = dist > 200;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _avatarCtrl.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _showScrollToBottom.dispose();
    _inputFocused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          const Positioned.fill(child: _BackgroundPattern()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Stack(
                    children: [
                      Obx(() {
                        if (controller.isInitializing.value) {
                          return _buildLoadingState();
                        }
                        if (!controller.isConfigured.value &&
                            controller.messages.isEmpty) {
                          return _buildNoApiState();
                        }
                        return _buildChatArea();
                      }),
                      Positioned(
                        bottom: 12,
                        right: 16,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _showScrollToBottom,
                          builder: (_, show, child) => AnimatedScale(
                            scale: show ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
                            child: child,
                          ),
                          child: _ScrollToBottomFab(onTap: _scrollToBottom),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => controller.isConfigured.value
                    ? _buildInputBar(context)
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: _C.headerBg,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.07),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(4, 10, 8, 10),
          child: Row(
            children: [
              if (!isWide)
                IconButton(
                  icon: const Icon(Icons.menu_rounded,
                      color: Colors.white, size: 24),
                  onPressed: () => Get.find<HomeController>()
                      .scaffoldKey
                      .currentState
                      ?.openDrawer(),
                ),
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _avatarCtrl,
                builder: (_, child) => Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      center: Alignment.center,
                      startAngle: _avatarCtrl.value * 2 * math.pi,
                      endAngle:
                          _avatarCtrl.value * 2 * math.pi + 2 * math.pi,
                      colors: const [
                        Color(0xFF8B5CF6),
                        Color(0xFF6366F1),
                        Color(0xFF3B82F6),
                        Color(0xFF8B5CF6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _C.aiAvatarStart.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppL10n.of(context).aiCoachTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Obx(() => _buildStatusText()),
                  ],
                ),
              ),
              Obx(() => controller.isConfigured.value
                  ? _buildHeaderActions()
                  : const SizedBox(width: 8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    if (controller.isInitializing.value) {
      return _StatusChip(text: 'Cargando...', color: Colors.white38, dot: false);
    }
    if (controller.isRefreshingContext.value) {
      return _StatusChip(
          text: 'Actualizando datos', color: AppTheme.accentAI, dot: false);
    }
    if (!controller.isConfigured.value) {
      return _StatusChip(
          text: 'Sin configurar', color: AppTheme.accentRed, dot: false);
    }
    if (controller.isTyping.value) {
      return _StatusChip(
          text: 'Analizando...', color: AppTheme.accentAI, dot: false);
    }
    return _StatusChip(
      text: controller.contextSummary.value.isEmpty
          ? controller.currentModel.value
          : controller.contextSummary.value,
      color: AppTheme.accentGreen,
      dot: true,
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderBtn(
          icon: Icons.refresh_rounded,
          tooltip: 'Actualizar datos',
          loading: controller.isRefreshingContext.value,
          onTap: controller.isRefreshingContext.value
              ? null
              : controller.refreshContext,
        ),
        _HeaderBtn(
          icon: Icons.delete_outline_rounded,
          tooltip: 'Limpiar chat',
          onTap: controller.messages.isEmpty ? null : _confirmClear,
        ),
      ],
    );
  }

  // ── Loading state ─────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _avatarCtrl,
            builder: (_, child) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: SweepGradient(
                  startAngle: _avatarCtrl.value * 2 * math.pi,
                  endAngle: _avatarCtrl.value * 2 * math.pi + 2 * math.pi,
                  colors: const [
                    Color(0xFF8B5CF6),
                    Color(0xFF6366F1),
                    Color(0xFF3B82F6),
                    Color(0xFF8B5CF6),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Preparando tu coach...',
            style: TextStyle(
                color: Colors.white60, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cargando datos financieros',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── No API state ──────────────────────────────────────────────────────────

  Widget _buildNoApiState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _avatarCtrl,
            builder: (_, child) => Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: SweepGradient(
                  startAngle: _avatarCtrl.value * 2 * math.pi,
                  endAngle: _avatarCtrl.value * 2 * math.pi + 2 * math.pi,
                  colors: const [
                    Color(0xFF8B5CF6),
                    Color(0xFF6366F1),
                    Color(0xFF3B82F6),
                    Color(0xFF8B5CF6),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _C.aiAvatarStart.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 44),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Coach Financiero\nlisto para ayudarte',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Conecta tu API key de Google Gemini para activar el asistente. Gratis y en 1 minuto.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 14,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _C.aiAvatarStart.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Get.toNamed(Routes.settings),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.key_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Configurar API Key',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildCapabilitiesGrid(),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesGrid() {
    final caps = [
      (Icons.analytics_rounded, 'Analiza gastos', 'Por categoría y tendencias'),
      (Icons.savings_rounded, 'Metas de ahorro', 'Tiempo estimado y aportes'),
      (Icons.credit_card_rounded, 'Deudas', 'Estrategia de pago óptima'),
      (
        Icons.notifications_active_rounded,
        'Presupuestos',
        'Alertas en tiempo real'
      ),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: caps
          .map((c) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(c.$1, color: AppTheme.accentAI, size: 20),
                    const Spacer(),
                    Text(c.$2,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(c.$3,
                        style:
                            const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // ── Chat area ─────────────────────────────────────────────────────────────

  Widget _buildChatArea() {
    return Column(
      children: [
        // Todos panel (shows agent plan while typing)
        Obx(() {
          final todos = controller.agentTodos;
          if (todos.isEmpty) return const SizedBox.shrink();
          return _TodosPanel(todos: todos);
        }),
        Expanded(
          child: Obx(() {
            if (controller.messages.isEmpty) return _buildEmptyChat();
            return _buildMessageList();
          }),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final msg = controller.messages[index];
        final prev = index > 0 ? controller.messages[index - 1] : null;

        // Tool call bubbles — special compact style
        if (msg.isToolCall) {
          return _AnimatedMessageEntry(
            key: ValueKey('tool_$index'),
            isUser: false,
            child: _ToolCallBubble(msg: msg),
          );
        }

        final showTimestamp = prev == null ||
            (!prev.isToolCall &&
                msg.timestamp.difference(prev.timestamp).inMinutes > 5);

        final nextMsg = index < controller.messages.length - 1
            ? controller.messages[index + 1]
            : null;
        final isLastInGroup =
            nextMsg == null || nextMsg.role != msg.role || nextMsg.isToolCall;

        return _AnimatedMessageEntry(
          key: ValueKey('msg_$index'),
          isUser: msg.role == 'user',
          child: Column(
            children: [
              if (showTimestamp) _TimestampPill(dt: msg.timestamp),
              _MessageBubble(
                msg: msg,
                isLastInGroup: isLastInGroup,
                onCopy: msg.role == 'assistant' && !msg.isStreaming
                    ? () => _copyMessage(msg.content)
                    : null,
                onRetrySettings:
                    msg.isError ? () => Get.toNamed(Routes.settings) : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyChat() {
    return Obx(() {
      final suggestions = controller.dynamicSuggestions;
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _avatarCtrl,
              builder: (_, child) => Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: SweepGradient(
                    startAngle: _avatarCtrl.value * 2 * math.pi,
                    endAngle: _avatarCtrl.value * 2 * math.pi + 2 * math.pi,
                    colors: const [
                      Color(0xFF8B5CF6),
                      Color(0xFF6366F1),
                      Color(0xFF3B82F6),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: _C.aiAvatarStart.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 34),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¿En qué te puedo ayudar?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pregúntame sobre tus finanzas personales',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.8,
              children: suggestions
                  .map((s) => _SuggestionChip(
                        text: s,
                        onTap: () => controller.sendMessage(s),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
    });
  }

  // ── Input bar ─────────────────────────────────────────────────────────────

  Widget _buildInputBar(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return ValueListenableBuilder<bool>(
      valueListenable: _inputFocused,
      builder: (_, focused, child) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          border: Border(
            top: BorderSide(
              color: focused
                  ? _C.aiAvatarStart.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.07),
              width: focused ? 1.5 : 1,
            ),
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: _C.aiAvatarStart.withValues(alpha: 0.12),
                    blurRadius: 20,
                    spreadRadius: -4,
                    offset: const Offset(0, -4),
                  )
                ]
              : [],
        ),
        padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + bottom),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: _C.inputBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: focused
                        ? _C.aiAvatarStart.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: controller.textController,
                        focusNode: _inputFocusNode,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, height: 1.45),
                        decoration: InputDecoration(
                          hintText: 'Pregunta sobre tus finanzas...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (v) {
                          controller.sendMessage(v);
                          _inputFocusNode.requestFocus();
                        },
                        maxLines: 5,
                        minLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Obx(() => _SendButton(
                  isLoading: controller.isTyping.value,
                  onTap: controller.isTyping.value
                      ? null
                      : () => controller
                          .sendMessage(controller.textController.text),
                )),
          ],
        ),
      ),
    );
  }

  // ── HITL dialog ───────────────────────────────────────────────────────────

  void _showHITLDialog(PendingApproval approval) {
    Get.dialog(
      _HITLDialog(
        approval: approval,
        onApprove: controller.approveHITL,
        onReject: controller.rejectHITL,
      ),
      barrierDismissible: false,
    );
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Mensaje copiado', style: TextStyle(fontSize: 13)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _confirmClear() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A2540),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppTheme.accentWarning, size: 20),
            SizedBox(width: 10),
            Text('Limpiar conversación',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Se borrarán todos los mensajes. No se puede deshacer.',
          style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.accentRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Get.back();
                controller.clearHistory();
              },
              child: const Text('Limpiar',
                  style: TextStyle(color: AppTheme.accentRed)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Todos panel ──────────────────────────────────────────────────────────────

class _TodosPanel extends StatefulWidget {
  const _TodosPanel({required this.todos});
  final List<AgentTodo> todos;

  @override
  State<_TodosPanel> createState() => _TodosPanelState();
}

class _TodosPanelState extends State<_TodosPanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final completed =
        widget.todos.where((t) => t.status == 'completed').length;
    final total = widget.todos.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _C.aiAvatarStart.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_C.aiAvatarStart, _C.aiAvatarEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(Icons.list_alt_rounded,
                        color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Plan del agente',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _C.aiAvatarStart.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$completed/$total',
                      style: const TextStyle(
                          color: _C.aiAvatarStart,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white38,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          // Todo items
          if (_expanded) ...[
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.todos
                    .map((todo) => _TodoItem(todo: todo))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TodoItem extends StatelessWidget {
  const _TodoItem({required this.todo});
  final AgentTodo todo;

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final IconData statusIcon;

    switch (todo.status) {
      case 'completed':
        statusColor = AppTheme.accentGreen;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'in_progress':
        statusColor = AppTheme.accentAI;
        statusIcon = Icons.radio_button_checked_rounded;
        break;
      default:
        statusColor = Colors.white24;
        statusIcon = Icons.radio_button_unchecked_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(statusIcon, color: statusColor, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              todo.content,
              style: TextStyle(
                color: todo.status == 'completed'
                    ? Colors.white38
                    : Colors.white70,
                fontSize: 12,
                decoration: todo.status == 'completed'
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: Colors.white38,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tool call bubble ─────────────────────────────────────────────────────────

class _ToolCallBubble extends StatelessWidget {
  const _ToolCallBubble({required this.msg});
  final AIChatMessage msg;

  IconData _icon() {
    switch (msg.toolName) {
      case 'write_todos':
        return Icons.list_alt_rounded;
      case 'get_financial_summary':
      case 'search_transactions':
        return Icons.search_rounded;
      case 'get_savings_goals':
      case 'create_savings_goal':
      case 'add_savings_contribution':
        return Icons.savings_rounded;
      case 'get_debts':
      case 'register_debt_payment':
        return Icons.credit_card_rounded;
      case 'get_subscriptions':
      case 'cancel_subscription':
        return Icons.repeat_rounded;
      case 'get_budgets':
      case 'create_budget':
        return Icons.account_balance_wallet_rounded;
      case 'get_accounts':
        return Icons.account_balance_rounded;
      case 'get_top_merchants':
        return Icons.leaderboard_rounded;
      case 'compare_periods':
        return Icons.compare_arrows_rounded;
      case 'forecast_cashflow':
        return Icons.trending_up_rounded;
      case 'create_transaction':
        return Icons.add_circle_outline_rounded;
      case 'delete_transaction':
        return Icons.delete_outline_rounded;
      case 'open_view':
        return Icons.open_in_new_rounded;
      case 'task':
        return Icons.psychology_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final approved = msg.isToolApproved;
    final isExecuting = approved == null && msg.toolName != null;

    Color accentColor = AppTheme.accentAI;
    if (approved == true) accentColor = AppTheme.accentGreen;
    if (approved == false) accentColor = AppTheme.accentRed;

    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _C.toolCallBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isExecuting)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: accentColor,
                ),
              )
            else
              Icon(_icon(), size: 12, color: accentColor),
            const SizedBox(width: 7),
            Text(
              msg.content,
              style: TextStyle(
                color: accentColor.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (approved == true) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_rounded,
                  size: 11, color: AppTheme.accentGreen.withValues(alpha: 0.7)),
            ],
            if (approved == false) ...[
              const SizedBox(width: 6),
              Icon(Icons.close_rounded,
                  size: 11, color: AppTheme.accentRed.withValues(alpha: 0.7)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── HITL approval dialog ─────────────────────────────────────────────────────

class _HITLDialog extends StatelessWidget {
  const _HITLDialog({
    required this.approval,
    required this.onApprove,
    required this.onReject,
  });
  final PendingApproval approval;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  String _argsPreview() {
    final args = approval.args;
    final lines = <String>[];
    args.forEach((k, v) {
      if (v != null && v.toString().isNotEmpty) {
        lines.add('• $k: $v');
      }
    });
    return lines.join('\n');
  }

  String _toolDescription() {
    final args = approval.args;
    switch (approval.toolName) {
      case 'create_transaction':
        final type = args['type'] == 'income' ? 'ingreso' : 'gasto';
        return 'Registrar un $type de \$${args['amount']} por "${args['concept'] ?? ''}".';
      case 'delete_transaction':
        return 'Eliminar transacción${args['concept_hint'] != null ? ' "${args['concept_hint']}"' : ''}.';
      case 'create_budget':
        return 'Crear presupuesto de \$${args['limit']} para "${args['category_name']}".';
      case 'create_savings_goal':
        return 'Crear meta "${args['name']}" con objetivo \$${args['target_amount']}.';
      case 'add_savings_contribution':
        return 'Aportar \$${args['amount']} a la meta "${args['goal_name']}".';
      case 'register_debt_payment':
        return 'Registrar pago de \$${args['amount']} a la deuda "${args['debt_name']}".';
      case 'cancel_subscription':
        return 'Cancelar la suscripción "${args['subscription_name']}".';
      case 'open_view':
        return 'Abrir vista: ${args['view']}.';
      default:
        return 'El agente quiere ejecutar: ${approval.toolName}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A2540),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: _C.aiAvatarStart.withValues(alpha: 0.2), width: 1),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_C.aiAvatarStart, _C.aiAvatarEnd],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.security_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          const Text('Acción del agente',
              style: TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _toolDescription(),
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          if (approval.args.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                _argsPreview(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.6,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            '¿Deseas permitir esta acción?',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            onReject();
          },
          child: const Text('Rechazar',
              style: TextStyle(color: AppTheme.accentRed)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.aiAvatarStart, _C.aiAvatarEnd],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton(
            onPressed: () {
              Get.back();
              onApprove();
            },
            child: const Text('Permitir',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

// ─── Animated message entry ────────────────────────────────────────────────────

class _AnimatedMessageEntry extends StatefulWidget {
  const _AnimatedMessageEntry({
    super.key,
    required this.isUser,
    required this.child,
  });
  final bool isUser;
  final Widget child;

  @override
  State<_AnimatedMessageEntry> createState() => _AnimatedMessageEntryState();
}

class _AnimatedMessageEntryState extends State<_AnimatedMessageEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: widget.isUser ? const Offset(0.15, 0) : const Offset(-0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ─── Message bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatefulWidget {
  const _MessageBubble({
    required this.msg,
    required this.isLastInGroup,
    this.onCopy,
    this.onRetrySettings,
  });
  final AIChatMessage msg;
  final bool isLastInGroup;
  final VoidCallback? onCopy;
  final VoidCallback? onRetrySettings;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.msg.role == 'user';
    final maxWidth = MediaQuery.of(context).size.width * 0.76;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUser)
              SizedBox(
                width: 32,
                child: widget.isLastInGroup
                    ? Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 6, bottom: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_C.aiAvatarStart, _C.aiAvatarEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: _C.aiAvatarStart.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 14),
                      )
                    : null,
              ),
            Flexible(
              child: GestureDetector(
                onTap: !isUser && widget.onCopy != null
                    ? () => setState(() => _showActions = !_showActions)
                    : null,
                onLongPress:
                    !isUser && widget.onCopy != null ? widget.onCopy : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      isUser
                          ? _UserBubble(msg: widget.msg)
                          : _AIBubble(
                              msg: widget.msg,
                              isLastInGroup: widget.isLastInGroup,
                              onRetrySettings: widget.onRetrySettings,
                            ),
                      if (_showActions && !isUser && widget.onCopy != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, right: 2),
                          child: GestureDetector(
                            onTap: () {
                              widget.onCopy!();
                              setState(() => _showActions = false);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.white12, width: 1),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.copy_rounded,
                                      size: 12, color: Colors.white54),
                                  SizedBox(width: 5),
                                  Text('Copiar',
                                      style: TextStyle(
                                          color: Colors.white54, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (isUser) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

// ─── User bubble ──────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.msg});
  final AIChatMessage msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.userBubbleStart, _C.userBubbleEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
            color: _C.userBubbleEnd.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          msg.content,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}

// ─── AI bubble ────────────────────────────────────────────────────────────────

class _AIBubble extends StatelessWidget {
  const _AIBubble({
    required this.msg,
    required this.isLastInGroup,
    this.onRetrySettings,
  });
  final AIChatMessage msg;
  final bool isLastInGroup;
  final VoidCallback? onRetrySettings;

  static final _mdStyle = MarkdownStyleSheet(
    p: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, height: 1.6),
    strong: const TextStyle(
        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
    em: const TextStyle(
        color: Color(0xFFCBD5E1), fontStyle: FontStyle.italic, fontSize: 14),
    listBullet: const TextStyle(color: AppTheme.accentAI, fontSize: 14),
    listIndent: 18,
    blockquoteDecoration: const BoxDecoration(
      border: Border(left: BorderSide(color: AppTheme.accentAI, width: 3)),
      color: Color(0x0A8B5CF6),
    ),
    blockquote: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
    tableHead: const TextStyle(
        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
    tableBody: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
    tableBorder: TableBorder.all(color: Color(0x1AFFFFFF), width: 1),
    tableHeadAlign: TextAlign.left,
    code: const TextStyle(
      backgroundColor: Color(0x1A8B5CF6),
      color: Color(0xFFA78BFA),
      fontSize: 13,
      fontFamily: 'monospace',
    ),
    codeblockDecoration: BoxDecoration(
      color: const Color(0x0D8B5CF6),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0x1A8B5CF6)),
    ),
    codeblockPadding: const EdgeInsets.all(14),
    h1: const TextStyle(
        color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
    h2: const TextStyle(
        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
    h3: const TextStyle(
        color: Color(0xFFCBD5E1), fontSize: 14, fontWeight: FontWeight.w600),
    a: const TextStyle(
        color: AppTheme.accentAI,
        decoration: TextDecoration.underline,
        decorationColor: AppTheme.accentAI),
    horizontalRuleDecoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF), width: 1)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (msg.isStreaming && msg.content.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: _bubbleDecoration(),
        child: const _TypingDots(),
      );
    }

    return Container(
      margin: const EdgeInsets.only(right: 48),
      decoration: msg.isError ? _errorDecoration() : _bubbleDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: msg.isStreaming ? '${msg.content}▌' : msg.content,
              styleSheet: _mdStyle,
              selectable: !msg.isStreaming,
              onTapLink: (text, href, title) async {
                if (href == null) return;
                final uri = Uri.tryParse(href);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            if (msg.isError && onRetrySettings != null) ...[
              const SizedBox(height: 10),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onRetrySettings,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.settings_rounded,
                        size: 12, color: AppTheme.accentAI),
                    SizedBox(width: 5),
                    Text(
                      'Ir a Configuración',
                      style: TextStyle(
                        color: AppTheme.accentAI,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration _bubbleDecoration() => BoxDecoration(
        color: _C.aiBubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(5),
          topRight: const Radius.circular(18),
          bottomLeft: isLastInGroup
              ? const Radius.circular(18)
              : const Radius.circular(5),
          bottomRight: const Radius.circular(18),
        ),
        border: Border.all(color: _C.aiBubbleBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );

  BoxDecoration _errorDecoration() => BoxDecoration(
        color: const Color(0xFF1A0D11),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(
            color: AppTheme.accentRed.withValues(alpha: 0.25), width: 1),
      );
}

// ─── Timestamp pill ────────────────────────────────────────────────────────────

class _TimestampPill extends StatelessWidget {
  const _TimestampPill({required this.dt});
  final DateTime dt;

  String _label() {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ayer ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.08), width: 1),
          ),
          child: Text(
            _label(),
            style: const TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ),
      ),
    );
  }
}

// ─── Suggestion chip ──────────────────────────────────────────────────────────

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.accentAI.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppTheme.accentAI.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.bolt_rounded,
                  size: 13, color: AppTheme.accentAI),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status chip ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip(
      {required this.text, required this.color, this.dot = true});
  final String text;
  final Color color;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
        ],
        Text(text, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}

// ─── Header button ────────────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn(
      {required this.icon,
      required this.tooltip,
      this.onTap,
      this.loading = false});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white38))
            : Icon(icon, color: Colors.white38, size: 19),
        onPressed: onTap,
        splashRadius: 20,
      ),
    );
  }
}

// ─── Send button ──────────────────────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  const _SendButton({this.onTap, this.isLoading = false});
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isLoading ? Colors.white10 : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: _C.aiAvatarStart.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white38),
                ),
              )
            : const Icon(Icons.send_rounded, color: Colors.white, size: 19),
      ),
    );
  }
}

// ─── Scroll to bottom FAB ─────────────────────────────────────────────────────

class _ScrollToBottomFab extends StatelessWidget {
  const _ScrollToBottomFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.1), width: 1),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, blurRadius: 10, offset: Offset(0, 3))
          ],
        ),
        child: const Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.white60, size: 22),
      ),
    );
  }
}

// ─── Background pattern ───────────────────────────────────────────────────────

class _BackgroundPattern extends StatelessWidget {
  const _BackgroundPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter());
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    const radius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Typing dots ──────────────────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) {
              final progress = (_ctrl.value + i / 3) % 1.0;
              final scale = 0.5 + 0.5 * math.sin(progress * math.pi);
              final opacity = 0.3 + 0.7 * scale;
              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(colors: [
                        const Color(0xFFA78BFA),
                        _C.aiAvatarEnd,
                      ]),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
