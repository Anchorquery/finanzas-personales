import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/setup/views/setup_view.dart';
import '../modules/setup/bindings/setup_binding.dart';
import '../modules/savings/views/create_saving_goal_view.dart';
import '../modules/savings/bindings/savings_binding.dart';
import '../modules/incomes/views/add_income_view.dart';
import '../modules/incomes/bindings/incomes_binding.dart';
import '../modules/organizations/views/organizations_list_view.dart';
import '../modules/organizations/views/organization_details_view.dart';
import '../modules/auth/views/invitations_view.dart';
import '../modules/auth/controllers/invitations_controller.dart';
import '../modules/workspaces/views/workspace_settings_view.dart';
import '../modules/workspaces/controllers/workspace_settings_controller.dart';
import '../modules/workspaces/views/create_workspace_view.dart';
import '../modules/workspaces/controllers/workspaces_controller.dart';
import '../modules/transactions/views/add_transaction_view.dart';
import '../modules/transactions/bindings/transactions_binding.dart';
import '../modules/events/views/create_event_view.dart';
import '../modules/events/bindings/events_binding.dart';
import '../modules/organizations/controllers/organizations_controller.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/scan_receipt/views/scan_receipt_view.dart';
import '../modules/scan_receipt/bindings/scan_receipt_binding.dart';
import '../modules/security/views/security_view.dart';
import '../modules/security/bindings/security_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.login;
  static final _homeBindings = [HomeBinding()];

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: Routes.setup,
      page: () => const SetupView(),
      binding: SetupBinding(),
    ),
    // Rutas que abren la shell del home con el índice correcto (sidebar visible en web)
    GetPage(
      name: Routes.aiCoach,
      page: () => const HomeView(initialIndex: HomeController.coachIndex),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.settings,
      page: () => const HomeView(initialIndex: HomeController.settingsIndex),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.savings,
      page: () => const HomeView(initialIndex: HomeController.savingsIndex),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.budgets,
      page: () => const HomeView(initialIndex: HomeController.budgetsIndex),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.debts,
      page: () => const HomeView(initialIndex: HomeController.debtsIndex),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.incomes,
      page: () => const HomeView(initialIndex: HomeController.incomesIndex),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.subscriptions,
      page: () => const HomeView(initialIndex: HomeController.subscriptionsIndex),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.expenses,
      page: () => const HomeView(initialIndex: HomeController.expensesIndex),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.transactions,
      page: () => const HomeView(initialIndex: HomeController.transactionsIndex),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.events,
      page: () => const HomeView(initialIndex: HomeController.eventsIndex),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.workspaces,
      page: () => const HomeView(initialIndex: HomeController.workspacesIndex),
      bindings: _homeBindings,
    ),
    GetPage(
      name: Routes.recurring,
      page: () => const HomeView(initialIndex: HomeController.recurringIndex),
      bindings: _homeBindings,
    ),
    // Sub-rutas (pantallas de detalle / creación — abren sobre la shell)
    GetPage(
      name: Routes.addIncome,
      page: () => const AddIncomeView(),
      binding: IncomesBinding(),
    ),
    GetPage(
      name: Routes.organizations,
      page: () => const OrganizationsListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OrganizationsController>(() => OrganizationsController());
      }),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.organizationDetails,
      page: () => const OrganizationDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OrganizationsController>(() => OrganizationsController());
      }),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.invitations,
      page: () => const InvitationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<InvitationsController>(() => InvitationsController());
      }),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.createWorkspace,
      page: () => const CreateWorkspaceView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WorkspacesController>(() => WorkspacesController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.workspaceSettings,
      page: () => const WorkspaceSettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WorkspaceSettingsController>(
          () => WorkspaceSettingsController(),
        );
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.createSavingGoal,
      page: () => const CreateSavingGoalView(),
      binding: SavingsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.scanReceipt,
      page: () => const ScanReceiptView(),
      binding: ScanReceiptBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.createEvent,
      page: () => const CreateEventView(),
      binding: EventsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.createTransaction,
      page: () => const AddTransactionView(),
      binding: TransactionsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.security,
      page: () => const SecurityView(),
      binding: SecurityBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
