import 'package:langchain_core/tools.dart';

// ─── Tool specs exposed to the Gemini model ───────────────────────────────────

class AgentToolSpecs {
  static const List<ToolSpec> all = [
    // ── Planning ────────────────────────────────────────────────────────────
    ToolSpec(
      name: 'write_todos',
      description:
          'Update your task list to plan multi-step analysis. Call this at the '
          'start of complex requests so the user can see your plan. Status: '
          'pending | in_progress | completed.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'todos': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'content': {'type': 'string'},
                'status': {
                  'type': 'string',
                  'enum': ['pending', 'in_progress', 'completed'],
                },
              },
              'required': ['content', 'status'],
            },
          },
        },
        'required': ['todos'],
      },
    ),

    // ── Read: financial data ─────────────────────────────────────────────────
    ToolSpec(
      name: 'get_financial_summary',
      description:
          'Get the current balance, monthly income, monthly expenses, and '
          'savings rate for the active workspace.',
      inputJsonSchema: {'type': 'object', 'properties': {}},
    ),
    ToolSpec(
      name: 'search_transactions',
      description:
          'Search recent transactions. Use to find specific spending patterns, '
          'by category, type (income|expense), or date range.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'limit': {
            'type': 'integer',
            'description': 'Max results (default 30, max 100)',
          },
          'type': {
            'type': 'string',
            'enum': ['income', 'expense', 'all'],
          },
          'category': {
            'type': 'string',
            'description': 'Category name (partial match)',
          },
          'start_date': {'type': 'string', 'description': 'YYYY-MM-DD'},
          'end_date': {'type': 'string', 'description': 'YYYY-MM-DD'},
        },
      },
    ),
    ToolSpec(
      name: 'get_savings_goals',
      description: 'Get all savings goals with current/target amount and date.',
      inputJsonSchema: {'type': 'object', 'properties': {}},
    ),
    ToolSpec(
      name: 'get_debts',
      description:
          'Get all debts with remaining amount, interest rate, due date and status.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'only_active': {
            'type': 'boolean',
            'description': 'Filter only active debts (default true)',
          },
        },
      },
    ),
    ToolSpec(
      name: 'get_subscriptions',
      description:
          'Get all subscriptions with amount, billing cycle and monthly cost.',
      inputJsonSchema: {'type': 'object', 'properties': {}},
    ),
    ToolSpec(
      name: 'get_budgets',
      description:
          'Get all budgets with spent amount, limit and status (on_track | at_risk | exceeded).',
      inputJsonSchema: {'type': 'object', 'properties': {}},
    ),
    ToolSpec(
      name: 'get_accounts',
      description:
          'Get all financial accounts (bank, cash, card, investment) with balance and currency.',
      inputJsonSchema: {'type': 'object', 'properties': {}},
    ),

    // ── Read: analytical ─────────────────────────────────────────────────────
    ToolSpec(
      name: 'get_top_merchants',
      description:
          'Top concepts/merchants where money is spent in the last N days, '
          'ranked by total spent and frequency.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'days': {
            'type': 'integer',
            'description': 'Lookback window in days (default 30, max 365)',
          },
          'limit': {
            'type': 'integer',
            'description': 'Top N merchants (default 10, max 25)',
          },
        },
      },
    ),
    ToolSpec(
      name: 'compare_periods',
      description:
          'Compare income, expenses and savings rate between two date ranges. '
          'Returns deltas in absolute and percentage. Use to spot trends month-over-month.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'start_a': {'type': 'string', 'description': 'YYYY-MM-DD'},
          'end_a': {'type': 'string', 'description': 'YYYY-MM-DD'},
          'start_b': {'type': 'string', 'description': 'YYYY-MM-DD'},
          'end_b': {'type': 'string', 'description': 'YYYY-MM-DD'},
        },
        'required': ['start_a', 'end_a', 'start_b', 'end_b'],
      },
    ),
    ToolSpec(
      name: 'forecast_cashflow',
      description:
          'Project net cashflow for the next N days based on planned incomes, '
          'active subscriptions and historical expense run-rate. Useful for '
          'liquidity planning.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'days': {
            'type': 'integer',
            'description': 'Horizon in days (default 30, max 180)',
          },
        },
      },
    ),

    // ── Write: requires HITL approval ────────────────────────────────────────
    ToolSpec(
      name: 'create_transaction',
      description:
          'Create a new income or expense transaction. REQUIRES user approval.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'concept': {'type': 'string'},
          'amount': {'type': 'number', 'description': 'Positive amount'},
          'type': {'type': 'string', 'enum': ['income', 'expense']},
          'category_name': {
            'type': 'string',
            'description': 'Category (matched or created)',
          },
          'date': {'type': 'string', 'description': 'YYYY-MM-DD (default today)'},
        },
        'required': ['concept', 'amount', 'type', 'date'],
      },
    ),
    ToolSpec(
      name: 'delete_transaction',
      description: 'Delete a transaction by id. REQUIRES user approval.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'concept_hint': {
            'type': 'string',
            'description': 'Short label shown to user for confirmation',
          },
        },
        'required': ['id'],
      },
    ),
    ToolSpec(
      name: 'create_budget',
      description:
          'Create a monthly budget for a category. REQUIRES user approval.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'category_name': {'type': 'string'},
          'limit': {'type': 'number', 'description': 'Monthly limit, positive'},
        },
        'required': ['category_name', 'limit'],
      },
    ),
    ToolSpec(
      name: 'create_savings_goal',
      description:
          'Create a new savings goal with optional target date. REQUIRES user approval.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'target_amount': {'type': 'number', 'description': 'Target, positive'},
          'target_date': {
            'type': 'string',
            'description': 'YYYY-MM-DD (optional)',
          },
        },
        'required': ['name', 'target_amount'],
      },
    ),
    ToolSpec(
      name: 'add_savings_contribution',
      description:
          'Add a contribution to a savings goal. Matches goal by name (closest). '
          'REQUIRES user approval.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'goal_name': {'type': 'string'},
          'amount': {'type': 'number', 'description': 'Contribution, positive'},
        },
        'required': ['goal_name', 'amount'],
      },
    ),
    ToolSpec(
      name: 'register_debt_payment',
      description:
          'Register a payment toward an active debt. Reduces remaining_amount. '
          'Matches debt by name (closest). REQUIRES user approval.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'debt_name': {'type': 'string'},
          'amount': {'type': 'number', 'description': 'Payment, positive'},
        },
        'required': ['debt_name', 'amount'],
      },
    ),
    ToolSpec(
      name: 'cancel_subscription',
      description:
          'Mark a subscription as inactive (cancelled). Matches by name. '
          'REQUIRES user approval.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'subscription_name': {'type': 'string'},
        },
        'required': ['subscription_name'],
      },
    ),

    // ── Navigation ──────────────────────────────────────────────────────────
    ToolSpec(
      name: 'open_view',
      description:
          'Suggest opening a specific module to the user. REQUIRES user approval. '
          'Valid views: dashboard, transactions, budgets, savings, debts, '
          'subscriptions, recurring, incomes, scan_receipt, workspaces.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'view': {
            'type': 'string',
            'enum': [
              'dashboard',
              'transactions',
              'budgets',
              'savings',
              'debts',
              'subscriptions',
              'recurring',
              'incomes',
              'scan_receipt',
              'workspaces',
            ],
          },
        },
        'required': ['view'],
      },
    ),

    // ── Delegation: specialized subagents ───────────────────────────────────
    ToolSpec(
      name: 'task',
      description:
          'Delegate to a specialized financial subagent for deep analysis. '
          'Subagents are stateless — include all needed context in instruction.',
      inputJsonSchema: {
        'type': 'object',
        'properties': {
          'agent': {
            'type': 'string',
            'enum': ['debt_strategist', 'savings_coach', 'spending_analyst'],
            'description':
                'debt_strategist: avalanche/snowball debt payoff plans. '
                'savings_coach: savings goals and investment strategy. '
                'spending_analyst: spending patterns and budget optimization.',
          },
          'instruction': {
            'type': 'string',
            'description':
                'Complete self-contained task. Include all relevant numbers — '
                'agent has no memory.',
          },
        },
        'required': ['agent', 'instruction'],
      },
    ),
  ];

  // Tools that mutate data or trigger navigation — require HITL approval.
  static const _writeTools = {
    'create_transaction',
    'delete_transaction',
    'create_budget',
    'create_savings_goal',
    'add_savings_contribution',
    'register_debt_payment',
    'cancel_subscription',
    'open_view',
  };

  /// Read-only tools safe for stateless subagents (no HITL needed).
  static const _readOnlyTools = {
    'get_financial_summary',
    'search_transactions',
    'get_savings_goals',
    'get_debts',
    'get_subscriptions',
    'get_budgets',
    'get_accounts',
    'get_top_merchants',
    'compare_periods',
    'forecast_cashflow',
  };

  static bool isWriteTool(String name) => _writeTools.contains(name);
  static bool isReadOnlyTool(String name) => _readOnlyTools.contains(name);

  /// Subset of [all] spec safe to pass to subagents.
  static List<ToolSpec> get readOnly =>
      all.where((s) => _readOnlyTools.contains(s.name)).toList();

  static String displayLabel(String toolName) {
    switch (toolName) {
      case 'write_todos':
        return 'Planificando pasos';
      case 'get_financial_summary':
        return 'Consultando resumen financiero';
      case 'search_transactions':
        return 'Buscando transacciones';
      case 'get_savings_goals':
        return 'Consultando metas de ahorro';
      case 'get_debts':
        return 'Consultando deudas';
      case 'get_subscriptions':
        return 'Consultando suscripciones';
      case 'get_budgets':
        return 'Consultando presupuestos';
      case 'get_accounts':
        return 'Consultando cuentas';
      case 'get_top_merchants':
        return 'Calculando top comercios';
      case 'compare_periods':
        return 'Comparando períodos';
      case 'forecast_cashflow':
        return 'Proyectando flujo de caja';
      case 'create_transaction':
        return 'Crear transacción';
      case 'delete_transaction':
        return 'Eliminar transacción';
      case 'create_budget':
        return 'Crear presupuesto';
      case 'create_savings_goal':
        return 'Crear meta de ahorro';
      case 'add_savings_contribution':
        return 'Aportar a meta';
      case 'register_debt_payment':
        return 'Registrar pago de deuda';
      case 'cancel_subscription':
        return 'Cancelar suscripción';
      case 'open_view':
        return 'Abrir vista';
      case 'task':
        return 'Consultando agente especializado';
      default:
        return toolName;
    }
  }

  static String subagentSystemPrompt(String agentName) {
    switch (agentName) {
      case 'debt_strategist':
        return '''Eres un estratega experto en eliminación de deudas.
Dominas los métodos avalanche (mayor interés primero) y snowball (menor saldo primero).
Siempre:
- Presentas un plan de pago paso a paso con montos y plazos exactos
- Calculas el interés total ahorrado con cada estrategia
- Recomiendas la mejor estrategia basándote en los números reales
- Respondes en español con formato markdown estructurado''';

      case 'savings_coach':
        return '''Eres un coach experto en ahorro e inversión personal.
Dominas fondos de emergencia, metas de ahorro y estrategias de inversión para Latinoamérica.
Siempre:
- Calculas proyecciones con fechas específicas (cuándo se alcanza la meta)
- Sugieres aportes mensuales viables basados en el contexto real
- Priorizas metas por urgencia e impacto
- Respondes en español con formato markdown estructurado''';

      case 'spending_analyst':
        return '''Eres un analista experto en patrones de gasto y optimización de presupuestos.
Dominas el análisis de gastos por categoría, estacionalidad y detección de fugas.
Siempre:
- Identificas las 3 categorías de mayor gasto y su % del ingreso
- Señalas gastos anómalos o innecesarios con montos exactos
- Das recomendaciones concretas de reducción con impacto numérico
- Respondes en español con formato markdown estructurado''';

      default:
        return 'Eres un asesor financiero personal experto. Respondes en español con análisis detallados y recomendaciones prácticas.';
    }
  }
}
