import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const init = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(init);

    // Request platform-specific notification permissions
    await requestPlatformPermissions();

    _initialized = true;
  }

  Future<void> requestPlatformPermissions() async {
    // Android 13+ notifications permission
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> simple(String title, String body) async {
/*************  ✨ Windsurf Command ⭐  *************/
  /// Shows a basic notification with the given [title] and [body].
  ///
  /// The notification has a high importance and priority on Android, and is
  /// shown immediately.
/*******  30f54668-43c1-4017-9da7-1a22e4afb761  *******/    const details = NotificationDetails(
      android: AndroidNotificationDetails('stepgo_basic', 'Basic',
          importance: Importance.high, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }

  Future<void> scheduleWaterReminders({required Duration every, required bool enable}) async {
    await _plugin.cancel(1001);
    if (!enable) return;
    // Schedule a repeating notification (Android) or multiple next alarms.
    const details = NotificationDetails(
      android: AndroidNotificationDetails('stepgo_water', 'Water Reminders',
          importance: Importance.defaultImportance, priority: Priority.defaultPriority),
      iOS: DarwinNotificationDetails(),
    );
    // Next 12 hours reminders (works cross-platform reliably)
    final now = tz.TZDateTime.now(tz.local);
    const scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
    for (int i = 1; i <= 6; i++) {
      final id = 1001 + i;
      final time = now.add(every * i);
      await _plugin.zonedSchedule(
        id,
        'Hydrate',
        'Time to drink some water.',
        tz.TZDateTime.from(time, tz.local),
        details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'water',
      );
    }
  }
}
