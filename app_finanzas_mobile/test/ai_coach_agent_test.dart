import 'package:flutter_test/flutter_test.dart';
import 'package:app_finanzas_mobile/modules/ai_coach/agent/agent_helpers.dart';
import 'package:app_finanzas_mobile/modules/ai_coach/agent/agent_tools.dart';
import 'package:app_finanzas_mobile/routes/app_routes.dart';

void main() {
  group('AgentToolSpecs', () {
    test('write tools require HITL', () {
      expect(AgentToolSpecs.isWriteTool('create_transaction'), isTrue);
      expect(AgentToolSpecs.isWriteTool('delete_transaction'), isTrue);
      expect(AgentToolSpecs.isWriteTool('create_budget'), isTrue);
      expect(AgentToolSpecs.isWriteTool('create_savings_goal'), isTrue);
      expect(AgentToolSpecs.isWriteTool('add_savings_contribution'), isTrue);
      expect(AgentToolSpecs.isWriteTool('register_debt_payment'), isTrue);
      expect(AgentToolSpecs.isWriteTool('cancel_subscription'), isTrue);
      expect(AgentToolSpecs.isWriteTool('open_view'), isTrue);
    });

    test('read tools do NOT require HITL', () {
      const readTools = [
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
        'write_todos',
        'task',
      ];
      for (final t in readTools) {
        expect(AgentToolSpecs.isWriteTool(t), isFalse, reason: t);
      }
    });

    test('every tool spec has a display label', () {
      for (final spec in AgentToolSpecs.all) {
        final label = AgentToolSpecs.displayLabel(spec.name);
        expect(label, isNotEmpty, reason: spec.name);
        expect(label, isNot(equals(spec.name)),
            reason: '${spec.name} falls back to raw name');
      }
    });

    test('subagentSystemPrompt covers known agents', () {
      expect(AgentToolSpecs.subagentSystemPrompt('debt_strategist'),
          contains('avalanche'));
      expect(AgentToolSpecs.subagentSystemPrompt('savings_coach'),
          contains('ahorro'));
      expect(AgentToolSpecs.subagentSystemPrompt('spending_analyst'),
          contains('gasto'));
    });

    test('isReadOnlyTool whitelist', () {
      const readOnly = [
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
      ];
      for (final t in readOnly) {
        expect(AgentToolSpecs.isReadOnlyTool(t), isTrue, reason: t);
      }
    });

    test('write tools are NOT read-only', () {
      const writes = [
        'create_transaction',
        'delete_transaction',
        'create_budget',
        'create_savings_goal',
        'add_savings_contribution',
        'register_debt_payment',
        'cancel_subscription',
        'open_view',
      ];
      for (final t in writes) {
        expect(AgentToolSpecs.isReadOnlyTool(t), isFalse, reason: t);
      }
    });

    test('write_todos and task are neither read-only nor write', () {
      expect(AgentToolSpecs.isReadOnlyTool('write_todos'), isFalse);
      expect(AgentToolSpecs.isWriteTool('write_todos'), isFalse);
      expect(AgentToolSpecs.isReadOnlyTool('task'), isFalse);
      expect(AgentToolSpecs.isWriteTool('task'), isFalse);
    });

    test('readOnly spec list matches whitelist size', () {
      final names = AgentToolSpecs.readOnly.map((s) => s.name).toSet();
      expect(names.length, 10);
      expect(names, contains('get_financial_summary'));
      expect(names, contains('forecast_cashflow'));
    });

    test('readOnly excludes write tools', () {
      final names = AgentToolSpecs.readOnly.map((s) => s.name);
      expect(names, isNot(contains('create_transaction')));
      expect(names, isNot(contains('open_view')));
    });
  });

  group('AgentHelpers.routeForView', () {
    test('maps known views to routes', () {
      expect(AgentHelpers.routeForView('dashboard'), Routes.dashboard);
      expect(AgentHelpers.routeForView('debts'), Routes.debts);
      expect(AgentHelpers.routeForView('savings'), Routes.savings);
      expect(AgentHelpers.routeForView('scan_receipt'), Routes.scanReceipt);
    });

    test('returns null for unknown view', () {
      expect(AgentHelpers.routeForView('nope'), isNull);
      expect(AgentHelpers.routeForView(''), isNull);
    });
  });

  group('AgentHelpers.bestMatchByName', () {
    final items = [
      (key: 'Netflix', value: 1),
      (key: 'Spotify', value: 2),
      (key: 'Tarjeta BBVA', value: 3),
    ];

    test('exact match wins', () {
      expect(AgentHelpers.bestMatchByName(items, 'netflix'), 1);
      expect(AgentHelpers.bestMatchByName(items, 'NETFLIX'), 1);
    });

    test('contains match falls back', () {
      expect(AgentHelpers.bestMatchByName(items, 'bbva'), 3);
      expect(AgentHelpers.bestMatchByName(items, 'spot'), 2);
    });

    test('returns null when nothing matches', () {
      expect(AgentHelpers.bestMatchByName(items, 'amazon'), isNull);
    });

    test('reverse contains (needle contains key) also matches', () {
      // user might say "deuda tarjeta bbva 2024" — key "Tarjeta BBVA" inside it
      expect(
        AgentHelpers.bestMatchByName(items, 'pago tarjeta bbva septiembre'),
        3,
      );
    });
  });

  group('AgentHelpers.extractInsights', () {
    test('empty context produces no insights', () {
      expect(AgentHelpers.extractInsights(''), isEmpty);
    });

    test('detects exceeded budgets', () {
      final ins = AgentHelpers.extractInsights('Comida 🔴 EXCEDIDO');
      expect(ins, contains(contains('excedidos')));
    });

    test('detects at-risk budgets', () {
      final ins = AgentHelpers.extractInsights('Transporte 🟡 En riesgo');
      expect(ins, contains(contains('en riesgo')));
    });

    test('detects negative savings rate', () {
      final ins = AgentHelpers.extractInsights('Tasa de ahorro: -15.5%');
      expect(ins.first, contains('gastando más'));
    });

    test('detects low savings rate', () {
      final ins = AgentHelpers.extractInsights('Tasa de ahorro: 5.0%');
      expect(ins.first, contains('baja'));
    });

    test('detects active debts but skips if saldada present', () {
      expect(
        AgentHelpers.extractInsights('DEUDAS ACTIVAS\n• X'),
        contains(contains('deudas activas')),
      );
      expect(
        AgentHelpers.extractInsights('DEUDAS ACTIVAS\nSALDADA hoy'),
        isNot(contains(contains('deudas activas'))),
      );
    });

    test('caps to 3 insights', () {
      final ctx = '🔴 EXCEDIDO\n🟡 En riesgo\nTasa de ahorro: -5%\nDEUDAS ACTIVAS';
      expect(AgentHelpers.extractInsights(ctx).length, lessThanOrEqualTo(3));
    });
  });
}
