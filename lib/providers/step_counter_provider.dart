import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/step_data.dart';
// import '../services/home_widget_service.dart';

class StepCounterProvider extends ChangeNotifier {
  int _currentSteps = 0;
  int _dailyGoal = 10000;
  double _currentDistance = 0.0;
  int _currentCalories = 0;
  List<StepData> _weeklyData = [];
  List<WaterIntake> _todayWaterIntake = [];
  NutritionData? _todayNutrition;
  UserProfile? _userProfile;
  
  late Stream<StepCount> _stepCountStream;
  late StreamSubscription<StepCount> _stepCountSubscription;
  
  // Getters
  int get currentSteps => _currentSteps;
  int get dailyGoal => _dailyGoal;
  double get currentDistance => _currentDistance;
  int get currentCalories => _currentCalories;
  List<StepData> get weeklyData => _weeklyData;
  List<WaterIntake> get todayWaterIntake => _todayWaterIntake;
  NutritionData? get todayNutrition => _todayNutrition;
  UserProfile? get userProfile => _userProfile;
  
  double get stepsProgress => _currentSteps / _dailyGoal;
  double get waterProgress {
    double totalWater = _todayWaterIntake.fold(0.0, (sum, intake) => sum + intake.amount);
    return totalWater / (_userProfile?.dailyWaterGoal ?? 2500); // Convert liters to ml
  }
  
  StepCounterProvider() {
    _initializeData();
    _requestPermissions();
  }

  Future<void> _initializeData() async {
    await _loadUserProfile();
    await _loadTodayData();
    await _loadWeeklyData();
    await _loadWaterIntake();
    await _loadNutritionData();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _initPedometer();
    }
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountSubscription = _stepCountStream.listen(_onStepCount);
  }

  void _onStepCount(StepCount event) {
    _currentSteps = event.steps;
    _calculateDistance();
    _calculateCalories();
    _saveTodayData();
    _updateHomeWidget();
    notifyListeners();
  }

  void _calculateDistance() {
    // Average step length for adults is about 0.78 meters
    double stepLength = 0.78;
    if (_userProfile != null) {
      // More accurate calculation based on height
      stepLength = _userProfile!.height * 0.45 / 100; // Convert cm to meters
    }
    _currentDistance = (_currentSteps * stepLength) / 1000; // Convert to kilometers
  }

  void _calculateCalories() {
    if (_userProfile != null) {
      // MET value for walking is approximately 3.5
      double met = 3.5;
      double weightInKg = _userProfile!.weight;
      double timeInHours = _currentSteps / 2000; // Assuming 2000 steps per hour
      _currentCalories = (met * weightInKg * timeInHours).round();
    } else {
      // Default calculation
      _currentCalories = (_currentSteps * 0.04).round();
    }
  }

  Future<void> _updateHomeWidget() async {
    try {
      // Update home widget with new steps - commented out temporarily
      // await HomeWidgetService.updateStepsWidget(
      //   currentSteps: _currentSteps,
      //   dailyGoal: _dailyGoal,
      //   distance: _currentDistance,
      //   calories: _currentCalories,
      // );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating home widget: $e');
      }
    }
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      final profileData = json.decode(profileJson);
      _userProfile = UserProfile.fromJson(profileData);
      _dailyGoal = _userProfile!.dailyStepsGoal;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    _dailyGoal = profile.dailyStepsGoal;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(profile.toJson()));
    
    notifyListeners();
  }

  Future<void> _saveTodayData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'steps_${today.year}_${today.month}_${today.day}';
    
    final stepData = StepData(
      date: today,
      steps: _currentSteps,
      distance: _currentDistance,
      calories: _currentCalories,
    );
    
    await prefs.setString(todayKey, json.encode(stepData.toJson()));
  }

  Future<void> _loadTodayData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'steps_${today.year}_${today.month}_${today.day}';
    
    final stepDataJson = prefs.getString(todayKey);
    if (stepDataJson != null) {
      final stepData = StepData.fromJson(json.decode(stepDataJson));
      _currentSteps = stepData.steps;
      _currentDistance = stepData.distance;
      _currentCalories = stepData.calories;
    }
  }

  Future<void> _loadWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    _weeklyData.clear();
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = 'steps_${date.year}_${date.month}_${date.day}';
      final stepDataJson = prefs.getString(key);
      
      if (stepDataJson != null) {
        final stepData = StepData.fromJson(json.decode(stepDataJson));
        _weeklyData.add(stepData);
      } else {
        _weeklyData.add(StepData(
          date: date,
          steps: 0,
          distance: 0.0,
          calories: 0,
        ));
      }
    }
  }

  Future<void> addWaterIntake(double amount) async {
    final intake = WaterIntake(
      date: DateTime.now(),
      amount: amount,
    );
    
    _todayWaterIntake.add(intake);
    await _saveWaterIntake();
    notifyListeners();
  }

  Future<void> _saveWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'water_${today.year}_${today.month}_${today.day}';
    
    final waterJson = _todayWaterIntake.map((intake) => intake.toJson()).toList();
    await prefs.setString(todayKey, json.encode(waterJson));
  }

  Future<void> _loadWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'water_${today.year}_${today.month}_${today.day}';
    
    final waterJson = prefs.getString(todayKey);
    if (waterJson != null) {
      final waterList = json.decode(waterJson) as List;
      _todayWaterIntake = waterList.map((item) => WaterIntake.fromJson(item)).toList();
    }
  }

  Future<void> updateNutrition(NutritionData nutrition) async {
    _todayNutrition = nutrition;
    await _saveNutritionData();
    notifyListeners();
  }

  Future<void> _saveNutritionData() async {
    if (_todayNutrition == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'nutrition_${today.year}_${today.month}_${today.day}';
    
    await prefs.setString(todayKey, json.encode(_todayNutrition!.toJson()));
  }

  Future<void> _loadNutritionData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'nutrition_${today.year}_${today.month}_${today.day}';
    
    final nutritionJson = prefs.getString(todayKey);
    if (nutritionJson != null) {
      _todayNutrition = NutritionData.fromJson(json.decode(nutritionJson));
    }
  }

  @override
  void dispose() {
    _stepCountSubscription.cancel();
    super.dispose();
  }
}
