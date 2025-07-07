import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> showGoalAchievedNotification(int steps) async {
    const androidDetails = AndroidNotificationDetails(
      'goal_achieved',
      'Goal Achieved',
      channelDescription: 'Notifications for daily goal achievements',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'Goal Achieved! 🎉',
      'Congratulations! You\'ve reached your daily goal of $steps steps.',
      details,
    );
  }

  static Future<void> showProgressNotification(int steps, int goal) async {
    final progress = (steps / goal * 100).round();
    const androidDetails = AndroidNotificationDetails(
      'progress_update',
      'Progress Update',
      channelDescription: 'Notifications for step progress updates',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      'Step Progress',
      '$steps steps ($progress% of goal)',
      details,
    );
  }

  static Future<void> showWaterReminderNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'water_reminder',
      'Water Reminder',
      channelDescription: 'Reminders to drink water',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3,
      'Stay Hydrated! 💧',
      'Time to drink some water to stay healthy.',
      details,
    );
  }

  static Future<void> scheduleWaterReminders() async {
    // Schedule water reminders every 2 hours during the day
    const androidDetails = AndroidNotificationDetails(
      'water_reminder_scheduled',
      'Water Reminder Scheduled',
      channelDescription: 'Scheduled water reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule for 10 AM
    await _notifications.zonedSchedule(
      10,
      'Stay Hydrated! 💧',
      'Time to drink some water to stay healthy.',
      _nextInstanceOf(10, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Schedule for 2 PM
    await _notifications.zonedSchedule(
      14,
      'Stay Hydrated! 💧',
      'Time to drink some water to stay healthy.',
      _nextInstanceOf(14, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Schedule for 6 PM
    await _notifications.zonedSchedule(
      18,
      'Stay Hydrated! 💧',
      'Time to drink some water to stay healthy.',
      _nextInstanceOf(18, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
