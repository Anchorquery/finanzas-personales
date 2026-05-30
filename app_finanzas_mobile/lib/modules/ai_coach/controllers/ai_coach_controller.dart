import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:langchain_google/langchain_google.dart';
import 'package:langchain_core/chat_models.dart' as lc;
import 'package:langchain_core/prompts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../data/services/directus_service.dart';
import '../../workspaces/controllers/workspaces_controller.dart';
import '../agent/agent_helpers.dart';
import '../agent/agent_tools.dart';

// ─── Domain models ────────────────────────────────────────────────────────────

class AgentTodo {
  final String content;
  final String status; // 'pending' | 'in_progress' | 'completed'

  const AgentTodo({required this.content, required this.status});
}

class PendingApproval {
  final String toolName;
  final Map<String, dynamic> args;
  final Completer<bool> completer;

  PendingApproval({
    required this.toolName,
    required this.args,
    required this.completer,
  });
}

class AIChatMessage {
  final String role; // 'user' | 'assistant' | 'tool_call'
  final String content;
  final DateTime timestamp;
  final bool isError;
  final bool isStreaming;
  final String? toolName;
  final bool? isToolApproved; // null = executing, true = approved, false = rejected

  const AIChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.isError = false,
    this.isStreaming = false,
    this.toolName,
    this.isToolApproved,
  });

  bool get isToolCall => role == 'tool_call';

  AIChatMessage copyWith({
    String? content,
    bool? isStreaming,
    bool? isError,
    bool? isToolApproved,
  }) =>
      AIChatMessage(
        role: role,
        content: content ?? this.content,
        timestamp: timestamp,
        isError: isError ?? this.isError,
        isStreaming: isStreaming ?? this.isStreaming,
        toolName: toolName,
        isToolApproved: isToolApproved ?? this.isToolApproved,
      );

  Map<String, dynamic> toMap() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isError': isError,
        // tool_call messages are ephemeral — not persisted
      };

  factory AIChatMessage.fromMap(Map<String, dynamic> m) => AIChatMessage(
        role: m['role'] as String? ?? 'assistant',
        content: m['content'] as String? ?? '',
        timestamp:
            DateTime.tryParse(m['timestamp'] as String? ?? '') ?? DateTime.now(),
        isError: m['isError'] == true || m['isError'] == 'true',
      );
}

// ─── Controller ───────────────────────────────────────────────────────────────

class AICoachController extends GetxController {
  final messages = <AIChatMessage>[].obs;
  final textController = TextEditingController();
  final isTyping = false.obs;
  final isConfigured = false.obs;
  final isInitializing = true.obs;
  final isRefreshingContext = false.obs;
  final contextSummary = ''.obs;
  final currentModel = 'gemini-2.5-flash'.obs;

  // Agent-specific state
  final agentTodos = <AgentTodo>[].obs;
  final pendingApproval = Rxn<PendingApproval>();

  final _storage = GetStorage();
  final DirectusService _directusService = Get.find<DirectusService>();

  ChatGoogleGenerativeAI? _chatModel; // with tools — main agent
  String? _cachedApiKey;

  final List<lc.ChatMessage> _langchainHistory = [];

  // Context cache
  String? _cachedContext;
  DateTime? _contextBuiltAt;
  static const _contextTtl = Duration(minutes: 2);

  static const _maxConversationTurns = 20;
  static const _modelName = 'gemini-2.5-flash';
  static const flashModel = 'gemini-2.5-flash';
  static const proModel = 'gemini-2.5-pro';
  static const _localApiKeyStorageKey = 'ai_gemini_key_cached';
  static const _localModelStorageKey = 'ai_gemini_model';
  static const _maxAgentIterations = 8;

  bool get isConfiguredValue => isConfigured.value;

  String get _workspaceId {
    if (Get.isRegistered<WorkspacesController>()) {
      return Get.find<WorkspacesController>().activeWorkspace?.id ?? 'default';
    }
    return 'default';
  }

  String get _messagesKey => 'ai_coach_messages_v2_$_workspaceId';

  @override
  void onInit() {
    super.onInit();
    _initializeAI();
  }

  // ── Persistencia ─────────────────────────────────────────────────────────────

  void _loadPersistedMessages() {
    try {
      final saved = _storage.read<List>(_messagesKey);
      if (saved != null && saved.isNotEmpty) {
        messages.assignAll(
          saved
              .map((e) =>
                  AIChatMessage.fromMap(Map<String, dynamic>.from(e as Map)))
              .where((m) => !m.isToolCall) // tool_call msgs are ephemeral
              .toList(),
        );
      }
    } catch (_) {}
  }

  void _persistMessages() {
    try {
      _storage.write(
        _messagesKey,
        messages
            .where((m) => !m.isStreaming && !m.isToolCall)
            .map((m) => m.toMap())
            .toList(),
      );
    } catch (_) {}
  }

  void _rebuildLangchainHistory(String systemPrompt) {
    _langchainHistory.clear();
    _langchainHistory.add(lc.ChatMessage.system(systemPrompt));

    for (final m in messages.where((m) =>
        !m.isError && !m.isStreaming && !m.isToolCall)) {
      if (m.role == 'user') {
        _langchainHistory.add(lc.ChatMessage.humanText(m.content));
      } else {
        _langchainHistory.add(lc.ChatMessage.ai(m.content));
      }
    }
    _truncateLangchainHistory();
  }

  void _truncateLangchainHistory() {
    if (_langchainHistory.isEmpty) return;

    final systemMsgs =
        _langchainHistory.whereType<lc.SystemChatMessage>().toList();
    final conversationMsgs =
        _langchainHistory.where((m) => m is! lc.SystemChatMessage).toList();

    if (conversationMsgs.length > _maxConversationTurns * 2) {
      final truncated = conversationMsgs
          .sublist(conversationMsgs.length - _maxConversationTurns * 2);
      _langchainHistory
        ..clear()
        ..addAll(systemMsgs)
        ..addAll(truncated);
    }
  }

  // ── Inicialización ───────────────────────────────────────────────────────────

  Future<void> _initializeAI() async {
    isInitializing.value = true;
    try {
      final apiKey = await _fetchApiKey();
      if (apiKey == null || apiKey.isEmpty) return;

      _cachedApiKey = apiKey;
      await _setupChatModel(apiKey);
      isConfigured.value = true;

      _loadPersistedMessages();

      if (messages.isEmpty) {
        _addWelcomeMessage();
      } else {
        _rebuildLangchainHistory(_buildSystemPrompt(_cachedContext ?? ''));
      }
    } catch (e) {
      Get.log('AICoachController: Error initializing: $e');
    } finally {
      isInitializing.value = false;
    }
  }

  Future<String?> _fetchApiKey() async {
    final cached = _storage.read<String>(_localApiKeyStorageKey);
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final org = await _directusService.getOrganization();
      if (org == null) return null;
      final settings = await _directusService.getOrganizationSettings(org.id);
      final key = (settings?['gemini_api_key'] as String?) ?? '';
      if (key.isNotEmpty) {
        _storage.write(_localApiKeyStorageKey, key);
        return key;
      }
    } catch (e) {
      Get.log('AICoachController: _fetchApiKey error: $e');
    }
    return null;
  }

  void invalidateApiKeyCache() {
    _storage.remove(_localApiKeyStorageKey);
  }

  Future<void> _setupChatModel(String apiKey) async {
    _chatModel = ChatGoogleGenerativeAI(
      apiKey: apiKey,
      defaultOptions: ChatGoogleGenerativeAIOptions(
        model: _modelName,
        temperature: 0.6,
        tools: AgentToolSpecs.all,
      ),
    );
    currentModel.value = _modelName;

    final context = await _buildFinancialContext();
    final systemPrompt = _buildSystemPrompt(context);

    _langchainHistory.clear();
    _langchainHistory.add(lc.ChatMessage.system(systemPrompt));
  }

  String _buildSystemPrompt(String context) => '''
Eres un asesor financiero personal inteligente llamado "Coach Financiero".
Siempre respondes en español. Eres conciso pero profundo cuando se necesita.
Usa Markdown: **negrita**, listas con -, tablas cuando ayuden. Emojis con moderación.

════════════════════════════════
DATOS FINANCIEROS DEL USUARIO
════════════════════════════════
${context.isEmpty ? 'No hay datos disponibles. Pide al usuario que registre transacciones.' : context}

════════════════════════════════
TUS HERRAMIENTAS
════════════════════════════════
PLANEACIÓN
- write_todos: planifica análisis complejos en pasos visibles

LECTURA (datos frescos)
- get_financial_summary, search_transactions, get_savings_goals, get_debts,
  get_subscriptions, get_budgets, get_accounts

ANÁLISIS
- get_top_merchants(days, limit): ranking de comercios donde más gasta
- compare_periods(start_a, end_a, start_b, end_b): comparativa de períodos
- forecast_cashflow(days): proyecta flujo de caja próximo

ESCRITURA (requieren aprobación HITL)
- create_transaction, delete_transaction
- create_budget, create_savings_goal, add_savings_contribution
- register_debt_payment, cancel_subscription

NAVEGACIÓN (HITL)
- open_view(view): propone abrir un módulo (dashboard, transactions, debts, etc.)

DELEGACIÓN
- task(agent, instruction): delega a debt_strategist, savings_coach o spending_analyst

════════════════════════════════
REGLAS
════════════════════════════════
- Usa write_todos al inicio de análisis con más de 2 pasos
- NUNCA inventes datos. Usa herramientas para confirmar números.
- Antes de cualquier escritura, explica QUÉ vas a hacer y POR QUÉ
- Cuando el usuario pida una vista (ej. "muéstrame mis deudas"), usa open_view
- Para análisis profundos, delega con task
- Redirige amablemente temas no financieros
''';

  // ── Contexto financiero ──────────────────────────────────────────────────────

  Future<String> _buildFinancialContext() async {
    if (_cachedContext != null &&
        _contextBuiltAt != null &&
        DateTime.now().difference(_contextBuiltAt!) < _contextTtl) {
      return _cachedContext!;
    }

    final buf = StringBuffer();
    try {
      final ws = Get.isRegistered<WorkspacesController>()
          ? Get.find<WorkspacesController>().activeWorkspace
          : null;
      if (ws == null) return 'No hay workspace activo.';

      final now = DateTime.now();
      final startMonth = DateTime(now.year, now.month, 1);
      final endMonth = DateTime(now.year, now.month + 1, 0);

      DashboardSummary? summary;
      List<Transaction> txs = [];
      List<Saving> savings = [];
      List<Budget> budgets = [];
      List<Debt> debts = [];
      List<Subscription> subs = [];

      await Future.wait([
        (() async {
          try {
            summary = await _directusService.getDashboardSummary(
              startDate: startMonth,
              endDate: endMonth,
              workspaceId: ws.id,
            );
          } catch (_) {}
        })(),
        (() async {
          try {
            txs = await _directusService.getTransactions(
                limit: 50, workspaceId: ws.id);
          } catch (_) {}
        })(),
        (() async {
          try {
            savings = await _directusService.getSavings(ws.id);
          } catch (_) {}
        })(),
        (() async {
          try {
            budgets = await _directusService.getBudgetsStatus(ws.id);
          } catch (_) {}
        })(),
        (() async {
          try {
            debts = await _directusService.getDebts(workspaceId: ws.id);
          } catch (_) {}
        })(),
        (() async {
          try {
            subs = await _directusService.getSubscriptions(workspaceId: ws.id);
          } catch (_) {}
        })(),
      ]);

      if (summary != null) {
        final s = summary!;
        final savingRate = s.monthlyIncome > 0
            ? ((s.monthlyIncome - s.monthlyExpenses) /
                    s.monthlyIncome *
                    100)
                .toStringAsFixed(1)
            : '0';
        buf
          ..writeln('📊 RESUMEN (${_monthName(now.month)} ${now.year})')
          ..writeln('Workspace: ${ws.name} | Moneda: ${ws.currency}')
          ..writeln('Balance: \$${s.currentBalance.toStringAsFixed(2)}')
          ..writeln('Ingresos: \$${s.monthlyIncome.toStringAsFixed(2)}')
          ..writeln('Gastos: \$${s.monthlyExpenses.toStringAsFixed(2)}')
          ..writeln('Tasa de ahorro: $savingRate%')
          ..writeln();
        contextSummary.value =
            '${ws.name} · \$${s.currentBalance.toStringAsFixed(0)}';
      }

      if (txs.isNotEmpty) {
        final expenses = txs.where((t) => t.type == 'expense').toList();
        final Map<String, double> byCategory = {};
        for (final t in expenses) {
          final cat = t.category?.name ?? 'Sin categoría';
          byCategory[cat] = (byCategory[cat] ?? 0) + t.amount;
        }
        final sortedCats = byCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sortedCats.isNotEmpty) {
          buf.writeln('📋 GASTOS POR CATEGORÍA');
          for (final e in sortedCats.take(10)) {
            buf.writeln('• ${e.key}: \$${e.value.toStringAsFixed(2)}');
          }
          buf.writeln();
        }

        buf.writeln('🕒 ÚLTIMAS ${txs.take(20).length} TRANSACCIONES');
        for (final t in txs.take(20)) {
          final tipo = t.type == 'income' ? '↑' : '↓';
          buf.writeln(
              '$tipo \$${t.amount.toStringAsFixed(2)} — ${t.concept} [${t.category?.name ?? '-'}]');
        }
        buf.writeln();
      }

      if (savings.isNotEmpty) {
        buf.writeln('🏦 METAS DE AHORRO');
        for (final s in savings) {
          final pct = s.targetAmount > 0
              ? (s.currentAmount / s.targetAmount * 100).toStringAsFixed(1)
              : '0';
          buf.writeln(
              '• ${s.name}: \$${s.currentAmount.toStringAsFixed(2)} / \$${s.targetAmount.toStringAsFixed(2)} ($pct%)');
          if (s.targetDate != null) buf.writeln('  Vence: ${_fmtDate(s.targetDate!)}');
        }
        buf.writeln();
      }

      if (budgets.isNotEmpty) {
        buf.writeln('💰 PRESUPUESTOS');
        for (final b in budgets) {
          final pct = b.limit > 0
              ? (b.spent / b.limit * 100).toStringAsFixed(1)
              : '0';
          final alert = b.spent > b.limit
              ? ' 🔴 EXCEDIDO'
              : double.parse(pct) >= 80
                  ? ' 🟡 En riesgo'
                  : ' 🟢';
          buf.writeln(
              '• ${b.name}: \$${b.spent.toStringAsFixed(2)} / \$${b.limit.toStringAsFixed(2)} ($pct%)$alert');
        }
        buf.writeln();
      }

      final activeDebts = debts.where((d) => d.status == 'active').toList();
      if (activeDebts.isNotEmpty) {
        buf.writeln('💳 DEUDAS ACTIVAS');
        for (final d in activeDebts) {
          buf.writeln(
              '• ${d.name}: \$${d.remainingAmount.toStringAsFixed(2)} pendiente');
          if ((d.interestRate ?? 0) > 0) buf.writeln('  Interés: ${d.interestRate}%');
          if (d.dueDate != null) buf.writeln('  Vence: ${_fmtDate(d.dueDate!)}');
        }
        buf.writeln();
      }

      if (subs.isNotEmpty) {
        final monthly = subs.fold<double>(
            0,
            (s, sub) =>
                s + (sub.billingCycle == 'annual' ? sub.amount / 12 : sub.amount));
        buf.writeln(
            '🔄 SUSCRIPCIONES (mensual estimado: \$${monthly.toStringAsFixed(2)})');
        for (final s in subs) {
          buf.writeln(
              '• ${s.name}: \$${s.amount.toStringAsFixed(2)}/${s.billingCycle == 'annual' ? 'año' : s.billingCycle}');
        }
        buf.writeln();
      }
    } catch (e) {
      Get.log('AICoachController: _buildFinancialContext error: $e');
    }

    final result = buf.toString();
    _cachedContext = result;
    _contextBuiltAt = DateTime.now();
    return result;
  }

  List<String> get dynamicSuggestions {
    final ctx = _cachedContext;
    if (ctx == null || ctx.isEmpty) {
      return [
        '¿Cómo puedo mejorar mis finanzas?',
        '¿Qué es una tasa de ahorro saludable?',
        '¿Cómo priorizo mis deudas?',
        'Dame consejos de ahorro',
        '¿Cómo crear un presupuesto?',
      ];
    }
    final suggestions = <String>[];
    if (ctx.contains('EXCEDIDO')) suggestions.add('¿Qué presupuestos excedí?');
    if (ctx.contains('En riesgo')) suggestions.add('¿Qué presupuestos están en riesgo?');
    if (ctx.contains('METAS DE AHORRO')) suggestions.add('¿Cuánto me falta para mis metas?');
    if (ctx.contains('DEUDAS ACTIVAS')) suggestions.add('Ayúdame a priorizar mis deudas');
    if (ctx.contains('SUSCRIPCIONES')) suggestions.add('¿Qué suscripciones debería cancelar?');
    suggestions
      ..add('¿Cuánto gasté este mes?')
      ..add('¿Cómo puedo ahorrar más?');
    return suggestions.take(5).toList();
  }

  // ── Acciones ─────────────────────────────────────────────────────────────────

  Future<void> refreshContext() async {
    if (isRefreshingContext.value || !isConfigured.value) return;
    isRefreshingContext.value = true;
    try {
      _cachedContext = null;
      _contextBuiltAt = null;
      final context = await _buildFinancialContext();
      final newSystemPrompt = _buildSystemPrompt(context);

      if (_langchainHistory.isNotEmpty &&
          _langchainHistory.first is lc.SystemChatMessage) {
        _langchainHistory[0] = lc.ChatMessage.system(newSystemPrompt);
      } else {
        _langchainHistory.insert(0, lc.ChatMessage.system(newSystemPrompt));
      }

      _addAssistantMessage(_l10n?.aiCoachContextRefreshed ??
          '✅ Contexto actualizado con los datos más recientes.');
    } catch (_) {
    } finally {
      isRefreshingContext.value = false;
    }
  }

  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isTyping.value) return;
    textController.clear();

    // Clear ephemeral todos on new message
    agentTodos.clear();

    messages.add(AIChatMessage(
      role: 'user',
      content: trimmed,
      timestamp: DateTime.now(),
    ));
    _persistMessages();

    if (!isConfigured.value || _chatModel == null) {
      _addAssistantMessage(
        _l10n?.aiCoachErrorNoApi ??
            '⚠️ No tengo configurada la API de Gemini.\nVe a **Ajustes > Configuración AI** para agregar tu API key.',
        isError: true,
      );
      return;
    }

    _runAgentLoop(trimmed);
  }

  void clearHistory() {
    messages.clear();
    agentTodos.clear();
    _storage.remove(_messagesKey);

    final systemMsgs =
        _langchainHistory.whereType<lc.SystemChatMessage>().toList();
    _langchainHistory
      ..clear()
      ..addAll(systemMsgs);

    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _addAssistantMessage(
      _l10n?.aiCoachWelcome ??
          '¡Hola! Soy tu **Coach Financiero** 💡\n\nTengo acceso a tus datos y puedo analizar gastos, optimizar presupuestos, planificar el pago de deudas, registrar movimientos y abrir vistas por ti. ¿En qué te ayudo hoy?',
    );
    _emitProactiveInsights();
  }

  Future<void> _emitProactiveInsights() async {
    try {
      final ctx = _cachedContext ?? await _buildFinancialContext();
      final insights = _extractInsights(ctx);
      if (insights.isEmpty) return;

      final header =
          _l10n?.aiCoachInsightsHeader ?? '🔎 **Lo que detecté en tus datos:**';
      final buf = StringBuffer('$header\n');
      for (final i in insights) {
        buf.writeln('- $i');
      }
      _addAssistantMessage(buf.toString());
    } catch (e) {
      Get.log('AICoachController: _emitProactiveInsights error: $e');
    }
  }

  List<String> _extractInsights(String ctx) =>
      AgentHelpers.extractInsights(ctx);

  // ── Agent loop ────────────────────────────────────────────────────────────────

  Future<void> _runAgentLoop(String userMessage) async {
    isTyping.value = true;
    _langchainHistory.add(lc.ChatMessage.humanText(userMessage));
    _truncateLangchainHistory();

    // Typing placeholder at end of list
    messages.add(AIChatMessage(
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    ));
    int placeholderIdx = messages.length - 1;

    try {
      for (int iter = 0; iter < _maxAgentIterations; iter++) {
        final result = await _chatModel!
            .invoke(PromptValue.chat(_langchainHistory))
            .timeout(const Duration(seconds: 90));

        final output = result.output;

        // ── Tool call branch ────────────────────────────────────────────────
        if (output.toolCalls.isNotEmpty) {
          _langchainHistory.add(output);

          for (final tc in output.toolCalls) {
            final toolName = tc.name;
            final args = tc.arguments;

            // Insert tool call bubble BEFORE the typing placeholder
            messages.insert(
              placeholderIdx,
              AIChatMessage(
                role: 'tool_call',
                content: AgentToolSpecs.displayLabel(toolName),
                timestamp: DateTime.now(),
                toolName: toolName,
                isToolApproved: null,
              ),
            );
            placeholderIdx++; // placeholder shifted down

            String toolResult;
            if (AgentToolSpecs.isWriteTool(toolName)) {
              // HITL: pause until user approves/rejects
              final approved = await _requestHITL(toolName, args);

              // Update bubble to show approval status
              final bubbleIdx = placeholderIdx - 1;
              messages[bubbleIdx] =
                  messages[bubbleIdx].copyWith(isToolApproved: approved);

              if (!approved) {
                toolResult = 'El usuario rechazó esta acción.';
              } else {
                toolResult = await _executeTool(toolName, args);
              }
            } else {
              toolResult = await _executeTool(toolName, args);
            }

            _langchainHistory.add(lc.ToolChatMessage(
              content: toolResult,
              toolCallId: tc.id,
            ));
          }

          continue; // Next agent iteration
        }

        // ── Final text response ────────────────────────────────────────────
        final finalText = output.content;
        _langchainHistory.add(lc.ChatMessage.ai(finalText));

        messages[placeholderIdx] = AIChatMessage(
          role: 'assistant',
          content: finalText,
          timestamp: DateTime.now(),
        );
        _persistMessages();
        return;
      }

      // Max iterations hit
      messages[placeholderIdx] = AIChatMessage(
        role: 'assistant',
        content: _l10n?.aiCoachErrorMaxIterations ??
            '⚠️ Alcancé el límite de pasos del análisis. Intenta con una pregunta más específica.',
        timestamp: DateTime.now(),
        isError: true,
      );
      _persistMessages();
    } catch (e, st) {
      Get.log('AICoachController: _runAgentLoop error: $e');
      _captureSentry(e, st, tag: 'agent_loop');

      if (_langchainHistory.isNotEmpty &&
          _langchainHistory.last is lc.HumanChatMessage) {
        _langchainHistory.removeLast();
      }

      // Ensure placeholder is still valid
      if (placeholderIdx < messages.length) {
        messages[placeholderIdx] = AIChatMessage(
          role: 'assistant',
          content: _errorMessage(e.toString()),
          timestamp: DateTime.now(),
          isError: true,
        );
      }
      _persistMessages();
    } finally {
      isTyping.value = false;
      pendingApproval.value = null;
    }
  }

  // ── HITL ─────────────────────────────────────────────────────────────────────

  Future<bool> _requestHITL(String toolName, Map<String, dynamic> args) async {
    final completer = Completer<bool>();
    pendingApproval.value = PendingApproval(
      toolName: toolName,
      args: args,
      completer: completer,
    );
    return completer.future;
  }

  void approveHITL() {
    pendingApproval.value?.completer.complete(true);
    pendingApproval.value = null;
  }

  void rejectHITL() {
    pendingApproval.value?.completer.complete(false);
    pendingApproval.value = null;
  }

  // ── Tool executor ─────────────────────────────────────────────────────────────

  Future<String> _executeTool(
      String name, Map<String, dynamic> args) async {
    try {
      switch (name) {
        case 'write_todos':
          return _execWriteTodos(args);
        case 'get_financial_summary':
          return _execGetFinancialSummary();
        case 'search_transactions':
          return _execSearchTransactions(args);
        case 'get_savings_goals':
          return _execGetSavingsGoals();
        case 'get_debts':
          return _execGetDebts(args);
        case 'get_subscriptions':
          return _execGetSubscriptions();
        case 'get_budgets':
          return _execGetBudgets();
        case 'get_accounts':
          return _execGetAccounts();
        case 'get_top_merchants':
          return _execGetTopMerchants(args);
        case 'compare_periods':
          return _execComparePeriods(args);
        case 'forecast_cashflow':
          return _execForecastCashflow(args);
        case 'create_transaction':
          return _execCreateTransaction(args);
        case 'delete_transaction':
          return _execDeleteTransaction(args);
        case 'create_budget':
          return _execCreateBudget(args);
        case 'create_savings_goal':
          return _execCreateSavingsGoal(args);
        case 'add_savings_contribution':
          return _execAddSavingsContribution(args);
        case 'register_debt_payment':
          return _execRegisterDebtPayment(args);
        case 'cancel_subscription':
          return _execCancelSubscription(args);
        case 'open_view':
          return _execOpenView(args);
        case 'task':
          return _execTask(args);
        default:
          return 'Error: herramienta "$name" no reconocida.';
      }
    } catch (e, st) {
      _captureSentry(e, st, tag: 'tool:$name');
      return 'Error ejecutando $name: $e';
    }
  }

  String _execWriteTodos(Map<String, dynamic> args) {
    final raw = args['todos'];
    if (raw is! List) return '✓ Sin tareas.';
    agentTodos.assignAll(
      raw.map((t) {
        final m = t as Map<String, dynamic>;
        return AgentTodo(
          content: m['content'] as String? ?? '',
          status: m['status'] as String? ?? 'pending',
        );
      }).toList(),
    );
    return '✓ Lista de tareas actualizada (${agentTodos.length} pasos).';
  }

  Future<String> _execGetFinancialSummary() async {
    _invalidateContext();
    final ctx = await _buildFinancialContext();
    return ctx.isEmpty ? 'No hay datos financieros disponibles.' : ctx;
  }

  Future<String> _execSearchTransactions(Map<String, dynamic> args) async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final limit = (args['limit'] as num?)?.toInt() ?? 30;
    final typeFilter = args['type'] as String? ?? 'all';
    final categoryFilter =
        (args['category'] as String?)?.toLowerCase() ?? '';
    final startDateStr = args['start_date'] as String?;
    final endDateStr = args['end_date'] as String?;

    DateTime? startDate = startDateStr != null
        ? DateTime.tryParse(startDateStr)
        : null;
    DateTime? endDate =
        endDateStr != null ? DateTime.tryParse(endDateStr) : null;

    final txs = await _directusService.getTransactions(
      limit: limit.clamp(1, 100),
      workspaceId: ws.id,
      startDate: startDate,
      endDate: endDate,
    );

    var filtered = txs.where((t) {
      if (typeFilter != 'all' && t.type != typeFilter) return false;
      if (categoryFilter.isNotEmpty &&
          !(t.category?.name ?? '').toLowerCase().contains(categoryFilter)) {
        return false;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) return 'No se encontraron transacciones con esos filtros.';

    final buf = StringBuffer('${filtered.length} transacciones encontradas:\n');
    for (final t in filtered) {
      final tipo = t.type == 'income' ? '↑ Ingreso' : '↓ Gasto';
      buf.writeln(
          '$tipo \$${t.amount.toStringAsFixed(2)} — ${t.concept} [${t.category?.name ?? '-'}] ${t.date}');
    }
    return buf.toString();
  }

  Future<String> _execGetSavingsGoals() async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final savings = await _directusService.getSavings(ws.id);
    if (savings.isEmpty) return 'No hay metas de ahorro registradas.';

    final buf = StringBuffer('Metas de ahorro:\n');
    for (final s in savings) {
      final pct = s.targetAmount > 0
          ? (s.currentAmount / s.targetAmount * 100).toStringAsFixed(1)
          : '0';
      buf.writeln(
          '• ${s.name}: \$${s.currentAmount.toStringAsFixed(2)} / \$${s.targetAmount.toStringAsFixed(2)} ($pct%)');
      if (s.targetDate != null) buf.writeln('  Objetivo: ${_fmtDate(s.targetDate!)}');
    }
    return buf.toString();
  }

  Future<String> _execGetDebts(Map<String, dynamic> args) async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final onlyActive = args['only_active'] as bool? ?? true;
    final debts = await _directusService.getDebts(workspaceId: ws.id);
    final list = onlyActive
        ? debts.where((d) => d.status == 'active').toList()
        : debts;
    if (list.isEmpty) {
      return onlyActive
          ? '¡Felicidades! No tienes deudas activas.'
          : 'No hay deudas registradas.';
    }

    final buf = StringBuffer(onlyActive ? 'Deudas activas:\n' : 'Deudas:\n');
    for (final d in list) {
      buf.writeln(
          '• [${d.id}] ${d.name}: \$${d.remainingAmount.toStringAsFixed(2)} pendiente (${d.status})');
      if ((d.interestRate ?? 0) > 0) buf.writeln('  Interés: ${d.interestRate}%');
      if (d.dueDate != null) buf.writeln('  Vence: ${_fmtDate(d.dueDate!)}');
    }
    return buf.toString();
  }

  Future<String> _execGetSubscriptions() async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final subs = await _directusService.getSubscriptions(workspaceId: ws.id);
    if (subs.isEmpty) return 'No hay suscripciones registradas.';

    final monthly = subs.fold<double>(
        0,
        (s, sub) =>
            s + (sub.billingCycle == 'annual' ? sub.amount / 12 : sub.amount));
    final buf = StringBuffer(
        'Suscripciones (mensual estimado: \$${monthly.toStringAsFixed(2)}):\n');
    for (final s in subs) {
      buf.writeln(
          '• ${s.name}: \$${s.amount.toStringAsFixed(2)}/${s.billingCycle == 'annual' ? 'año' : s.billingCycle}');
    }
    return buf.toString();
  }

  Future<String> _execGetBudgets() async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final budgets = await _directusService.getBudgetsStatus(ws.id);
    if (budgets.isEmpty) return 'No hay presupuestos configurados.';

    final buf = StringBuffer('Presupuestos del mes:\n');
    for (final b in budgets) {
      final pct = b.limit > 0 ? (b.spent / b.limit * 100).toStringAsFixed(1) : '0';
      final status = b.spent > b.limit
          ? '🔴 EXCEDIDO'
          : double.parse(pct) >= 80
              ? '🟡 En riesgo'
              : '🟢 OK';
      buf.writeln(
          '• ${b.name}: \$${b.spent.toStringAsFixed(2)} / \$${b.limit.toStringAsFixed(2)} ($pct%) $status');
    }
    return buf.toString();
  }

  // ── New analytical tools ─────────────────────────────────────────────────

  Future<String> _execGetAccounts() async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';
    final accounts = await _directusService.getAccounts(workspaceId: ws.id);
    if (accounts.isEmpty) return 'No hay cuentas registradas.';

    final buf = StringBuffer('Cuentas:\n');
    for (final a in accounts) {
      buf.writeln(
          '• [${a.id}] ${a.name} (${a.type}) — \$${a.currentBalance.toStringAsFixed(2)} ${a.currency}');
    }
    return buf.toString();
  }

  Future<String> _execGetTopMerchants(Map<String, dynamic> args) async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final days = ((args['days'] as num?)?.toInt() ?? 30).clamp(1, 365);
    final limit = ((args['limit'] as num?)?.toInt() ?? 10).clamp(1, 25);

    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));

    final txs = await _directusService.getTransactions(
      limit: 500,
      workspaceId: ws.id,
      startDate: start,
      endDate: end,
    );

    final expenses = txs.where((t) => t.type == 'expense');
    final Map<String, _MerchantAgg> agg = {};
    for (final t in expenses) {
      final key = t.concept.trim().toLowerCase().isEmpty
          ? '(sin concepto)'
          : t.concept.trim();
      final cur = agg[key] ?? _MerchantAgg(label: t.concept.trim());
      cur.total += t.amount;
      cur.count += 1;
      agg[key] = cur;
    }
    final sorted = agg.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    if (sorted.isEmpty) {
      return 'Sin gastos en los últimos $days días.';
    }

    final buf = StringBuffer(
        'Top ${sorted.take(limit).length} comercios/conceptos (últimos $days días):\n');
    for (final m in sorted.take(limit)) {
      buf.writeln(
          '• ${m.label}: \$${m.total.toStringAsFixed(2)} (${m.count} txns, prom \$${(m.total / m.count).toStringAsFixed(2)})');
    }
    return buf.toString();
  }

  Future<String> _execComparePeriods(Map<String, dynamic> args) async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final startA = DateTime.tryParse(args['start_a'] as String? ?? '');
    final endA = DateTime.tryParse(args['end_a'] as String? ?? '');
    final startB = DateTime.tryParse(args['start_b'] as String? ?? '');
    final endB = DateTime.tryParse(args['end_b'] as String? ?? '');
    if (startA == null || endA == null || startB == null || endB == null) {
      return 'Error: fechas inválidas. Usa formato YYYY-MM-DD.';
    }

    final results = await Future.wait([
      _directusService.getDashboardSummary(
          startDate: startA, endDate: endA, workspaceId: ws.id),
      _directusService.getDashboardSummary(
          startDate: startB, endDate: endB, workspaceId: ws.id),
    ]);
    final a = results[0];
    final b = results[1];

    double pctDelta(double from, double to) =>
        from == 0 ? (to == 0 ? 0 : 100) : ((to - from) / from.abs()) * 100;

    String fmt(double v) => '\$${v.toStringAsFixed(2)}';
    String pct(double v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(1)}%';

    final buf = StringBuffer()
      ..writeln('Comparativa de períodos:')
      ..writeln(
          'A: ${_fmtDate(startA)} → ${_fmtDate(endA)} | B: ${_fmtDate(startB)} → ${_fmtDate(endB)}')
      ..writeln(
          'Ingresos:  A=${fmt(a.monthlyIncome)}  B=${fmt(b.monthlyIncome)}  Δ=${pct(pctDelta(a.monthlyIncome, b.monthlyIncome))}')
      ..writeln(
          'Gastos:    A=${fmt(a.monthlyExpenses)}  B=${fmt(b.monthlyExpenses)}  Δ=${pct(pctDelta(a.monthlyExpenses, b.monthlyExpenses))}')
      ..writeln(
          'Balance:   A=${fmt(a.currentBalance)}  B=${fmt(b.currentBalance)}');
    return buf.toString();
  }

  Future<String> _execForecastCashflow(Map<String, dynamic> args) async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final days = ((args['days'] as num?)?.toInt() ?? 30).clamp(1, 180);

    final now = DateTime.now();
    final lookbackStart = now.subtract(const Duration(days: 30));

    final results = await Future.wait([
      _directusService.getTransactions(
        limit: 500,
        workspaceId: ws.id,
        startDate: lookbackStart,
        endDate: now,
      ),
      _directusService.getSubscriptions(workspaceId: ws.id),
      _directusService.getIncomePlans(workspaceId: ws.id),
    ]);
    final recent = results[0] as List<Transaction>;
    final subs = (results[1] as List<Subscription>).where((s) => s.isActive);
    final incomes = results[2] as List<IncomePlan>;

    final expenses = recent.where((t) => t.type == 'expense');
    final totalExpense30d =
        expenses.fold<double>(0, (s, t) => s + t.amount);
    final runRatePerDay = totalExpense30d / 30.0;
    final projectedExpenses = runRatePerDay * days;

    final subsMonthly = subs.fold<double>(
        0,
        (s, sub) =>
            s + (sub.billingCycle == 'annual' ? sub.amount / 12 : sub.amount));
    final projectedSubs = subsMonthly * (days / 30.0);

    final plannedIncome = incomes.fold<double>(0, (s, i) => s + i.amount);
    final projectedIncome = plannedIncome * (days / 30.0);

    final netFlow = projectedIncome - projectedExpenses - projectedSubs;

    final buf = StringBuffer()
      ..writeln('Proyección de flujo de caja a $days días:')
      ..writeln(
          'Ingresos planificados: \$${projectedIncome.toStringAsFixed(2)}')
      ..writeln(
          'Gastos (run-rate 30d): \$${projectedExpenses.toStringAsFixed(2)}')
      ..writeln('Suscripciones:         \$${projectedSubs.toStringAsFixed(2)}')
      ..writeln(
          'Flujo neto estimado:   \$${netFlow.toStringAsFixed(2)} ${netFlow >= 0 ? '🟢' : '🔴'}');
    if (netFlow < 0) {
      buf.writeln('⚠️ Atención: déficit proyectado. Considera reducir gastos.');
    }
    return buf.toString();
  }

  // ── New write tools ──────────────────────────────────────────────────────

  Future<String> _execDeleteTransaction(Map<String, dynamic> args) async {
    final id = args['id'] as String? ?? '';
    if (id.isEmpty) return 'Error: id requerido.';
    try {
      await _directusService.deleteTransaction(id);
      _afterMutation();
      return '✅ Transacción eliminada (id $id).';
    } catch (e) {
      return 'Error eliminando transacción: $e';
    }
  }

  Future<String> _execCreateBudget(Map<String, dynamic> args) async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final categoryName = (args['category_name'] as String? ?? '').trim();
    final limit = (args['limit'] as num?)?.toDouble() ?? 0;
    if (categoryName.isEmpty || limit <= 0) {
      return 'Error: nombre de categoría y límite (>0) son requeridos.';
    }

    final categories = await _directusService.getCategories(workspaceId: ws.id);
    final match = categories.firstWhereOrNull(
      (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
    );
    if (match == null) {
      return 'Error: no encontré la categoría "$categoryName". Crea una transacción con esa categoría primero o usa create_transaction.';
    }
    try {
      await _directusService.createBudget(
        limit: limit,
        categoryId: match.id,
        workspaceId: ws.id,
      );
      _afterMutation();
      return '✅ Presupuesto creado: $categoryName — \$${limit.toStringAsFixed(2)}/mes.';
    } catch (e) {
      return 'Error creando presupuesto: $e';
    }
  }

  Future<String> _execCreateSavingsGoal(Map<String, dynamic> args) async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final name = (args['name'] as String? ?? '').trim();
    final target = (args['target_amount'] as num?)?.toDouble() ?? 0;
    final dateStr = args['target_date'] as String?;
    if (name.isEmpty || target <= 0) {
      return 'Error: nombre y target_amount (>0) son requeridos.';
    }
    DateTime? targetDate;
    if (dateStr != null && dateStr.isNotEmpty) {
      targetDate = DateTime.tryParse(dateStr);
    }
    try {
      await _directusService.createSavingGoal(
        name: name,
        targetAmount: target,
        workspaceId: ws.id,
        targetDate: targetDate,
      );
      _afterMutation();
      return '✅ Meta creada: $name — objetivo \$${target.toStringAsFixed(2)}${targetDate != null ? ' (${_fmtDate(targetDate)})' : ''}.';
    } catch (e) {
      return 'Error creando meta: $e';
    }
  }

  Future<String> _execAddSavingsContribution(Map<String, dynamic> args) async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final goalName = (args['goal_name'] as String? ?? '').trim();
    final amount = (args['amount'] as num?)?.toDouble() ?? 0;
    if (goalName.isEmpty || amount <= 0) {
      return 'Error: goal_name y amount (>0) son requeridos.';
    }
    final goals = await _directusService.getSavings(ws.id);
    final goal = _bestMatchByName(
      goals.map((g) => (key: g.name, value: g)),
      goalName,
    );
    if (goal == null) {
      return 'Error: no encontré una meta llamada "$goalName".';
    }
    try {
      await _directusService.addSavingContribution(
          goal.id, amount, goal.currentAmount);
      _afterMutation();
      return '✅ Aporte registrado: \$${amount.toStringAsFixed(2)} a "${goal.name}". Nuevo total: \$${(goal.currentAmount + amount).toStringAsFixed(2)} / \$${goal.targetAmount.toStringAsFixed(2)}.';
    } catch (e) {
      return 'Error registrando aporte: $e';
    }
  }

  Future<String> _execRegisterDebtPayment(Map<String, dynamic> args) async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final debtName = (args['debt_name'] as String? ?? '').trim();
    final amount = (args['amount'] as num?)?.toDouble() ?? 0;
    if (debtName.isEmpty || amount <= 0) {
      return 'Error: debt_name y amount (>0) son requeridos.';
    }
    final debts = await _directusService.getDebts(workspaceId: ws.id);
    final active = debts.where((d) => d.status == 'active');
    final debt = _bestMatchByName(
      active.map((d) => (key: d.name, value: d)),
      debtName,
    );
    if (debt == null) {
      return 'Error: no encontré una deuda activa llamada "$debtName".';
    }
    final double newRemaining =
        (debt.remainingAmount - amount).clamp(0.0, double.infinity);
    final paidOff = newRemaining <= 0;
    try {
      await _directusService.updateDebt(debt.id, {
        'remaining_amount': newRemaining,
        if (paidOff) 'status': 'paid',
      });
      _afterMutation();
      return paidOff
          ? '🎉 Pago registrado: \$${amount.toStringAsFixed(2)} — ¡Deuda "${debt.name}" SALDADA!'
          : '✅ Pago registrado: \$${amount.toStringAsFixed(2)} a "${debt.name}". Pendiente: \$${newRemaining.toStringAsFixed(2)}.';
    } catch (e) {
      return 'Error registrando pago: $e';
    }
  }

  Future<String> _execCancelSubscription(Map<String, dynamic> args) async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'No hay workspace activo.';

    final subName = (args['subscription_name'] as String? ?? '').trim();
    if (subName.isEmpty) return 'Error: subscription_name requerido.';

    final subs = await _directusService.getSubscriptions(workspaceId: ws.id);
    final sub = _bestMatchByName(
      subs.map((s) => (key: s.name, value: s)),
      subName,
    );
    if (sub == null) {
      return 'Error: no encontré la suscripción "$subName".';
    }
    try {
      await _directusService
          .updateSubscription(sub.id, {'is_active': false});
      _afterMutation();
      return '✅ Suscripción "${sub.name}" marcada como cancelada. Ahorro estimado: \$${(sub.billingCycle == 'annual' ? sub.amount / 12 : sub.amount).toStringAsFixed(2)}/mes.';
    } catch (e) {
      return 'Error cancelando suscripción: $e';
    }
  }

  Future<String> _execOpenView(Map<String, dynamic> args) async {
    final view = args['view'] as String? ?? '';
    final route = _routeForView(view);
    if (route == null) return 'Error: vista desconocida "$view".';
    try {
      Get.toNamed(route);
      return '✅ Abriendo $view.';
    } catch (e) {
      return 'Error abriendo vista: $e';
    }
  }

  String? _routeForView(String view) => AgentHelpers.routeForView(view);

  Workspace? _activeWorkspaceOrNull() => Get.isRegistered<WorkspacesController>()
      ? Get.find<WorkspacesController>().activeWorkspace
      : null;

  /// Returns localized strings; falls back to ES if widget tree not mounted.
  AppL10n? get _l10n {
    final ctx = Get.context;
    return ctx != null ? AppL10n.of(ctx) : null;
  }

  void _captureSentry(Object error, StackTrace stack, {String? tag}) {
    if (!AppConfig.sentryEnabled) return;
    unawaited(
      Sentry.captureException(
        error,
        stackTrace: stack,
        withScope: (scope) {
          if (tag != null) scope.setTag('agent.where', tag);
          scope.setTag('agent.model', _modelName);
        },
      ),
    );
  }

  /// Call after any write that mutates Directus data:
  /// - Invalidates agent's local financial-context cache
  /// - Broadcasts dataVersion so dashboards/modules reload
  void _afterMutation() {
    _invalidateContext();
    _directusService.notifyDataChanged();
  }

  void _invalidateContext() {
    _cachedContext = null;
    _contextBuiltAt = null;
  }

  T? _bestMatchByName<T>(
          Iterable<({String key, T value})> items, String needle) =>
      AgentHelpers.bestMatchByName(items, needle);

  Future<String> _execCreateTransaction(Map<String, dynamic> args) async {
    final ws = _activeWorkspaceOrNull();
    if (ws == null) return 'Error: no hay workspace activo.';

    final concept = args['concept'] as String? ?? '';
    final amount = (args['amount'] as num?)?.toDouble() ?? 0;
    final type = args['type'] as String? ?? 'expense';
    final categoryName = args['category_name'] as String? ?? 'General';
    final date = args['date'] as String? ??
        DateTime.now().toIso8601String().substring(0, 10);

    if (concept.isEmpty || amount <= 0) {
      return 'Error: concepto y monto son requeridos.';
    }

    // Look up or create category
    String categoryId;
    try {
      final categories = await _directusService.getCategories(workspaceId: ws.id);
      final match = categories.firstWhereOrNull(
        (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
      );
      if (match != null) {
        categoryId = match.id;
      } else {
        // Create the category
        await _directusService.createCategory(
          name: categoryName,
          type: type,
          workspaceId: ws.id,
        );
        final updated = await _directusService.getCategories(workspaceId: ws.id);
        final created = updated.firstWhereOrNull(
          (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
        );
        categoryId = created?.id ?? '';
      }
    } catch (e) {
      return 'Error buscando categoría: $e';
    }

    if (categoryId.isEmpty) {
      return 'Error: no se pudo encontrar o crear la categoría "$categoryName".';
    }

    try {
      await _directusService.createTransaction(
        amount: amount,
        concept: concept,
        date: date,
        type: type,
        categoryId: categoryId,
        workspaceId: ws.id,
      );

      _afterMutation();
      return '✅ Transacción creada: ${type == 'income' ? 'Ingreso' : 'Gasto'} \$${amount.toStringAsFixed(2)} — $concept [$categoryName] el $date';
    } catch (e) {
      return 'Error creando transacción: $e';
    }
  }

  static const _maxSubagentIterations = 4;

  Future<String> _execTask(Map<String, dynamic> args) async {
    if (_cachedApiKey == null) return 'Error: API key no disponible.';

    final agentName = args['agent'] as String? ?? '';
    final instruction = args['instruction'] as String? ?? '';

    if (instruction.isEmpty) {
      return 'Error: instrucción vacía para el subagente.';
    }

    final systemPrompt = AgentToolSpecs.subagentSystemPrompt(agentName);
    final context = _cachedContext ?? await _buildFinancialContext();

    // Subagent has READ tools only; cannot mutate. Lower temperature for analysis.
    final subagent = ChatGoogleGenerativeAI(
      apiKey: _cachedApiKey!,
      defaultOptions: ChatGoogleGenerativeAIOptions(
        model: _modelName,
        temperature: 0.4,
        tools: AgentToolSpecs.readOnly,
      ),
    );

    final history = <lc.ChatMessage>[
      lc.ChatMessage.system(
        '$systemPrompt\n\nCONTEXTO FINANCIERO (instantánea inicial):\n$context\n\n'
        'Puedes invocar herramientas de SOLO LECTURA para refrescar datos '
        'cuando sea necesario. No puedes modificar datos.',
      ),
      lc.ChatMessage.humanText(instruction),
    ];

    try {
      for (int iter = 0; iter < _maxSubagentIterations; iter++) {
        final result = await subagent
            .invoke(PromptValue.chat(history))
            .timeout(const Duration(seconds: 60));

        final output = result.output;
        if (output.toolCalls.isEmpty) {
          return output.content;
        }

        history.add(output);
        for (final tc in output.toolCalls) {
          // Gate: subagent restricted to read-only tools.
          final result = AgentToolSpecs.isReadOnlyTool(tc.name)
              ? await _executeTool(tc.name, tc.arguments)
              : 'Error: subagentes no pueden usar la herramienta "${tc.name}".';
          history.add(lc.ToolChatMessage(
            content: result,
            toolCallId: tc.id,
          ));
        }
      }
      return 'Subagente $agentName alcanzó el límite de pasos sin respuesta final.';
    } catch (e, st) {
      _captureSentry(e, st, tag: 'subagent:$agentName');
      return 'Error en subagente $agentName: $e';
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  void _addAssistantMessage(String content, {bool isError = false}) {
    messages.add(AIChatMessage(
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
      isError: isError,
    ));
    _persistMessages();
  }

  String _errorMessage(String err) {
    final t = _l10n;
    if (err.contains('API key') || err.contains('INVALID_ARGUMENT')) {
      isConfigured.value = false;
      invalidateApiKeyCache();
      return t?.aiCoachErrorApiKey ??
          '🔑 **API key inválida**. Ve a Ajustes > Configuración AI.';
    }
    if (err.contains('QUOTA') || err.contains('429')) {
      return t?.aiCoachErrorQuota ??
          '⏳ **Cuota agotada**. Espera unos minutos e intenta de nuevo.';
    }
    if (err.contains('SAFETY')) {
      return t?.aiCoachErrorSafety ??
          '🛡️ Respuesta bloqueada por filtros de seguridad. Reformula tu pregunta.';
    }
    if (err.contains('TimeoutException') || err.contains('timeout')) {
      return t?.aiCoachErrorTimeout ??
          '⏱️ La respuesta tardó demasiado. Verifica tu conexión e intenta de nuevo.';
    }
    return t?.aiCoachErrorGeneric ?? '❌ Error al obtener respuesta. Intenta de nuevo.';
  }

  String _monthName(int month) {
    const months = [
      '',
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return months[month];
  }

  String _fmtDate(DateTime d) {
    const m = [
      '',
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${d.day} ${m[d.month]} ${d.year}';
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}

class _MerchantAgg {
  _MerchantAgg({required this.label});
  final String label;
  double total = 0;
  int count = 0;
}
