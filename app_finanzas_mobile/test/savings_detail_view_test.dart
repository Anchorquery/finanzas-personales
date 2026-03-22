import 'package:app_finanzas_mobile/data/models/finance/saving.dart';
import 'package:app_finanzas_mobile/data/models/finance/transaction.dart';
import 'package:app_finanzas_mobile/modules/savings/controllers/savings_controller.dart';
import 'package:app_finanzas_mobile/modules/savings/views/savings_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeSavingsDetailController extends GetxController
    implements SavingsController {
  @override
  final goalTransactions = <Transaction>[].obs;

  @override
  final isLoading = false.obs;

  @override
  final savings = <Saving>[
    Saving(
      id: 'goal-1',
      name: 'Fondo emergencia',
      targetAmount: 1000,
      currentAmount: 250,
      dateCreated: DateTime(2026, 1, 1),
      percent: 25,
      icon: '💰',
    ),
  ].obs;

  int loadGoalHistoryCalls = 0;

  @override
  void addFunds(String id, String name) {}

  @override
  String calculateProjection(Saving saving) => 'OK';

  @override
  void createGoal() {}

  @override
  Future<void> deleteGoal(String id) async {}

  @override
  Widget getGoalIconWidget(Saving goal, {double size = 24}) {
    return Text(goal.icon ?? '', style: TextStyle(fontSize: size));
  }

  @override
  Future<void> loadGoalHistory(String goalId) async {
    loadGoalHistoryCalls++;
  }

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
  double get totalSaved => 250;
}

void main() {
  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'detalle de ahorro carga historial una sola vez aunque el Obx se reconstruya',
    (tester) async {
      final controller =
          Get.put<SavingsController>(FakeSavingsDetailController())
              as FakeSavingsDetailController;

      await tester.pumpWidget(
        GetMaterialApp(
          home: SavingsDetailView(saving: controller.savings.first),
        ),
      );
      await tester.pump();

      expect(controller.loadGoalHistoryCalls, 1);

      controller.goalTransactions.assignAll([
        Transaction(
          id: 'tx-1',
          amount: 50,
          concept: 'Aporte',
          date: DateTime(2026, 3, 21),
          type: 'expense',
        ),
      ]);
      await tester.pump();

      expect(controller.loadGoalHistoryCalls, 1);
    },
  );
}
