import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click if needed
      },
    );

    // Request permissions for Android 13+
    if (Platform.isAndroid) {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!Platform.isAndroid) return;

    final tz.TZDateTime scheduledTZDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    // Only schedule if the date is in the future
    if (scheduledTZDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTZDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'contest_reminders',
          '比赛提醒',
          channelDescription: '提醒即将开始的比赛',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
