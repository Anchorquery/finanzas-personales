// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppL10nEs extends AppL10n {
  AppL10nEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Finanzas Personales';

  @override
  String get aiCoachTitle => 'Coach Financiero';

  @override
  String get aiCoachSubtitle => 'Asistente con IA';

  @override
  String get aiCoachWelcome =>
      '¡Hola! Soy tu **Coach Financiero** 💡\n\nTengo acceso a tus datos y puedo analizar gastos, optimizar presupuestos, planificar el pago de deudas, registrar movimientos y abrir vistas por ti. ¿En qué te ayudo hoy?';

  @override
  String get aiCoachReadyTitle => 'Coach Financiero\nlisto para ayudarte';

  @override
  String get aiCoachConnectGemini =>
      'Conecta tu API key de Google Gemini para activar el asistente. Gratis y en 1 minuto.';

  @override
  String get aiCoachInsightsHeader => '🔎 **Lo que detecté en tus datos:**';

  @override
  String get aiCoachInsightBudgetsExceeded =>
      'Tienes presupuestos **excedidos** este mes. Pregunta cuáles.';

  @override
  String get aiCoachInsightBudgetsAtRisk =>
      'Hay presupuestos **en riesgo** (≥80% gastado).';

  @override
  String get aiCoachInsightDebtsActive =>
      'Tienes **deudas activas**. ¿Quieres un plan de pago?';

  @override
  String aiCoachInsightSaveRateNegative(String rate) {
    return 'Estás **gastando más de lo que ingresas** este mes ($rate%).';
  }

  @override
  String aiCoachInsightSaveRateLow(String rate) {
    return 'Tu tasa de ahorro es baja ($rate%). Meta saludable: ≥20%.';
  }

  @override
  String get aiCoachErrorApiKey =>
      '🔑 **API key inválida**. Ve a Ajustes > Configuración AI.';

  @override
  String get aiCoachErrorQuota =>
      '⏳ **Cuota agotada**. Espera unos minutos e intenta de nuevo.';

  @override
  String get aiCoachErrorSafety =>
      '🛡️ Respuesta bloqueada por filtros de seguridad. Reformula tu pregunta.';

  @override
  String get aiCoachErrorTimeout =>
      '⏱️ La respuesta tardó demasiado. Verifica tu conexión e intenta de nuevo.';

  @override
  String get aiCoachErrorGeneric =>
      '❌ Error al obtener respuesta. Intenta de nuevo.';

  @override
  String get aiCoachErrorMaxIterations =>
      '⚠️ Alcancé el límite de pasos del análisis. Intenta con una pregunta más específica.';

  @override
  String get aiCoachErrorNoApi =>
      '⚠️ No tengo configurada la API de Gemini.\nVe a **Ajustes > Configuración AI** para agregar tu API key.';

  @override
  String get aiCoachContextRefreshed =>
      '✅ Contexto actualizado con los datos más recientes.';

  @override
  String get aiCoachNoWorkspace => 'No hay workspace activo.';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonApprove => 'Aprobar';

  @override
  String get commonReject => 'Rechazar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonAdd => 'Agregar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonRequired => 'Requerido';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Éxito';

  @override
  String get errorRequired => 'Campo requerido';

  @override
  String get errorInvalidEmail => 'Correo inválido';

  @override
  String get errorAmountInvalid => 'Monto inválido';

  @override
  String get errorAmountPositive => 'Debe ser mayor que cero';

  @override
  String get errorPasswordShort => 'Contraseña muy corta';

  @override
  String get debtsTitle => 'Mis Deudas';

  @override
  String get debtsEmpty => 'No hay deudas registradas.';

  @override
  String get debtsAddNew => 'Nueva Deuda';

  @override
  String get debtsTotalAmount => 'Monto Total';

  @override
  String get debtsInterest => 'Interés (%)';

  @override
  String get debtsDueDate => 'Fecha de vencimiento';

  @override
  String get debtsRegister => 'REGISTRAR DEUDA';

  @override
  String get debtsNameLabel => 'Nombre de la deuda';

  @override
  String get debtsGeneralInfo => 'Información General';

  @override
  String get savingsTitle => 'Mis Ahorros';

  @override
  String get savingsActiveGoals => 'METAS ACTIVAS';

  @override
  String savingsGoalsCount(int count) {
    return '$count Metas';
  }

  @override
  String get savingsCreateGoal => 'Crear meta';

  @override
  String get savingsGoalName => 'Nombre de la meta';

  @override
  String get savingsTargetAmount => 'Monto objetivo';

  @override
  String get savingsTargetDate => 'Fecha objetivo';

  @override
  String get savingsTotalSaved => 'Total ahorrado';

  @override
  String get savingsAddFunds => 'Aportar';

  @override
  String get savingsWithdrawFunds => 'Retirar';

  @override
  String get budgetsTitle => 'Mis Presupuestos';

  @override
  String get budgetsEmptyTitle => 'Control total de tus finanzas';

  @override
  String get budgetsEmptyBody =>
      'Define límites mensuales por categoría para evitar gastos innecesarios y alcanzar tus metas de ahorro más rápido.';

  @override
  String get budgetsCreate => 'Crear presupuesto';

  @override
  String get budgetsLimit => 'Límite';

  @override
  String get budgetsCategory => 'Categoría';

  @override
  String get subscriptionsTitle => 'Suscripciones';

  @override
  String get subscriptionsEmpty =>
      'No se encontraron suscripciones.\nAgrega una manualmente.';

  @override
  String get subscriptionsAdd => 'Agregar Suscripción';

  @override
  String get subscriptionsCancelled => 'Cancelada';

  @override
  String get subscriptionsName => 'Nombre';

  @override
  String get subscriptionsAmount => 'Monto Mensual';

  @override
  String get subscriptionsDay => 'Día de cobro (1-31)';

  @override
  String get subscriptionsRegisterPayment => 'Registrar pago';

  @override
  String get recurringTitle => 'Pagos Recurrentes';

  @override
  String get recurringEmpty => 'No hay suscripciones activas.';

  @override
  String get recurringManage => 'Gestionar suscripciones';

  @override
  String recurringDueIn(int days, int day) {
    return 'Vence en $days días (Día $day)';
  }

  @override
  String get recurringConfirmPay => 'Confirmar Pago';

  @override
  String recurringPayPrompt(String name, String amount) {
    return '¿Registrar pago de $name por \$$amount?';
  }

  @override
  String get transactionsTitle => 'Transacciones';

  @override
  String get transactionsEmpty => 'Sin transacciones en este período';

  @override
  String get transactionsAdd => 'Nueva transacción';

  @override
  String get transactionsConcept => 'Concepto';

  @override
  String get transactionsAmount => 'Monto';

  @override
  String get transactionsCategory => 'Categoría';

  @override
  String get transactionsDate => 'Fecha';

  @override
  String get transactionsTypeIncome => 'Ingreso';

  @override
  String get transactionsTypeExpense => 'Gasto';

  @override
  String get incomesTitle => 'Mis Ingresos';

  @override
  String get incomesEmpty => 'No hay ingresos registrados.';

  @override
  String get incomesAdd => 'Agregar ingreso';

  @override
  String get incomesSource => 'Fuente';

  @override
  String get incomesAmount => 'Monto';

  @override
  String get incomesPlanned => 'Planificados';

  @override
  String get incomesActual => 'Recibidos';

  @override
  String get expensesTitle => 'Mis Gastos';

  @override
  String get expensesEmpty => 'No hay gastos registrados.';

  @override
  String get expensesAdd => 'Nuevo gasto';

  @override
  String get eventsTitle => 'Eventos';

  @override
  String get eventsEmpty => 'No hay eventos programados.';

  @override
  String get eventsAdd => 'Nuevo evento';

  @override
  String get accountsTitle => 'Cuentas';

  @override
  String get accountsEmpty => 'No hay cuentas.';

  @override
  String get accountsBalance => 'Saldo';

  @override
  String get accountsCreate => 'Crear cuenta';

  @override
  String get scanReceiptTitle => 'Escanear recibo';

  @override
  String get scanReceiptUpload => 'Subir archivo';

  @override
  String get scanReceiptCapture => 'Tomar foto';

  @override
  String get scanReceiptGallery => 'Galería';

  @override
  String get scanReceiptProcessing => 'Procesando…';

  @override
  String get scanReceiptAnalyzed => 'Analizado';

  @override
  String get scanReceiptFailed => 'Falló';

  @override
  String get scanReceiptRecentUploads => 'Subidas recientes';

  @override
  String get homeTabDashboard => 'Dashboard';

  @override
  String get homeTabTransactions => 'Transacciones';

  @override
  String get homeTabSettings => 'Ajustes';

  @override
  String get homeTabCoach => 'Coach';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsEmpty => 'Sin datos para mostrar';

  @override
  String get statsByCategory => 'Por categoría';

  @override
  String get statsTrend => 'Tendencia';

  @override
  String get createEventTitle => 'Nuevo Evento / Viaje';

  @override
  String get createEventName => 'Nombre del Evento';

  @override
  String get createEventDescription => 'Descripción';

  @override
  String get createEventBudget => 'Presupuesto';

  @override
  String get createEventStart => 'Fecha inicio';

  @override
  String get createEventEnd => 'Fecha fin';

  @override
  String get createEventSubmit => 'Crear Evento';

  @override
  String get addIncomeTitle => 'Registrar Ingreso';

  @override
  String get addExpenseTitle => 'Nuevo Gasto';

  @override
  String get createSavingTitle => 'Nueva Meta de Ahorro';

  @override
  String get createWorkspaceTitle => 'Crear Espacio';

  @override
  String get aiSettingsTitle => 'Configuración AI';

  @override
  String get membersTitle => 'Miembros';

  @override
  String get accountDetailTitle => 'Detalle de Cuenta';

  @override
  String get currencySettingsTitle => 'Moneda y Conversión';

  @override
  String get loginEmailHint => 'tu@correo.com';

  @override
  String get loginPasswordHint => 'Mínimo 8 caracteres';

  @override
  String get registerNameHint => 'Tu nombre';

  @override
  String get transactionItemsTitle => 'Artículos';

  @override
  String get transactionItemsEmpty => 'No hay artículos';

  @override
  String get transactionItemEvolutionTitle => 'Evolución de precio';

  @override
  String get organizationsTitle => 'Organizaciones';

  @override
  String get organizationsEmpty => 'No tienes organizaciones todavía';

  @override
  String get organizationsNew => 'Nueva Organización';

  @override
  String get organizationsCreate => 'Crear Nueva Organización';

  @override
  String get organizationsNameLabel => 'Nombre de la organización';

  @override
  String get organizationsInviteRevoke => 'Revocar invitación';

  @override
  String organizationsConfirmRevoke(String email) {
    return '¿Revocar la invitación a $email?';
  }

  @override
  String get organizationsInviteMember => 'Invitar miembro';

  @override
  String get organizationsRole => 'Rol';

  @override
  String get workspacesTitle => 'Espacios';

  @override
  String get workspaceEditTitle => 'Editar Espacio';

  @override
  String get workspaceNameLabel => 'Nombre del espacio';

  @override
  String get workspaceCreate => 'Crear espacio';

  @override
  String get workspaceDelete => 'Eliminar Espacio';

  @override
  String get workspaceDeleteWarning =>
      'Esta acción no se puede deshacer. Se perderán todos los datos financieros y configuraciones de IA asociadas.';

  @override
  String get workspaceCurrency => 'Moneda';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsPreferences => 'Preferencias';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsAi => 'Configuración AI';

  @override
  String get settingsSecurity => 'Seguridad';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get securityTitle => 'Seguridad';

  @override
  String get securityPin => 'PIN';

  @override
  String get securityBiometric => 'Biometría';

  @override
  String get setupTitle => 'Configuración inicial';

  @override
  String get setupWelcome => 'Bienvenido';

  @override
  String get setupCreateFirst => 'Crea tu primer espacio para empezar';

  @override
  String get authLoginTitle => 'Iniciar sesión';

  @override
  String get authLoginEmail => 'Correo electrónico';

  @override
  String get authLoginPassword => 'Contraseña';

  @override
  String get authLoginButton => 'INGRESAR';

  @override
  String get authLoginForgot => '¿Olvidaste tu contraseña?';

  @override
  String get authLoginNoAccount => '¿No tienes cuenta?';

  @override
  String get authLoginRegister => 'Regístrate';

  @override
  String get authRegisterTitle => 'Crear cuenta';

  @override
  String get authRegisterName => 'Nombre';

  @override
  String get authRegisterButton => 'REGISTRARSE';

  @override
  String get authRegisterHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get authRegisterLogin => 'Inicia sesión';

  @override
  String get authForgotTitle => 'Recuperar Contraseña';

  @override
  String get authForgotHint =>
      'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get authForgotButton => 'ENVIAR ENLACE';

  @override
  String get authForgotSuccess => 'Correo Enviado';

  @override
  String get authForgotSuccessBody =>
      'Revisa tu bandeja de entrada para restablecer tu contraseña.';

  @override
  String get authForgotError =>
      'No se pudo enviar el correo. Verifica que el email sea correcto.';

  @override
  String get authForgotInvalidEmail => 'Correo electrónico inválido';

  @override
  String get invitationsTitle => 'Invitaciones';

  @override
  String get invitationsEmpty => 'No tienes invitaciones pendientes.';
}
