import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:pedometer/pedometer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:steps_counter_app/src/services/notification_service.dart';

class AppState extends ChangeNotifier {
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  // Channel for native communication
  static const _platform = MethodChannel('com.example.steps_counter_app/background_service');

  // Steps and metrics
  int stepsToday = 0;
  int stepGoal = 10000;
  double get distanceKm => stepsToday * 0.00078; // ~0.78m/step
  int get calories => (stepsToday * 0.04).round(); // rough estimate
  int get activeMinutes => (stepsToday / 110).round();

  // Preferences
  bool darkMode = false;
  bool waterReminders = true;
  Duration waterInterval = const Duration(hours: 2);
  bool milestoneNotifications = true;

  // Analytics history: yyyy-MM-dd -> steps
  Map<String, int> _stepHistory = {};
  // Public getter for analytics screen
  Map<String, int> get stepHistory => Map.unmodifiable(_stepHistory);

  int _stepsAtStartOfDay = 0;
  StreamSubscription<StepCount>? _stepCountSubscription;

  String? userName;
  String? photoURL;
  DateTime? dob;

  // Services
  DateTime _today = _dateOnly(DateTime.now());
  final NotificationService _notifier = NotificationService();
  User? _user;
  DocumentReference? _userDoc;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    await _loadBasePrefs();
    FirebaseAuth.instance.authStateChanges().listen(_handleUserChange);
  }

  Future<void> _handleUserChange(User? user) async {
    _user = user;
    final sp = await SharedPreferences.getInstance();
    if (user != null) {
      _userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      // Save current user ID for the background service
      await sp.setString('current_user_id', user.uid);
      initialize();
    } else {
      // User logged out, reset state
      await sp.remove('current_user_id');
      _resetState();
    }
  }

  void _resetState() {
    _isInitializing = true;
    stepsToday = 0;
    stepGoal = 10000;
    darkMode = false;
    waterReminders = true;
    milestoneNotifications = true;
    waterInterval = const Duration(hours: 2);
    _stepHistory.clear();
    userName = null;
    photoURL = null;
    dob = null;
    _today = _dateOnly(DateTime.now());
    _user = null;
    _userDoc = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    super.dispose();
  }

  static DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);
  static String _keyForDay(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> initialize() async {
    if (_user == null) {
      _isInitializing = false;
      notifyListeners();
      return;
    }
    _isInitializing = true;
    notifyListeners();

    await _notifier.init();
    await _initHealthData();
    await _loadUserData();
    await _loadUserName();
    _ensureTodayEntrySaved();
    if (waterReminders) {
      _notifier.scheduleWaterReminders(every: waterInterval, enable: true);
    }
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> _loadBasePrefs() async {
    final sp = await SharedPreferences.getInstance();
    darkMode = sp.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> _initHealthData() async {
    if (Platform.isAndroid) {
      var status = await Permission.activityRecognition.status;
      if (status.isDenied) {
        // Request permission
        status = await Permission.activityRecognition.request();
      }

      // For Android 13+, also request notification permission for the foreground service
      var notificationStatus = await Permission.notification.status;
      if (notificationStatus.isDenied) {
        await Permission.notification.request();
      }

      if (status.isGranted) {
        // Start the native background service
        try {
          await _platform.invokeMethod('startService');
          if (kDebugMode) print("Started background step counter service.");
        } on PlatformException catch (e) {
          if (kDebugMode) print("Failed to start background service: '${e.message}'.");
        }
        _listenToStepCount();
      } else {
        // Handle case where user denies permissions
        if (kDebugMode) {
          print("Step counting permissions denied.");
        }
        return;
      }
    }
    // iOS implementation would go here

    HomeWidget.registerInteractivityCallback(_interactiveCallback);
  }

  void _listenToStepCount() {
    _stepCountSubscription?.cancel();
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );
  }

  void _onStepCount(StepCount event) async {
    final sp = await SharedPreferences.getInstance();
    final nowDay = _dateOnly(DateTime.now());

    if (nowDay.isAfter(_today)) {
      await _persistTodayToHistory();
      _today = nowDay;
      stepsToday = 0;
      _stepsAtStartOfDay = event.steps;
      if (_user != null) await sp.setInt('stepsAtStartOfDay_${_user!.uid}', _stepsAtStartOfDay);
    }

    if (_stepsAtStartOfDay == 0) {
      _stepsAtStartOfDay = event.steps - stepsToday;
    }

    final newStepsToday = event.steps - _stepsAtStartOfDay;

    if (newStepsToday >= 0 && newStepsToday != stepsToday) {
      stepsToday = newStepsToday;
      _updateSteps(stepsToday);
    }
  }

  void _onStepCountError(error) {
    if (kDebugMode) {
      print("Pedometer Error: $error");
    }
  }

  Future<void> _loadUserData() async {
    final currentUser = _user;
    if (currentUser == null || _userDoc == null) return;
    final uid = currentUser.uid;

    final sp = await SharedPreferences.getInstance();

    // Try loading from local storage first by checking for a key.
    // If stepGoal is present, we assume all other prefs are too.
    if (sp.containsKey('stepGoal_$uid')) {
      final todayString = sp.getString('todayDate_$uid');
      // Data exists locally, load from SharedPreferences
      darkMode = sp.getBool('darkMode_$uid') ?? false;
      waterReminders = sp.getBool('waterReminders_$uid') ?? true;
      milestoneNotifications = sp.getBool('milestoneNotifications_$uid') ?? true;
      stepGoal = sp.getInt('stepGoal_$uid') ?? 10000;
      final intervalMin = sp.getInt('waterIntervalMin_$uid') ?? 120;
      waterInterval = Duration(minutes: intervalMin);
      userName = sp.getString('userName_$uid');
      photoURL = sp.getString('photoURL_$uid');
      final dobString = sp.getString('dob_$uid');
      dob = (dobString != null) ? DateTime.tryParse(dobString) : null;
      _today = (todayString != null) ? _dateOnly(DateTime.parse(todayString)) : _dateOnly(DateTime.now());

      final historyJson = sp.getString('stepHistory_$uid');
      if (historyJson != null) {
        try {
          _stepHistory = Map<String, int>.from(json.decode(historyJson));
        } catch (e) {
          _stepHistory = {};
        }
      }
    } else {
      // Data not found locally, fetch from Firebase
      final snapshot = await _userDoc!.get();
      if (snapshot.exists) {
        _today = _dateOnly(DateTime.now());
        final data = snapshot.data() as Map<String, dynamic>;
        darkMode = data['darkMode'] ?? false;
        waterReminders = data['waterReminders'] ?? true;
        milestoneNotifications = data['milestoneNotifications'] ?? true;
        stepGoal = data['stepGoal'] as int? ?? 10000;
        final intervalMin = data['waterIntervalMin'] ?? 120;
        waterInterval = Duration(minutes: intervalMin);
        userName = data['name'] as String?;
        photoURL = data['photoURL'] as String?;
        final dobTimestamp = data['dob'] as Timestamp?;
        dob = dobTimestamp?.toDate();

        final historySnapshot =
            await _userDoc!.collection('step_history').get();
        _stepHistory = {
          for (var doc in historySnapshot.docs)
            doc.id: doc.data()['steps'] as int
        };

        // Save fetched data to local storage for next time
        await _saveUserData();
      } else {
        // First time user, create document with defaults and save locally
        await _saveUserData();
      }
    }

    stepsToday = sp.getInt('stepsToday_$uid') ?? 0;
    _stepsAtStartOfDay = sp.getInt('stepsAtStartOfDay_$uid') ?? 0;

    notifyListeners();
  }

  Future<void> _loadUserName() async {
    // Refresh user to get latest profile data
    await _user?.reload();
    _user = FirebaseAuth.instance.currentUser;
    userName ??= _user?.displayName ?? 'Guest User';
    photoURL ??= _user?.photoURL;
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    if (_user == null || _userDoc == null) return;

    // Save preferences to local storage for faster startup
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('darkMode_${_user!.uid}', darkMode);
    await sp.setBool('waterReminders_${_user!.uid}', waterReminders);
    await sp.setBool('milestoneNotifications_${_user!.uid}', milestoneNotifications);
    await sp.setInt('waterIntervalMin_${_user!.uid}', waterInterval.inMinutes);
    await sp.setInt('stepGoal_${_user!.uid}', stepGoal);
    if (userName != null) await sp.setString('userName_${_user!.uid}', userName!);
    if (photoURL != null) await sp.setString('photoURL_${_user!.uid}', photoURL!);
    if (dob != null) await sp.setString('dob_${_user!.uid}', dob!.toIso8601String());
    await sp.setString('todayDate_${_user!.uid}', _today.toIso8601String());

    // Save preferences to Firebase
    await _userDoc!.set({
      'darkMode': darkMode,
      'waterReminders': waterReminders,
      'milestoneNotifications': milestoneNotifications,
      'waterIntervalMin': waterInterval.inMinutes,
      'stepGoal': stepGoal,
      'name': userName,
      'photoURL': photoURL,
      'dob': dob,
    }, SetOptions(merge: true));
  }

  Future<void> _updateSteps(int steps) async {
    stepsToday = steps;
    notifyListeners();
    _maybeMilestoneNotifications();
    final sp = await SharedPreferences.getInstance();
    if (_user != null) await sp.setInt('stepsToday_${_user!.uid}', stepsToday);
    await HomeWidget.saveWidgetData<int>('steps', steps);
    await HomeWidget.updateWidget(
      name: 'StepsWidgetProvider',
      androidName: 'StepsWidgetProvider',
    );
  }

  Future<void> _persistTodayToHistory() async {
    if (_user == null || _userDoc == null) return;
    final dayKey = _keyForDay(_today);
    _stepHistory[dayKey] = stepsToday;

    // Persist history map to local storage
    final sp = await SharedPreferences.getInstance();
    await sp.setString('stepHistory_${_user!.uid}', json.encode(_stepHistory));

    // Persist the completed day's steps to Firebase
    await _userDoc!.collection('step_history').doc(dayKey).set({
      'steps': stepsToday,
      'distanceKm': distanceKm,
      'calories': calories,
      'activeMinutes': activeMinutes,
    });
  }

  void _ensureTodayEntrySaved() async {
    if (_user == null || _userDoc == null) return;
    final dayKey = _keyForDay(_today);
    _stepHistory[dayKey] = stepsToday;

    // Persist history map to local storage
    final sp = await SharedPreferences.getInstance();
    await sp.setString('stepHistory_${_user!.uid}', json.encode(_stepHistory));

    // Also update today's steps in Firebase. Use merge to be safe.
    await _userDoc!.collection('step_history').doc(dayKey).set({
      'steps': stepsToday,
      'distanceKm': distanceKm,
      'calories': calories,
      'activeMinutes': activeMinutes,
    }, SetOptions(merge: true));
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

  Future<Map<String, dynamic>?> getWaterForDay(DateTime date) async {
    if (_userDoc == null) return null;
    final key = 'water-${_keyForDay(date)}';
    final doc = await _userDoc!.collection('water_history').doc(key).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // Notifications for milestones (1k steps, 25/50/75%)
  int _lastThousandNotified = 0;
  int _lastProgressBucket = 0;

  void _maybeMilestoneNotifications() {
    if (!milestoneNotifications) return;
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
  Future<void> setDarkMode(bool v) async {
    if (darkMode == v) return;
    darkMode = v;
    notifyListeners();
    await _saveUserData(); // Persist change
  }

  Future<void> setMilestoneNotifications(bool v) async {
    if (milestoneNotifications == v) return;
    milestoneNotifications = v;
    notifyListeners();
    await _saveUserData(); // Persist change
  }

  Future<void> setWaterReminders(bool v) async {
    if (waterReminders == v) return;
    waterReminders = v;
    _notifier.scheduleWaterReminders(every: waterInterval, enable: v);
    notifyListeners();
    await _saveUserData(); // Persist change
  }

  Future<void> setWaterInterval(Duration d) async {
    if (waterInterval == d) return;
    waterInterval = d;
    if (waterReminders) _notifier.scheduleWaterReminders(every: d, enable: true);
    notifyListeners();
    await _saveUserData(); // Persist change
  }

  Future<void> setStepGoal(int v) async {
    if (stepGoal == v) return;
    stepGoal = v;
    notifyListeners();
    await _saveUserData(); // Persist change
  }

  Future<void> updateProfile({String? newName, DateTime? newDob}) async {
    bool changed = false;
    if (newName != null) {
      userName = newName;
      await _user?.updateDisplayName(newName);
      changed = true;
    }
    if (newDob != null) {
      dob = newDob;
      changed = true;
    }
    if (changed) {
      await _saveUserData();
      notifyListeners();
    }
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    final currentUser = _user;
    if (currentUser == null) return null;
    final ref = FirebaseStorage.instance.ref().child('profile_pictures').child('${currentUser.uid}.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    photoURL = downloadUrl;
    await _user?.updatePhotoURL(downloadUrl);
    await _saveUserData();
    notifyListeners();
    return downloadUrl;
  }

  // Called when the widget is clicked
  static Future<void> _interactiveCallback(Uri? uri) async {
    // For now, this is just a placeholder.
    // You could use this to trigger specific actions in the app.
  }
}
