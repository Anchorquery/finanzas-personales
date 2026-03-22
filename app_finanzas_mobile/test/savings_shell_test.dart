import 'package:app_finanzas_mobile/data/models/finance/saving.dart';
import 'package:app_finanzas_mobile/data/models/finance/transaction.dart';
import 'package:app_finanzas_mobile/modules/home/views/home_view.dart';
import 'package:app_finanzas_mobile/modules/savings/controllers/savings_controller.dart';
import 'package:app_finanzas_mobile/modules/savings/views/savings_view.dart';
import 'package:app_finanzas_mobile/routes/app_pages.dart';
import 'package:app_finanzas_mobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeSavingsController extends GetxController
    implements SavingsController {
  @override
  final goalTransactions = <Transaction>[].obs;

  @override
  final isLoading = false.obs;

  @override
  final savings = <Saving>[
    Saving(
      id: 'goal-1',
      name: 'Fondo de emergencia',
      targetAmount: 1000,
      currentAmount: 200,
      dateCreated: DateTime(2026, 1, 1),
      percent: 20,
      icon: '💰',
    ),
  ].obs;

  @override
  void addFunds(String id, String name) {}

  @override
  String calculateProjection(Saving saving) => '';

  @override
  void createGoal() {}

  @override
  Future<void> deleteGoal(String id) async {}

  @override
  Widget getGoalIconWidget(Saving goal, {double size = 24}) {
    return const SizedBox.shrink();
  }

  @override
  Future<void> loadGoalHistory(String goalId) async {}

  @override
  Future<void> loadSavings() async {}

  @override
  Future<void> submitAddFunds(String id, double amount) async {}

  @override
  Future<void> submitCreateGoal({
    required String name,
    required double amount,
    String? icon,
    DateTime? targetDate,
  }) async {}

  @override
  Future<void> submitDeleteGoal(String id) async {}

  @override
  Future<void> submitUpdateGoal({
    required String id,
    String? name,
    double? amount,
    String? icon,
    DateTime? targetDate,
  }) async {}

  @override
  Future<void> submitWithdrawFunds(String id, double amount) async {}

  @override
  double get totalSaved =>
      savings.fold(0, (sum, item) => sum + item.currentAmount);
}

void main() {
  tearDown(() {
    Get.reset();
  });

  test('la ruta de ahorros usa el shell principal', () {
    final savingsRoute = AppPages.routes.firstWhere(
      (route) => route.name == Routes.savings,
    );

    expect(savingsRoute.page(), isA<HomeView>());
  });

  testWidgets('la vista de ahorros puede abrir el drawer del shell', (
    tester,
  ) async {
    Get.put<SavingsController>(FakeSavingsController());

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          drawer: const Drawer(child: Text('drawer abierto')),
          body: const SavingsView(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();

    expect(find.text('drawer abierto'), findsOneWidget);
  });
}
