import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_finanzas_mobile/core/utils/currency_utils.dart';
import '../../../data/services/directus_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/exchange_rate_service.dart';
import 'package:app_finanzas_mobile/modules/workspaces/controllers/workspaces_controller.dart';

class DashboardController extends GetxController {
  final DirectusService _directusService = Get.find();
  final WorkspacesController _workspacesController =
      Get.find<WorkspacesController>();

  final totalBalance = 0.0.obs;
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final openingBalance = 0.0.obs;
  final balanceChangePercentage = 0.0.obs;
  final incomeChangePercentage = 0.0.obs;
  final expenseChangePercentage = 0.0.obs;
  final recentTransactions = <Transaction>[].obs;
  final isLoading = true.obs;
  final status = RxStatus.empty().obs;
  final tabIndex = 0.obs;
  final accounts = <Account>[].obs;

  final weeklySpots = <FlSpot>[].obs;
  final weeklyNetFlow = 0.0.obs;
  final userName = ''.obs;

  // Currency from active workspace
  final currency = 'USD'.obs;
  final secondaryCurrency = 'VES'.obs;
  final exchangeRate = 0.0.obs;

  // Mes anterior para comparación
  final previousIncome = 0.0.obs;
  final previousExpense = 0.0.obs;

  // Vista de dashboard: false = clásica, true = alternativa
  final useAlternativeView = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    _checkNotifications();

    // Reload when workspace changes
    ever(_workspacesController.activeWorkspaceRx, (_) => loadDashboard());
    // Reload when any module creates/edits/deletes data
    ever(_directusService.dataVersion, (_) => loadDashboard());
  }

  void _checkNotifications() async {
    try {
      // Demo: Schedule notification for recurring payments
      final list = await _directusService.getSubscriptions();
      final notifService = Get.find<NotificationService>();

      if (list.isNotEmpty) {
        final sub = list.first;
        notifService.scheduleRecurringPaymentNotification(
          1, // Fallback day
          sub.name,
          sub.amount,
        );
      }
    } catch (e) {
      Get.log(
        'DashboardController: Error checking notifications (non-fatal): $e',
      );
    }
  }

  Future<void> loadDashboard() async {
    try {
      try {
        final user = await _directusService.getCurrentUser().timeout(
          const Duration(seconds: 30),
          onTimeout: () => null,
        );
        if (user != null) {
          userName.value = user.firstName;
          Get.log('DashboardController: User fetched - ${user.firstName}');
        } else {
          Get.log('DashboardController: User fetch returned null');
        }
      } catch (e) {
        Get.log('DashboardController: Error fetching user: $e');
      }

      final workspaceId = _workspacesController.activeWorkspace?.id;
      if (workspaceId == null) {
        status.value = RxStatus.empty();
        return;
      }

      isLoading.value = true;
      status.value = RxStatus.loading();
      Get.log(
        'DashboardController: Starting loadDashboard for workspace $workspaceId',
      );

      // Update currency from active workspace
      final ws = _workspacesController.activeWorkspace;
      if (ws != null) {
        currency.value = ws.currency;
        secondaryCurrency.value = ws.secondaryCurrency;
        if (Get.isRegistered<ExchangeRateService>()) {
          exchangeRate.value = Get.find<ExchangeRateService>().getEffectiveRate(
            ws.exchangeRateMode,
            ws.manualExchangeRate,
          );
        }
      }

      // Calculate Current Month Range
      final now = DateTime.now();
      final startMonth = DateTime(now.year, now.month, 1);
      final endMonth = DateTime(now.year, now.month + 1, 0);
      final previousMonthDate = DateTime(now.year, now.month - 1, 1);
      final previousMonthStart = DateTime(
        previousMonthDate.year,
        previousMonthDate.month,
        1,
      );
      final previousMonthEnd = DateTime(
        previousMonthDate.year,
        previousMonthDate.month + 1,
        0,
      );

      Get.log('DashboardController: Fetching summary...');
      final summaries = await Future.wait([
        _directusService.getDashboardSummary(
          startDate: startMonth,
          endDate: endMonth,
          workspaceId: workspaceId,
        ),
        _directusService.getDashboardSummary(
          startDate: previousMonthStart,
          endDate: previousMonthEnd,
          workspaceId: workspaceId,
        ),
      ]).timeout(const Duration(seconds: 30));
      Get.log('DashboardController: Summary fetched');

      final DashboardSummary summary = summaries[0];
      final DashboardSummary previousSummary = summaries[1];

      totalIncome.value = summary.monthlyIncome;
      totalExpense.value = summary.monthlyExpenses;
      previousIncome.value = previousSummary.monthlyIncome;
      previousExpense.value = previousSummary.monthlyExpenses;
      totalBalance.value = summary.currentBalance;
      openingBalance.value = summary.openingBalance;
      incomeChangePercentage.value = _calculatePercentageChange(
        current: summary.monthlyIncome,
        previous: previousSummary.monthlyIncome,
      );
      expenseChangePercentage.value = _calculatePercentageChange(
        current: summary.monthlyExpenses,
        previous: previousSummary.monthlyExpenses,
      );

      final currentMonthNet = summary.monthlyIncome - summary.monthlyExpenses;
      final previousBalance = summary.currentBalance - currentMonthNet;
      balanceChangePercentage.value = _calculatePercentageChange(
        current: summary.currentBalance,
        previous: previousBalance,
      );

      // Calculate Current Week Range (Mon-Sun)
      final startWeek = now.subtract(Duration(days: now.weekday - 1));
      final endWeek = startWeek.add(const Duration(days: 6));

      Get.log('DashboardController: Fetching daily flow...');
      // Fetch Daily Cash Flow
      final dailyFlow = await _directusService
          .getDailyCashFlow(
            startDate: startWeek,
            endDate: endWeek,
            workspaceId: workspaceId,
          )
          .timeout(const Duration(seconds: 30));
      Get.log('DashboardController: Daily flow fetched');

      _processWeeklyData(dailyFlow, startWeek);

      Get.log('DashboardController: Fetching recent transactions...');
      // Fetch Recent Transactions
      final results = await Future.wait([
        _directusService.getTransactions(limit: 10, workspaceId: workspaceId),
        _directusService.getAccounts(workspaceId: workspaceId),
      ]).timeout(const Duration(seconds: 30));
      Get.log('DashboardController: Recent transactions fetched');

      final transactions = results[0] as List<Transaction>;
      final accountList = results[1] as List<Account>;
      accounts.assignAll(accountList);
      final openingTransactions = accountList
          .where((account) => account.initialBalance > 0)
          .map(
            (account) => Transaction(
              id: 'opening-${account.id}',
              amount: account.initialBalance,
              concept: 'Saldo inicial: ${account.name}',
              date: account.createdAt ?? startMonth,
              type: 'opening_balance',
              isPersonal: true,
              accountId: account.id,
              currency: account.currency,
            ),
          )
          .toList();

      final merged = [...transactions, ...openingTransactions]
        ..sort((a, b) => b.date.compareTo(a.date));
      recentTransactions.assignAll(merged.take(5).toList());

      status.value = RxStatus.success();
    } catch (e) {
      Get.log("DashboardController: Error loading dashboard: $e");
      status.value = RxStatus.error(e.toString());
      if (!Get.testMode) {
        Get.snackbar('Error', 'Error cargando dashboard. Intenta de nuevo.');
      }
    } finally {
      isLoading.value = false;
      Get.log('DashboardController: loadDashboard finished, isLoading=false');
    }
  }

  void _processWeeklyData(List<Map<String, dynamic>> data, DateTime startWeek) {
    // Initialize 7 days with 0
    final Map<int, double> dailyNet = {
      0: 0.0,
      1: 0.0,
      2: 0.0,
      3: 0.0,
      4: 0.0,
      5: 0.0,
      6: 0.0,
    };

    double totalWeekParams = 0.0;

    for (var item in data) {
      final dateStr = item['date'];
      final amount = double.tryParse(item['amount'].toString()) ?? 0.0;
      final type = item['type'];

      if (dateStr != null) {
        final date = DateTime.parse(dateStr);
        // Calculate diff in days from startWeek to get index 0-6
        // Use normalized dates (truncate time)
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final normalizedStart = DateTime(
          startWeek.year,
          startWeek.month,
          startWeek.day,
        );

        final diff = normalizedDate.difference(normalizedStart).inDays;

        if (diff >= 0 && diff <= 6) {
          if (type == 'income') {
            dailyNet[diff] = (dailyNet[diff] ?? 0.0) + amount;
            totalWeekParams += amount;
          } else {
            dailyNet[diff] = (dailyNet[diff] ?? 0.0) - amount;
            totalWeekParams -= amount;
          }
        }
      }
    }

    final spots = <FlSpot>[];
    dailyNet.forEach((key, value) {
      spots.add(FlSpot(key.toDouble(), value));
    });

    weeklySpots.assignAll(spots);
    weeklyNetFlow.value = totalWeekParams;
  }

  void changeTab(int index) {
    tabIndex.value = index;
  }

  void toggleDashboardView() {
    useAlternativeView.value = !useAlternativeView.value;
  }

  double get monthlyNetFlow => totalIncome.value - totalExpense.value;

  /// Insights financieros inteligentes basados en datos reales
  List<String> get insights {
    final list = <String>[];
    if (totalIncome.value > 0) {
      final savingsRate = ((totalIncome.value - totalExpense.value) / totalIncome.value * 100);
      if (savingsRate > 0) {
        list.add('Estás ahorrando ${savingsRate.toStringAsFixed(0)}% de tus ingresos este mes');
      } else {
        list.add('Cuidado: estás gastando más de lo que ingresas este mes');
      }
    }
    if (expenseChangePercentage.value > 20) {
      list.add('Tus gastos subieron ${expenseChangePercentage.value.toStringAsFixed(0)}% vs el mes pasado');
    } else if (expenseChangePercentage.value < -10) {
      list.add('Excelente: redujiste gastos ${expenseChangePercentage.value.abs().toStringAsFixed(0)}% vs el mes pasado');
    }
    if (incomeChangePercentage.value > 10) {
      list.add('Tus ingresos crecieron ${incomeChangePercentage.value.toStringAsFixed(0)}% este mes');
    } else if (incomeChangePercentage.value < -10) {
      list.add('Tus ingresos bajaron ${incomeChangePercentage.value.abs().toStringAsFixed(0)}% vs el mes pasado');
    }
    return list.take(3).toList();
  }

  /// Desglose de gastos por categoría
  Map<String, double> get categoryBreakdown {
    final map = <String, double>{};
    for (final t in recentTransactions) {
      if (t.type == 'expense' && t.category != null) {
        final name = t.category!.name;
        map[name] = (map[name] ?? 0) + t.amount;
      }
    }
    return map;
  }

  String get balanceFootnote {
    if (openingBalance.value > 0) {
      return 'Incluye saldo inicial de ${CurrencyUtils.formatInDisplayCurrency(openingBalance.value, currency.value)}';
    }
    return 'Actualizado hace un momento';
  }

  String get balanceBreakdown {
    final opening = CurrencyUtils.formatInDisplayCurrency(
      openingBalance.value,
      currency.value,
    );
    final income = CurrencyUtils.formatInDisplayCurrency(
      totalIncome.value,
      currency.value,
    );
    final expense = CurrencyUtils.formatInDisplayCurrency(
      totalExpense.value,
      currency.value,
    );
    return '$opening inicial + $income ingresos - $expense gastos';
  }

  double _calculatePercentageChange({
    required double current,
    required double previous,
  }) {
    if (previous == 0) {
      return current == 0 ? 0.0 : 100.0;
    }
    return ((current - previous) / previous) * 100;
  }
}
