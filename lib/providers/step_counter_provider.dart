import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../models/step_data.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class StepCounterProvider with ChangeNotifier {
  static const String _dailyGoalKey = 'daily_step_goal';
  static const String _lastDateKey = 'last_date';
  static const String _todayStepsKey = 'today_steps';

  // Current data
  int _currentSteps = 0;
  int _dailyGoal = 6000;
  double _caloriesBurned = 0.0;
  double _distanceWalked = 0.0;
  Duration _activeTime = Duration.zero;

  // Historical data
  List<StepData> _weeklyData = [];
  List<StepData> _monthlyData = [];

  // Streams
  StreamSubscription<StepCount>? _stepCountStream;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;

  // Status
  bool _isWalking = false;
  bool _isInitialized = false;
  String _lastUpdateDate = '';

  // Getters
  int get currentSteps => _currentSteps;
  int get dailyGoal => _dailyGoal;
  double get caloriesBurned => _caloriesBurned;
  double get distanceWalked => _distanceWalked;
  Duration get activeTime => _activeTime;
  List<StepData> get weeklyData => _weeklyData;
  List<StepData> get monthlyData => _monthlyData;
  bool get isWalking => _isWalking;
  bool get isInitialized => _isInitialized;

  double get goalProgress =>
      _dailyGoal > 0 ? (_currentSteps / _dailyGoal).clamp(0.0, 1.0) : 0.0;
  bool get goalAchieved => _currentSteps >= _dailyGoal;

  // Additional computed properties
  double get currentDistance => _distanceWalked;
  int get currentCalories => _caloriesBurned.round();

  Future<void> initialize() async {
    try {
      await _requestPermissions();
      await _loadStoredData();
      await _initializePedometer();
      await _loadHistoricalData();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing step counter: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.activityRecognition.request();
    if (status != PermissionStatus.granted) {
      debugPrint('Activity recognition permission not granted');
    }
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyGoal = prefs.getInt(_dailyGoalKey) ?? 6000;
    _lastUpdateDate = prefs.getString(_lastDateKey) ?? '';

    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_lastUpdateDate != today) {
      // New day, reset steps
      _currentSteps = 0;
      await prefs.setString(_lastDateKey, today);
      await prefs.setInt(_todayStepsKey, 0);
    } else {
      _currentSteps = prefs.getInt(_todayStepsKey) ?? 0;
    }

    _calculateDerivedValues();
  }

  Future<void> _initializePedometer() async {
    try {
      _stepCountStream = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );

      _pedestrianStatusStream = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
      );
    } catch (e) {
      debugPrint('Error initializing pedometer: $e');
    }
  }

  void _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (_lastUpdateDate != today) {
      // New day detected
      await _saveCurrentDayData();
      _currentSteps = 0;
      _lastUpdateDate = today;
      await prefs.setString(_lastDateKey, today);
    }

    final previousSteps = _currentSteps;
    _currentSteps = event.steps;

    // Only update if steps increased (prevent negative steps)
    if (_currentSteps > previousSteps) {
      await prefs.setInt(_todayStepsKey, _currentSteps);
      _calculateDerivedValues();

      // Check for goal achievement
      if (previousSteps < _dailyGoal && _currentSteps >= _dailyGoal) {
        await NotificationService.showGoalAchievedNotification(_currentSteps);
      }

      // Save to database periodically
      if (_currentSteps % 100 == 0) {
        await _saveCurrentDayData();
      }

      notifyListeners();
    }
  }

  void _onStepCountError(error) {
    debugPrint('Step count stream error: $error');
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    _isWalking = event.status == 'walking';
    notifyListeners();
  }

  void _onPedestrianStatusError(error) {
    debugPrint('Pedestrian status stream error: $error');
  }

  void _calculateDerivedValues() {
    // Calculate calories (rough estimate: 0.04 calories per step)
    _caloriesBurned = _currentSteps * 0.04;

    // Calculate distance (rough estimate: 0.762 meters per step)
    _distanceWalked = _currentSteps * 0.000762; // in kilometers

    // Calculate active time (rough estimate: 1 minute per 120 steps)
    final activeMinutes = _currentSteps ~/ 120;
    _activeTime = Duration(minutes: activeMinutes);
  }

  Future<void> _saveCurrentDayData() async {
    final stepData = StepData(
      date: DateTime.now(),
      steps: _currentSteps,
      calories: _caloriesBurned,
      distance: _distanceWalked,
      activeTime: _activeTime,
      goalAchieved: goalAchieved,
    );

    await DatabaseService.instance.insertOrUpdateStepData(stepData);
  }

  Future<void> _loadHistoricalData() async {
    try {
      _weeklyData = await DatabaseService.instance.getWeeklyData();
      _monthlyData = await DatabaseService.instance.getMonthlyData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading historical data: $e');
    }
  }

  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyGoalKey, goal);
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadHistoricalData();
  }

  @override
  void dispose() {
    _stepCountStream?.cancel();
    _pedestrianStatusStream?.cancel();
    super.dispose();
  }

  // Manual step addition for testing
  Future<void> addSteps(int steps) async {
    _currentSteps += steps;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_todayStepsKey, _currentSteps);
    _calculateDerivedValues();
    await _saveCurrentDayData();
    notifyListeners();
  }

  // Reset today's steps
  Future<void> resetTodaySteps() async {
    _currentSteps = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_todayStepsKey, 0);
    _calculateDerivedValues();
    await _saveCurrentDayData();
    notifyListeners();
  }
}
