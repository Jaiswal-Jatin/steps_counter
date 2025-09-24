import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// A service class for handling local notifications.
///
/// This class is a singleton, ensuring a single instance across the app.
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Counter for simple, one-off notification IDs to ensure they are unique.
  int _simpleNotificationId = 0;

  /// Initializes the notification service.
  ///
  /// This method should be called once at app startup. It configures
  /// timezones, initializes the plugin for Android and iOS, and requests
  /// necessary permissions.
  Future<void> init() async {
    // 1. Initialize timezones
    await _configureLocalTimeZone();

    // 2. Initialize plugin for each platform
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // 3. Request permissions
    await _requestPermissions();
  }

  /// Requests notification permissions for the current platform.
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  /// Configures the local timezone for scheduling.
  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  /// Returns the platform-specific notification details.
  NotificationDetails _getNotificationDetails() {
    // Custom vibration pattern for Android
    final Int64List vibrationPattern = Int64List.fromList([0, 500, 200, 500]);

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'water_reminder_channel', // Channel ID
      'Water Reminders', // Channel Name
      channelDescription: 'Channel for water reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
    );

    // For iOS, `presentSound: true` enables the default sound.
    // Vibration is enabled by default if the device settings allow it.
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(presentSound: true);

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Schedules water reminders at a given interval within the 8 AM - 10 PM window.
  ///
  /// It cancels any existing reminders and schedules new ones for the next 2 days.
  Future<void> scheduleReminders(int intervalHours) async {
    // Cancel any previously scheduled reminders to avoid duplicates
    await cancelReminders();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    int notificationId = 100; // Use a specific ID range for water reminders

    // Schedule notifications for the next 2 days
    for (int day = 0; day < 2; day++) {
      // Iterate through the allowed hours (8 AM to 10 PM) with the given interval
      for (int hour = 8; hour < 22; hour += intervalHours) {
        final tz.TZDateTime scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + day,
          hour,
        );

        // Only schedule if the calculated time is in the future
        if (scheduledDate.isAfter(now)) {
          await _notificationsPlugin.zonedSchedule(
            notificationId++,
            'Time to Drink Water 💧',
            'Stay hydrated! It’s been $intervalHours ${intervalHours == 1 ? 'hour' : 'hours'}.',
            scheduledDate,
            _getNotificationDetails(),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
    }
  }

  /// Cancels all scheduled notifications.
  ///
  /// This is used when the user toggles the reminders off.
  Future<void> cancelReminders() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Shows a simple, one-off notification for events like milestones.
  ///
  /// This is a replacement for the old `simple()` method.
  Future<void> showSimpleNotification({
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      _simpleNotificationId++, // Use a unique, incrementing ID
      title,
      body,
      _getNotificationDetails(),
    );
  }
}