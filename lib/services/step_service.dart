import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class StepCounterService {
  static final StepCounterService _instance = StepCounterService._internal();
  factory StepCounterService() => _instance;
  StepCounterService._internal();

  // Streams
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  // Controllers
  final _stepController = StreamController<int>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  // Data
  int _steps = 0;
  int _dailySteps = 0;
  int _initialSteps = 0;
  String _status = 'unknown';
  bool _hasPermission = false;
  SharedPreferences? _prefs;

  // Getters
  Stream<int> get stepStream => _stepController.stream;
  Stream<String> get statusStream => _statusController.stream;
  int get dailySteps => _dailySteps;
  int get totalSteps => _steps;
  String get status => _status;
  bool get hasPermission => _hasPermission;

  // Initialize service
  Future<void> initialize() async {
    await _loadPreferences();
    await _requestPermissions();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().substring(0, 10);
    String savedDate = _prefs?.getString('date') ?? '';

    if (savedDate == today) {
      _dailySteps = _prefs?.getInt('dailySteps') ?? 0;
      _initialSteps = _prefs?.getInt('initialSteps') ?? 0;
    } else {
      // New day, reset daily values
      await _prefs?.setString('date', today);
      await _prefs?.setInt('dailySteps', 0);
      _dailySteps = 0;
      _initialSteps = 0;
    }

    _stepController.add(_dailySteps);
  }

  Future<void> _savePreferences() async {
    String today = DateTime.now().toString().substring(0, 10);
    await _prefs?.setString('date', today);
    await _prefs?.setInt('dailySteps', _dailySteps);
    await _prefs?.setInt('initialSteps', _initialSteps);
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.activityRecognition.request();
    _hasPermission = status.isGranted;

    if (_hasPermission) {
      _initPlatformState();
    }
  }

  void _initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(_onPedestrianStatusChanged)
        .onError(_onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
  }

  void _onStepCount(StepCount event) {
    if (_initialSteps == 0) {
      _initialSteps = event.steps;
      _savePreferences();
    }

    _steps = event.steps;
    _dailySteps = _steps - _initialSteps;
    if (_dailySteps < 0) _dailySteps = 0;

    _stepController.add(_dailySteps);
    _savePreferences();
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    _status = event.status;
    _statusController.add(_status);
  }

  void _onStepCountError(error) {
    debugPrint('Step Count Error: $error');
    _status = 'Step counting unavailable';
    _statusController.add(_status);
  }

  void _onPedestrianStatusError(error) {
    debugPrint('Pedestrian Status Error: $error');
  }

  void addTestStep() {
    _dailySteps++;
    _stepController.add(_dailySteps);
    _savePreferences();
  }

  void resetSteps() {
    _dailySteps = 0;
    _initialSteps = _steps;
    _stepController.add(_dailySteps);
    _savePreferences();
  }

  // Calculate distance (in km)
  double getDistance() {
    return (_dailySteps * 0.762) / 1000; // Average step length
  }

  // Calculate calories burned
  int getCalories() {
    return (_dailySteps * 0.04).round(); // Approximate calories per step
  }

  // Get motivational message
  String getMotivationalMessage() {
    double progress = _dailySteps / 10000;
    if (progress >= 1.0) return "🎉 Goal Achieved! You're awesome!";
    if (progress >= 0.8) return "💪 Almost there! Keep pushing!";
    if (progress >= 0.5) return "🚀 Great progress! Halfway done!";
    if (progress >= 0.2) return "✨ Good start! Keep moving!";
    return "🌟 Every step counts! Let's begin!";
  }

  void dispose() {
    _stepController.close();
    _statusController.close();
  }
}
