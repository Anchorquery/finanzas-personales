import 'package:app_finanzas_mobile/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders icon and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: 'Vacío',
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('Vacío'), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: 'X',
              action: () => tapped = true,
              actionLabel: 'Reintentar',
            ),
          ),
        ),
      );
      expect(find.text('Reintentar'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      expect(tapped, isTrue);
    });

    testWidgets('no action button when actionLabel missing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: 'X',
              action: () {},
            ),
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });

  group('PullableEmptyState', () {
    testWidgets('wraps EmptyState in RefreshIndicator + scrollable',
        (tester) async {
      var refreshed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PullableEmptyState(
              onRefresh: () async => refreshed = true,
              icon: Icons.inbox,
              message: 'Sin datos',
            ),
          ),
        ),
      );
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Sin datos'), findsOneWidget);

      // Pull to refresh
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();
      expect(refreshed, isTrue);
    });
  });
}
