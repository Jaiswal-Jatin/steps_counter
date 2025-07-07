import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class StepProvider with ChangeNotifier {
  int _currentSteps = 0;
  int _dailyGoal = 6000;
  int _totalStepsToday = 0;
  int _startSteps = 0;
  bool _isPedometerListening = false;
  double _calories = 0.0;
  double _distance = 0.0;
  double _activeMinutes = 0.0;
  StreamSubscription<StepCount>? _stepCountStream;

  // Journey tracking
  String _currentJourney = "London to Paris";
  double _journeyTotalDistance = 344.0; // km
  double _journeyProgress = 0.0;

  // Weekly and monthly data
  List<int> _weeklySteps = List.filled(7, 0);
  Map<String, int> _monthlySteps = {};

  // Water tracking
  int _waterGoal = 8; // glasses
  int _waterConsumed = 0;

  // Getters
  int get currentSteps => _currentSteps;
  int get dailyGoal => _dailyGoal;
  int get totalStepsToday => _totalStepsToday;
  double get calories => _calories;
  double get distance => _distance;
  double get activeMinutes => _activeMinutes;
  bool get isPedometerListening => _isPedometerListening;
  String get currentJourney => _currentJourney;
  double get journeyTotalDistance => _journeyTotalDistance;
  double get journeyProgress => _journeyProgress;
  double get journeyRemainingDistance =>
      _journeyTotalDistance - _journeyProgress;
  List<int> get weeklySteps => _weeklySteps;
  Map<String, int> get monthlySteps => _monthlySteps;
  int get waterGoal => _waterGoal;
  int get waterConsumed => _waterConsumed;

  double get goalProgress => _totalStepsToday / _dailyGoal;
  bool get isGoalAchieved => _totalStepsToday >= _dailyGoal;

  StepProvider() {
    _loadData();
    _initializePedometer();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyGoal = prefs.getInt('daily_goal') ?? 6000;
    _totalStepsToday = prefs.getInt('total_steps_today') ?? 0;
    _startSteps = prefs.getInt('start_steps') ?? 0;
    _journeyProgress = prefs.getDouble('journey_progress') ?? 0.0;
    _waterConsumed = prefs.getInt('water_consumed') ?? 0;

    // Load weekly data
    for (int i = 0; i < 7; i++) {
      _weeklySteps[i] = prefs.getInt('weekly_step_$i') ?? 0;
    }

    // Check if it's a new day and reset if needed
    final lastDate = prefs.getString('last_date') ?? '';
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastDate != today) {
      await _resetDailyData();
      await prefs.setString('last_date', today);
    }

    notifyListeners();
  }

  Future<void> _resetDailyData() async {
    final prefs = await SharedPreferences.getInstance();

    // Shift weekly data
    for (int i = 6; i > 0; i--) {
      _weeklySteps[i] = _weeklySteps[i - 1];
      await prefs.setInt('weekly_step_$i', _weeklySteps[i]);
    }
    _weeklySteps[0] = _totalStepsToday;
    await prefs.setInt('weekly_step_0', _weeklySteps[0]);

    // Reset daily counters
    _totalStepsToday = 0;
    _waterConsumed = 0;
    _startSteps = 0;

    await prefs.setInt('total_steps_today', 0);
    await prefs.setInt('water_consumed', 0);
    await prefs.setInt('start_steps', 0);
  }

  Future<void> _initializePedometer() async {
    final permission = await Permission.activityRecognition.request();

    if (permission.isGranted) {
      _stepCountStream = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
      _isPedometerListening = true;
    }
    notifyListeners();
  }

  void _onStepCount(StepCount event) async {
    if (_startSteps == 0) {
      _startSteps = event.steps;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('start_steps', _startSteps);
    }

    _currentSteps = event.steps - _startSteps;
    _totalStepsToday = _currentSteps;

    // Calculate derived metrics
    _calories = _totalStepsToday * 0.045; // Rough calculation
    _distance = _totalStepsToday * 0.000762; // km (average step length)
    _activeMinutes = _totalStepsToday * 0.01; // Rough calculation

    // Update journey progress
    _journeyProgress = (_distance).clamp(0.0, _journeyTotalDistance);

    // Save data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_steps_today', _totalStepsToday);
    await prefs.setDouble('journey_progress', _journeyProgress);

    notifyListeners();
  }

  void _onStepCountError(error) {
    print('Step Count Error: $error');
    _isPedometerListening = false;
    notifyListeners();
  }

  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal', goal);
    notifyListeners();
  }

  Future<void> addWater() async {
    if (_waterConsumed < _waterGoal) {
      _waterConsumed++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('water_consumed', _waterConsumed);
      notifyListeners();
    }
  }

  Future<void> removeWater() async {
    if (_waterConsumed > 0) {
      _waterConsumed--;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('water_consumed', _waterConsumed);
      notifyListeners();
    }
  }

  Future<void> setWaterGoal(int goal) async {
    _waterGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_goal', goal);
    notifyListeners();
  }

  // Get average steps for different periods
  double get weeklyAverage {
    if (_weeklySteps.isEmpty) return 0.0;
    final sum = _weeklySteps.reduce((a, b) => a + b);
    return sum / _weeklySteps.length;
  }

  int get weeklyTotal {
    return _weeklySteps.reduce((a, b) => a + b);
  }

  // Mock data for monthly view (you can implement proper monthly storage)
  List<int> getMonthlyData() {
    // Return mock data for now - in real app, you'd store and retrieve actual monthly data
    return List.generate(
      31,
      (index) => (2000 + (index * 200) + (index % 7 * 500)).clamp(0, 8000),
    );
  }

  @override
  void dispose() {
    _stepCountStream?.cancel();
    super.dispose();
  }
}
