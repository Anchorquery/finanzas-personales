import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../stats/views/stats_view.dart';
import '../../ai_coach/controllers/ai_coach_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../workspaces/controllers/workspaces_controller.dart';
import '../../savings/controllers/savings_controller.dart';
import '../../budgets/controllers/budgets_controller.dart';
import '../../debts/controllers/debts_controller.dart';
import '../../incomes/controllers/incomes_controller.dart';
import '../../subscriptions/controllers/subscriptions_controller.dart';
import '../../expenses/controllers/expenses_controller.dart';
import '../../transactions/controllers/transactions_controller.dart';
import '../../transactions/controllers/templates_controller.dart';
import '../../events/controllers/events_controller.dart';
import '../../recurring/controllers/recurring_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<StatsController>(() => StatsController());
    Get.lazyPut<AICoachController>(() => AICoachController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.put<WorkspacesController>(WorkspacesController());
    Get.lazyPut<SavingsController>(() => SavingsController(), fenix: true);
    Get.lazyPut<BudgetsController>(() => BudgetsController(), fenix: true);
    Get.lazyPut<DebtsController>(() => DebtsController(), fenix: true);
    Get.lazyPut<IncomesController>(() => IncomesController(), fenix: true);
    Get.lazyPut<SubscriptionsController>(() => SubscriptionsController(), fenix: true);
    Get.lazyPut<ExpensesController>(() => ExpensesController(), fenix: true);
    Get.lazyPut<TransactionsController>(() => TransactionsController(), fenix: true);
    Get.lazyPut<TemplatesController>(() => TemplatesController(), fenix: true);
    Get.lazyPut<EventsController>(() => EventsController(), fenix: true);
    Get.lazyPut<RecurringController>(() => RecurringController(), fenix: true);
  }
}
