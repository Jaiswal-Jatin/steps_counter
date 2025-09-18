import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:steps_counter_app/src/models/water_entry.dart';
import 'package:steps_counter_app/src/services/notification_service.dart';

class AppState extends ChangeNotifier {
  // Steps and metrics
  int stepsToday = 0;
  int stepGoal = 10000;
  double get distanceKm => stepsToday * 0.00078; // ~0.78m/step
  int get calories => (stepsToday * 0.04).round(); // rough estimate
  int get activeMinutes => (stepsToday / 110).round();

  // Water
  int waterMlToday = 0;
  List<WaterEntry> waterEntries = [];

  // Preferences
  bool darkMode = false;
  bool vibrate = true;
  bool batterySaver = false;
  bool waterReminders = true;
  Duration waterInterval = const Duration(hours: 2);

  // Analytics history: yyyy-MM-dd -> steps
  Map<String, int> _stepHistory = {};

  String? userName;

  // Pedometer state
  StreamSubscription<StepCount>? _sub;
  int? _baseline; // device cumulative steps at the start of today
  DateTime _today = _dateOnly(DateTime.now());

  final NotificationService _notifier = NotificationService();

  static DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);
  static String _keyForDay(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> initialize() async {
    await _notifier.init();
    await _ensurePermissions();
    await _loadPrefs();
    await _loadUserName();
    await _startPedometer();
    _restoreWater();
    _ensureTodayEntrySaved();
    if (waterReminders) {
      _notifier.scheduleWaterReminders(every: waterInterval, enable: true);
    }
  }

  Future<void> _ensurePermissions() async {
    if (Platform.isAndroid) {
      // Request physical activity permission for step counting
      final status = await Permission.activityRecognition.request();
      if (!status.isGranted) {
        // Permission denied; pedometer stream may not emit values.
      }
    }
    // Notifications permissions are requested inside NotificationService.init()
  }

  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    darkMode = sp.getBool('darkMode') ?? false;
    vibrate = sp.getBool('vibrate') ?? true;
    batterySaver = sp.getBool('batterySaver') ?? false;
    waterReminders = sp.getBool('waterReminders') ?? true;
    stepGoal = sp.getInt('stepGoal') ?? 10000;

    final intervalMin = sp.getInt('waterIntervalMin') ?? 120;
    waterInterval = Duration(minutes: intervalMin);

    // Steps
    stepsToday = sp.getInt('stepsToday') ?? 0;
    _baseline = sp.getInt('baseline');
    final histStr = sp.getString('stepHistory');
    if (histStr != null && histStr.isNotEmpty) {
      _stepHistory = Map<String, int>.from(json.decode(histStr) as Map);
    }
    notifyListeners();
  }



  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    userName = user?.displayName ?? 'Guest User';
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('darkMode', darkMode);
    await sp.setBool('vibrate', vibrate);
    await sp.setBool('batterySaver', batterySaver);
    await sp.setBool('waterReminders', waterReminders);
    await sp.setInt('waterIntervalMin', waterInterval.inMinutes);
    await sp.setInt('stepGoal', stepGoal);
  }

  Future<void> _startPedometer() async {
    _sub?.cancel();
    _sub = Pedometer.stepCountStream.listen((event) {
      _onStepEvent(event.steps);
    }, onError: (e) {
      // If permission missing or sensor unavailable, keep zero.
    });
  }

  void _onStepEvent(int deviceCumulative) async {
    final nowDay = _dateOnly(DateTime.now());
    if (nowDay.isAfter(_today)) {
      // New day rollover.
      await _persistTodayToHistory();
      _today = nowDay;
      stepsToday = 0;
      _baseline = deviceCumulative;
      final sp = await SharedPreferences.getInstance();
      await sp.setInt('baseline', _baseline!);
      await sp.setInt('stepsToday', stepsToday);
    }
    _baseline ??= deviceCumulative - stepsToday;
    final newToday = deviceCumulative - (_baseline ?? 0);
    if (newToday != stepsToday && newToday >= 0) {
      stepsToday = newToday;
      final sp = await SharedPreferences.getInstance();
      await sp.setInt('stepsToday', stepsToday);
      notifyListeners();
      _maybeMilestoneNotifications();
    }
  }

  Future<void> _persistTodayToHistory() async {
    _stepHistory[_keyForDay(_today)] = stepsToday;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('stepHistory', json.encode(_stepHistory));
  }

  void _ensureTodayEntrySaved() async {
    final sp = await SharedPreferences.getInstance();
    _stepHistory[_keyForDay(_today)] = stepsToday;
    await sp.setString('stepHistory', json.encode(_stepHistory));
  }

  Map<DateTime, int> historyDays({int backDays = 30}) {
    final now = DateTime.now();
    final map = <DateTime, int>{};
    for (int i = backDays - 1; i >= 0; i--) {
      final d = _dateOnly(now.subtract(Duration(days: i)));
      map[d] = _stepHistory[_keyForDay(d)] ?? 0;
    }
    return map;
  }

  // Notifications for milestones (1k steps, 25/50/75%)
  int _lastThousandNotified = 0;
  int _lastProgressBucket = 0;

  void _maybeMilestoneNotifications() {
    final thousand = (stepsToday ~/ 1000);
    if (thousand > _lastThousandNotified && thousand > 0) {
      _notifier.simple('Milestone', 'You reached ${thousand * 1000} steps!');
      _lastThousandNotified = thousand;
    }
    final progress = ((stepsToday / stepGoal) * 100).clamp(0, 100).round();
    int bucket = 0;
    if (progress >= 75) bucket = 75;
    else if (progress >= 50) bucket = 50;
    else if (progress >= 25) bucket = 25;
    if (bucket > _lastProgressBucket) {
      _notifier.simple('Great progress', '$bucket% of your daily goal done.');
      _lastProgressBucket = bucket;
    }
  }

  // Preferences setters
  Future<void> setDarkMode(bool v) async { darkMode = v; await _savePrefs(); notifyListeners(); }
  Future<void> setVibrate(bool v) async { vibrate = v; await _savePrefs(); }
  Future<void> setBatterySaver(bool v) async { batterySaver = v; await _savePrefs(); }
  Future<void> setWaterReminders(bool v) async {
    waterReminders = v; await _savePrefs();
    _notifier.scheduleWaterReminders(every: waterInterval, enable: v);
    notifyListeners();
  }
  Future<void> setWaterInterval(Duration d) async {
    waterInterval = d; await _savePrefs();
    if (waterReminders) _notifier.scheduleWaterReminders(every: d, enable: true);
    notifyListeners();
  }
  Future<void> setStepGoal(int v) async { stepGoal = v; await _savePrefs(); notifyListeners(); }

  // Water
  Future<void> addWater(int ml) async {
    final now = DateTime.now();
    final entry = WaterEntry(at: now, ml: ml);
    waterEntries.insert(0, entry);
    waterMlToday += ml;
    await _persistWater();
    notifyListeners();
  }

  void _restoreWater() async {
    final sp = await SharedPreferences.getInstance();
    final key = 'water-${_keyForDay(_today)}';
    final s = sp.getString(key);
    if (s != null) {
      final data = (json.decode(s) as Map).cast<String, dynamic>();
      waterMlToday = data['total'] as int? ?? 0;
      final list = (data['entries'] as List?) ?? [];
      waterEntries = list.map((e) => WaterEntry.fromJson(Map<String, dynamic>.from(e))).toList();
      notifyListeners();
    }
  }

  Future<void> _persistWater() async {
    final sp = await SharedPreferences.getInstance();
    final key = 'water-${_keyForDay(_today)}';
    final payload = json.encode({
      'total': waterMlToday,
      'entries': waterEntries.map((e) => e.toJson()).toList(),
    });
    await sp.setString(key, payload);
  }

  Map<int, int> waterByHour() {
    final map = <int, int>{}; // hour -> ml
    for (final e in waterEntries) {
      final h = e.at.hour;
      map[h] = (map[h] ?? 0) + e.ml;
    }
    return map;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
