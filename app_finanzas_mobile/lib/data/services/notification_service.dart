import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const _coachNightlyId = 909001;

  Future<NotificationService> init() async {
    tz.initializeTimeZones();
    // Android init
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS init (skeleton)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    return this;
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id_finanzas',
          'Finanzas Notificaciones',
          channelDescription: 'Alertas de presupuesto y vencimientos',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF, // Unique ID
      title,
      body,
      details,
    );
  }

  /// Programa recordatorios recurrentes semanales para pagos
  Future<void> scheduleRecurringPaymentNotification(
    int day,
    String name,
    double amount,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'recurring_payments',
          'Pagos Recurrentes',
          channelDescription: 'Recordatorios de pagos recurrentes',
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    // ID estable basado en el nombre
    final id = name.hashCode & 0x7FFFFFFF;

    await flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      'Recordatorio de Pago',
      'Próximo pago: $name (\$${amount.toStringAsFixed(2)})',
      RepeatInterval.weekly,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancela una notificación programada
  Future<void> cancelNotification(String name) async {
    final id = name.hashCode & 0x7FFFFFFF;
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Schedules a daily reminder at 21:00 (local) prompting the user to log
  /// any expenses for the day. Idempotent — re-scheduling cancels prior.
  Future<void> scheduleCoachNightly({int hour = 21, int minute = 0}) async {
    await flutterLocalNotificationsPlugin.cancel(_coachNightlyId);

    const androidDetails = AndroidNotificationDetails(
      'coach_nightly',
      'Coach diario',
      channelDescription: 'Recordatorio nocturno del Coach Financiero',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      _coachNightlyId,
      '¿Cómo te fue hoy?',
      'Cuéntale a tu Coach Financiero lo que gastaste.',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'coach_nightly',
    );
  }

  Future<void> cancelCoachNightly() async {
    await flutterLocalNotificationsPlugin.cancel(_coachNightlyId);
  }
}
