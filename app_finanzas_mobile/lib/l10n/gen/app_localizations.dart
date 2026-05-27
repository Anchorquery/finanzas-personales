import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// App title
  ///
  /// In es, this message translates to:
  /// **'Finanzas Personales'**
  String get appTitle;

  /// No description provided for @aiCoachTitle.
  ///
  /// In es, this message translates to:
  /// **'Coach Financiero'**
  String get aiCoachTitle;

  /// No description provided for @aiCoachSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Asistente con IA'**
  String get aiCoachSubtitle;

  /// No description provided for @aiCoachWelcome.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Soy tu **Coach Financiero** 💡\n\nTengo acceso a tus datos y puedo analizar gastos, optimizar presupuestos, planificar el pago de deudas, registrar movimientos y abrir vistas por ti. ¿En qué te ayudo hoy?'**
  String get aiCoachWelcome;

  /// No description provided for @aiCoachReadyTitle.
  ///
  /// In es, this message translates to:
  /// **'Coach Financiero\nlisto para ayudarte'**
  String get aiCoachReadyTitle;

  /// No description provided for @aiCoachConnectGemini.
  ///
  /// In es, this message translates to:
  /// **'Conecta tu API key de Google Gemini para activar el asistente. Gratis y en 1 minuto.'**
  String get aiCoachConnectGemini;

  /// No description provided for @aiCoachInsightsHeader.
  ///
  /// In es, this message translates to:
  /// **'🔎 **Lo que detecté en tus datos:**'**
  String get aiCoachInsightsHeader;

  /// No description provided for @aiCoachInsightBudgetsExceeded.
  ///
  /// In es, this message translates to:
  /// **'Tienes presupuestos **excedidos** este mes. Pregunta cuáles.'**
  String get aiCoachInsightBudgetsExceeded;

  /// No description provided for @aiCoachInsightBudgetsAtRisk.
  ///
  /// In es, this message translates to:
  /// **'Hay presupuestos **en riesgo** (≥80% gastado).'**
  String get aiCoachInsightBudgetsAtRisk;

  /// No description provided for @aiCoachInsightDebtsActive.
  ///
  /// In es, this message translates to:
  /// **'Tienes **deudas activas**. ¿Quieres un plan de pago?'**
  String get aiCoachInsightDebtsActive;

  /// No description provided for @aiCoachInsightSaveRateNegative.
  ///
  /// In es, this message translates to:
  /// **'Estás **gastando más de lo que ingresas** este mes ({rate}%).'**
  String aiCoachInsightSaveRateNegative(String rate);

  /// No description provided for @aiCoachInsightSaveRateLow.
  ///
  /// In es, this message translates to:
  /// **'Tu tasa de ahorro es baja ({rate}%). Meta saludable: ≥20%.'**
  String aiCoachInsightSaveRateLow(String rate);

  /// No description provided for @aiCoachErrorApiKey.
  ///
  /// In es, this message translates to:
  /// **'🔑 **API key inválida**. Ve a Ajustes > Configuración AI.'**
  String get aiCoachErrorApiKey;

  /// No description provided for @aiCoachErrorQuota.
  ///
  /// In es, this message translates to:
  /// **'⏳ **Cuota agotada**. Espera unos minutos e intenta de nuevo.'**
  String get aiCoachErrorQuota;

  /// No description provided for @aiCoachErrorSafety.
  ///
  /// In es, this message translates to:
  /// **'🛡️ Respuesta bloqueada por filtros de seguridad. Reformula tu pregunta.'**
  String get aiCoachErrorSafety;

  /// No description provided for @aiCoachErrorTimeout.
  ///
  /// In es, this message translates to:
  /// **'⏱️ La respuesta tardó demasiado. Verifica tu conexión e intenta de nuevo.'**
  String get aiCoachErrorTimeout;

  /// No description provided for @aiCoachErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'❌ Error al obtener respuesta. Intenta de nuevo.'**
  String get aiCoachErrorGeneric;

  /// No description provided for @aiCoachErrorMaxIterations.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Alcancé el límite de pasos del análisis. Intenta con una pregunta más específica.'**
  String get aiCoachErrorMaxIterations;

  /// No description provided for @aiCoachErrorNoApi.
  ///
  /// In es, this message translates to:
  /// **'⚠️ No tengo configurada la API de Gemini.\nVe a **Ajustes > Configuración AI** para agregar tu API key.'**
  String get aiCoachErrorNoApi;

  /// No description provided for @aiCoachContextRefreshed.
  ///
  /// In es, this message translates to:
  /// **'✅ Contexto actualizado con los datos más recientes.'**
  String get aiCoachContextRefreshed;

  /// No description provided for @aiCoachNoWorkspace.
  ///
  /// In es, this message translates to:
  /// **'No hay workspace activo.'**
  String get aiCoachNoWorkspace;

  /// No description provided for @commonOk.
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonApprove.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get commonApprove;

  /// No description provided for @commonReject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get commonReject;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get commonAdd;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonRequired.
  ///
  /// In es, this message translates to:
  /// **'Requerido'**
  String get commonRequired;

  /// No description provided for @commonLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get commonLoading;

  /// No description provided for @commonContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get commonBack;

  /// No description provided for @commonError.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get commonSuccess;

  /// No description provided for @errorRequired.
  ///
  /// In es, this message translates to:
  /// **'Campo requerido'**
  String get errorRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo inválido'**
  String get errorInvalidEmail;

  /// No description provided for @errorAmountInvalid.
  ///
  /// In es, this message translates to:
  /// **'Monto inválido'**
  String get errorAmountInvalid;

  /// No description provided for @errorAmountPositive.
  ///
  /// In es, this message translates to:
  /// **'Debe ser mayor que cero'**
  String get errorAmountPositive;

  /// No description provided for @errorPasswordShort.
  ///
  /// In es, this message translates to:
  /// **'Contraseña muy corta'**
  String get errorPasswordShort;

  /// No description provided for @debtsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Deudas'**
  String get debtsTitle;

  /// No description provided for @debtsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay deudas registradas.'**
  String get debtsEmpty;

  /// No description provided for @debtsAddNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva Deuda'**
  String get debtsAddNew;

  /// No description provided for @debtsTotalAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto Total'**
  String get debtsTotalAmount;

  /// No description provided for @debtsInterest.
  ///
  /// In es, this message translates to:
  /// **'Interés (%)'**
  String get debtsInterest;

  /// No description provided for @debtsDueDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de vencimiento'**
  String get debtsDueDate;

  /// No description provided for @debtsRegister.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR DEUDA'**
  String get debtsRegister;

  /// No description provided for @debtsNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la deuda'**
  String get debtsNameLabel;

  /// No description provided for @debtsGeneralInfo.
  ///
  /// In es, this message translates to:
  /// **'Información General'**
  String get debtsGeneralInfo;

  /// No description provided for @savingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Ahorros'**
  String get savingsTitle;

  /// No description provided for @savingsActiveGoals.
  ///
  /// In es, this message translates to:
  /// **'METAS ACTIVAS'**
  String get savingsActiveGoals;

  /// No description provided for @savingsGoalsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} Metas'**
  String savingsGoalsCount(int count);

  /// No description provided for @savingsCreateGoal.
  ///
  /// In es, this message translates to:
  /// **'Crear meta'**
  String get savingsCreateGoal;

  /// No description provided for @savingsGoalName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la meta'**
  String get savingsGoalName;

  /// No description provided for @savingsTargetAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto objetivo'**
  String get savingsTargetAmount;

  /// No description provided for @savingsTargetDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha objetivo'**
  String get savingsTargetDate;

  /// No description provided for @savingsTotalSaved.
  ///
  /// In es, this message translates to:
  /// **'Total ahorrado'**
  String get savingsTotalSaved;

  /// No description provided for @savingsAddFunds.
  ///
  /// In es, this message translates to:
  /// **'Aportar'**
  String get savingsAddFunds;

  /// No description provided for @savingsWithdrawFunds.
  ///
  /// In es, this message translates to:
  /// **'Retirar'**
  String get savingsWithdrawFunds;

  /// No description provided for @budgetsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Presupuestos'**
  String get budgetsTitle;

  /// No description provided for @budgetsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Control total de tus finanzas'**
  String get budgetsEmptyTitle;

  /// No description provided for @budgetsEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Define límites mensuales por categoría para evitar gastos innecesarios y alcanzar tus metas de ahorro más rápido.'**
  String get budgetsEmptyBody;

  /// No description provided for @budgetsCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear presupuesto'**
  String get budgetsCreate;

  /// No description provided for @budgetsLimit.
  ///
  /// In es, this message translates to:
  /// **'Límite'**
  String get budgetsLimit;

  /// No description provided for @budgetsCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get budgetsCategory;

  /// No description provided for @subscriptionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Suscripciones'**
  String get subscriptionsTitle;

  /// No description provided for @subscriptionsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron suscripciones.\nAgrega una manualmente.'**
  String get subscriptionsEmpty;

  /// No description provided for @subscriptionsAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar Suscripción'**
  String get subscriptionsAdd;

  /// No description provided for @subscriptionsCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get subscriptionsCancelled;

  /// No description provided for @subscriptionsName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get subscriptionsName;

  /// No description provided for @subscriptionsAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto Mensual'**
  String get subscriptionsAmount;

  /// No description provided for @subscriptionsDay.
  ///
  /// In es, this message translates to:
  /// **'Día de cobro (1-31)'**
  String get subscriptionsDay;

  /// No description provided for @subscriptionsRegisterPayment.
  ///
  /// In es, this message translates to:
  /// **'Registrar pago'**
  String get subscriptionsRegisterPayment;

  /// No description provided for @recurringTitle.
  ///
  /// In es, this message translates to:
  /// **'Pagos Recurrentes'**
  String get recurringTitle;

  /// No description provided for @recurringEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay suscripciones activas.'**
  String get recurringEmpty;

  /// No description provided for @recurringManage.
  ///
  /// In es, this message translates to:
  /// **'Gestionar suscripciones'**
  String get recurringManage;

  /// No description provided for @recurringDueIn.
  ///
  /// In es, this message translates to:
  /// **'Vence en {days} días (Día {day})'**
  String recurringDueIn(int days, int day);

  /// No description provided for @recurringConfirmPay.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Pago'**
  String get recurringConfirmPay;

  /// No description provided for @recurringPayPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Registrar pago de {name} por \${amount}?'**
  String recurringPayPrompt(String name, String amount);

  /// No description provided for @transactionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Transacciones'**
  String get transactionsTitle;

  /// No description provided for @transactionsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin transacciones en este período'**
  String get transactionsEmpty;

  /// No description provided for @transactionsAdd.
  ///
  /// In es, this message translates to:
  /// **'Nueva transacción'**
  String get transactionsAdd;

  /// No description provided for @transactionsConcept.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get transactionsConcept;

  /// No description provided for @transactionsAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get transactionsAmount;

  /// No description provided for @transactionsCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get transactionsCategory;

  /// No description provided for @transactionsDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get transactionsDate;

  /// No description provided for @transactionsTypeIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get transactionsTypeIncome;

  /// No description provided for @transactionsTypeExpense.
  ///
  /// In es, this message translates to:
  /// **'Gasto'**
  String get transactionsTypeExpense;

  /// No description provided for @incomesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Ingresos'**
  String get incomesTitle;

  /// No description provided for @incomesEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay ingresos registrados.'**
  String get incomesEmpty;

  /// No description provided for @incomesAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar ingreso'**
  String get incomesAdd;

  /// No description provided for @incomesSource.
  ///
  /// In es, this message translates to:
  /// **'Fuente'**
  String get incomesSource;

  /// No description provided for @incomesAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get incomesAmount;

  /// No description provided for @incomesPlanned.
  ///
  /// In es, this message translates to:
  /// **'Planificados'**
  String get incomesPlanned;

  /// No description provided for @incomesActual.
  ///
  /// In es, this message translates to:
  /// **'Recibidos'**
  String get incomesActual;

  /// No description provided for @expensesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Gastos'**
  String get expensesTitle;

  /// No description provided for @expensesEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay gastos registrados.'**
  String get expensesEmpty;

  /// No description provided for @expensesAdd.
  ///
  /// In es, this message translates to:
  /// **'Nuevo gasto'**
  String get expensesAdd;

  /// No description provided for @eventsTitle.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get eventsTitle;

  /// No description provided for @eventsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay eventos programados.'**
  String get eventsEmpty;

  /// No description provided for @eventsAdd.
  ///
  /// In es, this message translates to:
  /// **'Nuevo evento'**
  String get eventsAdd;

  /// No description provided for @accountsTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuentas'**
  String get accountsTitle;

  /// No description provided for @accountsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay cuentas.'**
  String get accountsEmpty;

  /// No description provided for @accountsBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo'**
  String get accountsBalance;

  /// No description provided for @accountsCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get accountsCreate;

  /// No description provided for @scanReceiptTitle.
  ///
  /// In es, this message translates to:
  /// **'Escanear recibo'**
  String get scanReceiptTitle;

  /// No description provided for @scanReceiptUpload.
  ///
  /// In es, this message translates to:
  /// **'Subir archivo'**
  String get scanReceiptUpload;

  /// No description provided for @scanReceiptCapture.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get scanReceiptCapture;

  /// No description provided for @scanReceiptGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get scanReceiptGallery;

  /// No description provided for @scanReceiptProcessing.
  ///
  /// In es, this message translates to:
  /// **'Procesando…'**
  String get scanReceiptProcessing;

  /// No description provided for @scanReceiptAnalyzed.
  ///
  /// In es, this message translates to:
  /// **'Analizado'**
  String get scanReceiptAnalyzed;

  /// No description provided for @scanReceiptFailed.
  ///
  /// In es, this message translates to:
  /// **'Falló'**
  String get scanReceiptFailed;

  /// No description provided for @scanReceiptRecentUploads.
  ///
  /// In es, this message translates to:
  /// **'Subidas recientes'**
  String get scanReceiptRecentUploads;

  /// No description provided for @homeTabDashboard.
  ///
  /// In es, this message translates to:
  /// **'Dashboard'**
  String get homeTabDashboard;

  /// No description provided for @homeTabTransactions.
  ///
  /// In es, this message translates to:
  /// **'Transacciones'**
  String get homeTabTransactions;

  /// No description provided for @homeTabSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get homeTabSettings;

  /// No description provided for @homeTabCoach.
  ///
  /// In es, this message translates to:
  /// **'Coach'**
  String get homeTabCoach;

  /// No description provided for @statsTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statsTitle;

  /// No description provided for @statsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin datos para mostrar'**
  String get statsEmpty;

  /// No description provided for @statsByCategory.
  ///
  /// In es, this message translates to:
  /// **'Por categoría'**
  String get statsByCategory;

  /// No description provided for @statsTrend.
  ///
  /// In es, this message translates to:
  /// **'Tendencia'**
  String get statsTrend;

  /// No description provided for @createEventTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Evento / Viaje'**
  String get createEventTitle;

  /// No description provided for @createEventName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Evento'**
  String get createEventName;

  /// No description provided for @createEventDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get createEventDescription;

  /// No description provided for @createEventBudget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get createEventBudget;

  /// No description provided for @createEventStart.
  ///
  /// In es, this message translates to:
  /// **'Fecha inicio'**
  String get createEventStart;

  /// No description provided for @createEventEnd.
  ///
  /// In es, this message translates to:
  /// **'Fecha fin'**
  String get createEventEnd;

  /// No description provided for @createEventSubmit.
  ///
  /// In es, this message translates to:
  /// **'Crear Evento'**
  String get createEventSubmit;

  /// No description provided for @addIncomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar Ingreso'**
  String get addIncomeTitle;

  /// No description provided for @addExpenseTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Gasto'**
  String get addExpenseTitle;

  /// No description provided for @createSavingTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva Meta de Ahorro'**
  String get createSavingTitle;

  /// No description provided for @createWorkspaceTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear Espacio'**
  String get createWorkspaceTitle;

  /// No description provided for @aiSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración AI'**
  String get aiSettingsTitle;

  /// No description provided for @membersTitle.
  ///
  /// In es, this message translates to:
  /// **'Miembros'**
  String get membersTitle;

  /// No description provided for @accountDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de Cuenta'**
  String get accountDetailTitle;

  /// No description provided for @currencySettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Moneda y Conversión'**
  String get currencySettingsTitle;

  /// No description provided for @loginEmailHint.
  ///
  /// In es, this message translates to:
  /// **'tu@correo.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get loginPasswordHint;

  /// No description provided for @registerNameHint.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get registerNameHint;

  /// No description provided for @transactionItemsTitle.
  ///
  /// In es, this message translates to:
  /// **'Artículos'**
  String get transactionItemsTitle;

  /// No description provided for @transactionItemsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay artículos'**
  String get transactionItemsEmpty;

  /// No description provided for @transactionItemEvolutionTitle.
  ///
  /// In es, this message translates to:
  /// **'Evolución de precio'**
  String get transactionItemEvolutionTitle;

  /// No description provided for @organizationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Organizaciones'**
  String get organizationsTitle;

  /// No description provided for @organizationsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes organizaciones todavía'**
  String get organizationsEmpty;

  /// No description provided for @organizationsNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva Organización'**
  String get organizationsNew;

  /// No description provided for @organizationsCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear Nueva Organización'**
  String get organizationsCreate;

  /// No description provided for @organizationsNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la organización'**
  String get organizationsNameLabel;

  /// No description provided for @organizationsInviteRevoke.
  ///
  /// In es, this message translates to:
  /// **'Revocar invitación'**
  String get organizationsInviteRevoke;

  /// No description provided for @organizationsConfirmRevoke.
  ///
  /// In es, this message translates to:
  /// **'¿Revocar la invitación a {email}?'**
  String organizationsConfirmRevoke(String email);

  /// No description provided for @organizationsInviteMember.
  ///
  /// In es, this message translates to:
  /// **'Invitar miembro'**
  String get organizationsInviteMember;

  /// No description provided for @organizationsRole.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get organizationsRole;

  /// No description provided for @workspacesTitle.
  ///
  /// In es, this message translates to:
  /// **'Espacios'**
  String get workspacesTitle;

  /// No description provided for @workspaceEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Espacio'**
  String get workspaceEditTitle;

  /// No description provided for @workspaceNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del espacio'**
  String get workspaceNameLabel;

  /// No description provided for @workspaceCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear espacio'**
  String get workspaceCreate;

  /// No description provided for @workspaceDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Espacio'**
  String get workspaceDelete;

  /// No description provided for @workspaceDeleteWarning.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer. Se perderán todos los datos financieros y configuraciones de IA asociadas.'**
  String get workspaceDeleteWarning;

  /// No description provided for @workspaceCurrency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get workspaceCurrency;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get settingsAccount;

  /// No description provided for @settingsPreferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get settingsPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsAi.
  ///
  /// In es, this message translates to:
  /// **'Configuración AI'**
  String get settingsAi;

  /// No description provided for @settingsSecurity.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get settingsSecurity;

  /// No description provided for @settingsLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get settingsLogout;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get profileEdit;

  /// No description provided for @securityTitle.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get securityTitle;

  /// No description provided for @securityPin.
  ///
  /// In es, this message translates to:
  /// **'PIN'**
  String get securityPin;

  /// No description provided for @securityBiometric.
  ///
  /// In es, this message translates to:
  /// **'Biometría'**
  String get securityBiometric;

  /// No description provided for @setupTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración inicial'**
  String get setupTitle;

  /// No description provided for @setupWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get setupWelcome;

  /// No description provided for @setupCreateFirst.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer espacio para empezar'**
  String get setupCreateFirst;

  /// No description provided for @authLoginTitle.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authLoginTitle;

  /// No description provided for @authLoginEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authLoginEmail;

  /// No description provided for @authLoginPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authLoginPassword;

  /// No description provided for @authLoginButton.
  ///
  /// In es, this message translates to:
  /// **'INGRESAR'**
  String get authLoginButton;

  /// No description provided for @authLoginForgot.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authLoginForgot;

  /// No description provided for @authLoginNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get authLoginNoAccount;

  /// No description provided for @authLoginRegister.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get authLoginRegister;

  /// No description provided for @authRegisterTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get authRegisterName;

  /// No description provided for @authRegisterButton.
  ///
  /// In es, this message translates to:
  /// **'REGISTRARSE'**
  String get authRegisterButton;

  /// No description provided for @authRegisterHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get authRegisterHaveAccount;

  /// No description provided for @authRegisterLogin.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get authRegisterLogin;

  /// No description provided for @authForgotTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar Contraseña'**
  String get authForgotTitle;

  /// No description provided for @authForgotHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.'**
  String get authForgotHint;

  /// No description provided for @authForgotButton.
  ///
  /// In es, this message translates to:
  /// **'ENVIAR ENLACE'**
  String get authForgotButton;

  /// No description provided for @authForgotSuccess.
  ///
  /// In es, this message translates to:
  /// **'Correo Enviado'**
  String get authForgotSuccess;

  /// No description provided for @authForgotSuccessBody.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu bandeja de entrada para restablecer tu contraseña.'**
  String get authForgotSuccessBody;

  /// No description provided for @authForgotError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el correo. Verifica que el email sea correcto.'**
  String get authForgotError;

  /// No description provided for @authForgotInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico inválido'**
  String get authForgotInvalidEmail;

  /// No description provided for @invitationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Invitaciones'**
  String get invitationsTitle;

  /// No description provided for @invitationsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes invitaciones pendientes.'**
  String get invitationsEmpty;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'es':
      return AppL10nEs();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
