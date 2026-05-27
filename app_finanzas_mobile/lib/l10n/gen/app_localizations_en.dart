// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Personal Finance';

  @override
  String get aiCoachTitle => 'Financial Coach';

  @override
  String get aiCoachSubtitle => 'AI assistant';

  @override
  String get aiCoachWelcome =>
      'Hi! I\'m your **Financial Coach** 💡\n\nI have access to your data and can analyze spending, optimize budgets, plan debt payoff, record movements and open views for you. How can I help today?';

  @override
  String get aiCoachReadyTitle => 'Financial Coach\nready to help';

  @override
  String get aiCoachConnectGemini =>
      'Connect your Google Gemini API key to activate the assistant. Free, takes 1 minute.';

  @override
  String get aiCoachInsightsHeader => '🔎 **What I detected in your data:**';

  @override
  String get aiCoachInsightBudgetsExceeded =>
      'You have **exceeded** budgets this month. Ask which ones.';

  @override
  String get aiCoachInsightBudgetsAtRisk =>
      'Some budgets are **at risk** (≥80% spent).';

  @override
  String get aiCoachInsightDebtsActive =>
      'You have **active debts**. Want a payoff plan?';

  @override
  String aiCoachInsightSaveRateNegative(String rate) {
    return 'You\'re **spending more than you earn** this month ($rate%).';
  }

  @override
  String aiCoachInsightSaveRateLow(String rate) {
    return 'Your savings rate is low ($rate%). Healthy target: ≥20%.';
  }

  @override
  String get aiCoachErrorApiKey =>
      '🔑 **Invalid API key**. Go to Settings > AI Configuration.';

  @override
  String get aiCoachErrorQuota =>
      '⏳ **Quota exhausted**. Wait a few minutes and retry.';

  @override
  String get aiCoachErrorSafety =>
      '🛡️ Response blocked by safety filters. Rephrase your question.';

  @override
  String get aiCoachErrorTimeout =>
      '⏱️ Response took too long. Check your connection and retry.';

  @override
  String get aiCoachErrorGeneric => '❌ Error fetching response. Try again.';

  @override
  String get aiCoachErrorMaxIterations =>
      '⚠️ Reached analysis step limit. Try a more specific question.';

  @override
  String get aiCoachErrorNoApi =>
      '⚠️ Gemini API not configured.\nGo to **Settings > AI Configuration** to add your API key.';

  @override
  String get aiCoachContextRefreshed => '✅ Context refreshed with latest data.';

  @override
  String get aiCoachNoWorkspace => 'No active workspace.';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonApprove => 'Approve';

  @override
  String get commonReject => 'Reject';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get errorRequired => 'Field required';

  @override
  String get errorInvalidEmail => 'Invalid email';

  @override
  String get errorAmountInvalid => 'Invalid amount';

  @override
  String get errorAmountPositive => 'Must be greater than zero';

  @override
  String get errorPasswordShort => 'Password too short';

  @override
  String get debtsTitle => 'My Debts';

  @override
  String get debtsEmpty => 'No debts registered.';

  @override
  String get debtsAddNew => 'New Debt';

  @override
  String get debtsTotalAmount => 'Total Amount';

  @override
  String get debtsInterest => 'Interest (%)';

  @override
  String get debtsDueDate => 'Due date';

  @override
  String get debtsRegister => 'REGISTER DEBT';

  @override
  String get debtsNameLabel => 'Debt name';

  @override
  String get debtsGeneralInfo => 'General Information';

  @override
  String get savingsTitle => 'My Savings';

  @override
  String get savingsActiveGoals => 'ACTIVE GOALS';

  @override
  String savingsGoalsCount(int count) {
    return '$count Goals';
  }

  @override
  String get savingsCreateGoal => 'Create goal';

  @override
  String get savingsGoalName => 'Goal name';

  @override
  String get savingsTargetAmount => 'Target amount';

  @override
  String get savingsTargetDate => 'Target date';

  @override
  String get savingsTotalSaved => 'Total saved';

  @override
  String get savingsAddFunds => 'Deposit';

  @override
  String get savingsWithdrawFunds => 'Withdraw';

  @override
  String get budgetsTitle => 'My Budgets';

  @override
  String get budgetsEmptyTitle => 'Take full control of your finances';

  @override
  String get budgetsEmptyBody =>
      'Set monthly limits per category to avoid unnecessary spending and reach your savings goals faster.';

  @override
  String get budgetsCreate => 'Create budget';

  @override
  String get budgetsLimit => 'Limit';

  @override
  String get budgetsCategory => 'Category';

  @override
  String get subscriptionsTitle => 'Subscriptions';

  @override
  String get subscriptionsEmpty => 'No subscriptions found.\nAdd one manually.';

  @override
  String get subscriptionsAdd => 'Add Subscription';

  @override
  String get subscriptionsCancelled => 'Cancelled';

  @override
  String get subscriptionsName => 'Name';

  @override
  String get subscriptionsAmount => 'Monthly Amount';

  @override
  String get subscriptionsDay => 'Billing day (1-31)';

  @override
  String get subscriptionsRegisterPayment => 'Register payment';

  @override
  String get recurringTitle => 'Recurring Payments';

  @override
  String get recurringEmpty => 'No active subscriptions.';

  @override
  String get recurringManage => 'Manage subscriptions';

  @override
  String recurringDueIn(int days, int day) {
    return 'Due in $days days (Day $day)';
  }

  @override
  String get recurringConfirmPay => 'Confirm Payment';

  @override
  String recurringPayPrompt(String name, String amount) {
    return 'Register payment of $name for \$$amount?';
  }

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get transactionsEmpty => 'No transactions in this period';

  @override
  String get transactionsAdd => 'New transaction';

  @override
  String get transactionsConcept => 'Concept';

  @override
  String get transactionsAmount => 'Amount';

  @override
  String get transactionsCategory => 'Category';

  @override
  String get transactionsDate => 'Date';

  @override
  String get transactionsTypeIncome => 'Income';

  @override
  String get transactionsTypeExpense => 'Expense';

  @override
  String get incomesTitle => 'My Incomes';

  @override
  String get incomesEmpty => 'No incomes registered.';

  @override
  String get incomesAdd => 'Add income';

  @override
  String get incomesSource => 'Source';

  @override
  String get incomesAmount => 'Amount';

  @override
  String get incomesPlanned => 'Planned';

  @override
  String get incomesActual => 'Received';

  @override
  String get expensesTitle => 'My Expenses';

  @override
  String get expensesEmpty => 'No expenses registered.';

  @override
  String get expensesAdd => 'New expense';

  @override
  String get eventsTitle => 'Events';

  @override
  String get eventsEmpty => 'No scheduled events.';

  @override
  String get eventsAdd => 'New event';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountsEmpty => 'No accounts.';

  @override
  String get accountsBalance => 'Balance';

  @override
  String get accountsCreate => 'Create account';

  @override
  String get scanReceiptTitle => 'Scan receipt';

  @override
  String get scanReceiptUpload => 'Upload file';

  @override
  String get scanReceiptCapture => 'Take photo';

  @override
  String get scanReceiptGallery => 'Gallery';

  @override
  String get scanReceiptProcessing => 'Processing…';

  @override
  String get scanReceiptAnalyzed => 'Analyzed';

  @override
  String get scanReceiptFailed => 'Failed';

  @override
  String get scanReceiptRecentUploads => 'Recent uploads';

  @override
  String get homeTabDashboard => 'Dashboard';

  @override
  String get homeTabTransactions => 'Transactions';

  @override
  String get homeTabSettings => 'Settings';

  @override
  String get homeTabCoach => 'Coach';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsEmpty => 'No data to display';

  @override
  String get statsByCategory => 'By category';

  @override
  String get statsTrend => 'Trend';

  @override
  String get createEventTitle => 'New Event / Trip';

  @override
  String get createEventName => 'Event name';

  @override
  String get createEventDescription => 'Description';

  @override
  String get createEventBudget => 'Budget';

  @override
  String get createEventStart => 'Start date';

  @override
  String get createEventEnd => 'End date';

  @override
  String get createEventSubmit => 'Create Event';

  @override
  String get addIncomeTitle => 'Register Income';

  @override
  String get addExpenseTitle => 'New Expense';

  @override
  String get createSavingTitle => 'New Savings Goal';

  @override
  String get createWorkspaceTitle => 'Create Workspace';

  @override
  String get aiSettingsTitle => 'AI Configuration';

  @override
  String get membersTitle => 'Members';

  @override
  String get accountDetailTitle => 'Account Detail';

  @override
  String get currencySettingsTitle => 'Currency & Conversion';

  @override
  String get loginEmailHint => 'you@email.com';

  @override
  String get loginPasswordHint => 'Min 8 characters';

  @override
  String get registerNameHint => 'Your name';

  @override
  String get transactionItemsTitle => 'Items';

  @override
  String get transactionItemsEmpty => 'No items';

  @override
  String get transactionItemEvolutionTitle => 'Price evolution';

  @override
  String get organizationsTitle => 'Organizations';

  @override
  String get organizationsEmpty => 'You don\'t have organizations yet';

  @override
  String get organizationsNew => 'New Organization';

  @override
  String get organizationsCreate => 'Create New Organization';

  @override
  String get organizationsNameLabel => 'Organization name';

  @override
  String get organizationsInviteRevoke => 'Revoke invitation';

  @override
  String organizationsConfirmRevoke(String email) {
    return 'Revoke the invitation to $email?';
  }

  @override
  String get organizationsInviteMember => 'Invite member';

  @override
  String get organizationsRole => 'Role';

  @override
  String get workspacesTitle => 'Workspaces';

  @override
  String get workspaceEditTitle => 'Edit Workspace';

  @override
  String get workspaceNameLabel => 'Workspace name';

  @override
  String get workspaceCreate => 'Create workspace';

  @override
  String get workspaceDelete => 'Delete Workspace';

  @override
  String get workspaceDeleteWarning =>
      'This action cannot be undone. All financial data and AI settings will be lost.';

  @override
  String get workspaceCurrency => 'Currency';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsAi => 'AI Configuration';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get securityTitle => 'Security';

  @override
  String get securityPin => 'PIN';

  @override
  String get securityBiometric => 'Biometrics';

  @override
  String get setupTitle => 'Initial setup';

  @override
  String get setupWelcome => 'Welcome';

  @override
  String get setupCreateFirst => 'Create your first workspace to begin';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authLoginEmail => 'Email';

  @override
  String get authLoginPassword => 'Password';

  @override
  String get authLoginButton => 'SIGN IN';

  @override
  String get authLoginForgot => 'Forgot your password?';

  @override
  String get authLoginNoAccount => 'No account yet?';

  @override
  String get authLoginRegister => 'Sign up';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get authRegisterName => 'Name';

  @override
  String get authRegisterButton => 'SIGN UP';

  @override
  String get authRegisterHaveAccount => 'Already have an account?';

  @override
  String get authRegisterLogin => 'Sign in';

  @override
  String get authForgotTitle => 'Recover Password';

  @override
  String get authForgotHint =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get authForgotButton => 'SEND LINK';

  @override
  String get authForgotSuccess => 'Email Sent';

  @override
  String get authForgotSuccessBody =>
      'Check your inbox to reset your password.';

  @override
  String get authForgotError =>
      'Could not send email. Check that the address is correct.';

  @override
  String get authForgotInvalidEmail => 'Invalid email';

  @override
  String get invitationsTitle => 'Invitations';

  @override
  String get invitationsEmpty => 'No pending invitations.';
}
