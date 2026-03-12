import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final _instance = NotificationService._();
  factory NotificationService() => _instance;

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS:     iosSettings,
    );

    await _plugin.initialize(initSettings);

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  Future<void> showBudgetAlert({
    required String categoryName,
    required double spent,
    required double limit,
    required bool   isOverspent,
  }) async {
    final percent = ((spent / limit) * 100).toStringAsFixed(0);

    const androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Alerts when you approach budget limits',
      importance: Importance.high,
      priority:   Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS:     iosDetails,
    );

    await _plugin.show(
      categoryName.hashCode,
      isOverspent
          ? '⚠️ Budget Exceeded! — $categoryName'
          : '🔔 Budget Alert — $categoryName',
      isOverspent
          ? 'You spent ৳${spent.toStringAsFixed(0)} '
          '($percent%) of your ৳${limit.toStringAsFixed(0)} limit.'
          : 'You used $percent% of your '
          '৳${limit.toStringAsFixed(0)} $categoryName budget.',
      details,
    );
  }

  Future<void> scheduleBillReminder({
    required int      id,
    required String   title,
    required String   body,
    required DateTime scheduledDate,
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'bill_reminders',
      'Bill Reminders',
      channelDescription: 'Scheduled bill payment reminders',
      importance: Importance.high,
      priority:   Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS:     iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      '📅 Bill Reminder — $title',
      body,
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> cancelNotification(int id) async =>
      _plugin.cancel(id);

  Future<void> cancelAll() async =>
      _plugin.cancelAll();
}