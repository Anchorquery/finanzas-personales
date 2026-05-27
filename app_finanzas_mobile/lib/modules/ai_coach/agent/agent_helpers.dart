import '../../../routes/app_routes.dart';

/// Pure helpers extracted from AICoachController for unit testing.
class AgentHelpers {
  AgentHelpers._();

  /// Fuzzy lookup by lowercase contains; returns the closest match or null.
  /// Exact lowercase match wins over contains match.
  static T? bestMatchByName<T>(
    Iterable<({String key, T value})> items,
    String needle,
  ) {
    final n = needle.toLowerCase();
    ({String key, T value})? exact;
    ({String key, T value})? contains;
    for (final it in items) {
      final k = it.key.toLowerCase();
      if (k == n) {
        exact = it;
        break;
      }
      if (contains == null && (k.contains(n) || n.contains(k))) {
        contains = it;
      }
    }
    return (exact ?? contains)?.value;
  }

  /// Maps an `open_view` enum value to an app route.
  /// Returns null for unknown views.
  static String? routeForView(String view) {
    switch (view) {
      case 'dashboard':
        return Routes.dashboard;
      case 'transactions':
        return Routes.transactions;
      case 'budgets':
        return Routes.budgets;
      case 'savings':
        return Routes.savings;
      case 'debts':
        return Routes.debts;
      case 'subscriptions':
        return Routes.subscriptions;
      case 'recurring':
        return Routes.recurring;
      case 'incomes':
        return Routes.incomes;
      case 'scan_receipt':
        return Routes.scanReceipt;
      case 'workspaces':
        return Routes.workspaces;
      default:
        return null;
    }
  }

  /// Extracts up to 3 short proactive insights from a financial context string.
  static List<String> extractInsights(String ctx) {
    final out = <String>[];
    if (ctx.contains('🔴 EXCEDIDO')) {
      out.add('Tienes presupuestos **excedidos** este mes. Pregunta cuáles.');
    }
    if (ctx.contains('🟡 En riesgo')) {
      out.add('Hay presupuestos **en riesgo** (≥80% gastado).');
    }
    final saveRateMatch =
        RegExp(r'Tasa de ahorro: (-?\d+\.?\d*)%').firstMatch(ctx);
    if (saveRateMatch != null) {
      final rate = double.tryParse(saveRateMatch.group(1) ?? '') ?? 0;
      if (rate < 0) {
        out.add('Estás **gastando más de lo que ingresas** este mes ($rate%).');
      } else if (rate < 10) {
        out.add('Tu tasa de ahorro es baja ($rate%). Meta saludable: ≥20%.');
      }
    }
    if (ctx.contains('DEUDAS ACTIVAS') && !ctx.contains('SALDADA')) {
      out.add('Tienes **deudas activas**. ¿Quieres un plan de pago?');
    }
    return out.take(3).toList();
  }
}
