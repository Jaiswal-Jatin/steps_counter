import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  // Controllers
  final _waterController = StreamController<int>.broadcast();
  final _sleepController = StreamController<double>.broadcast();

  // Data
  int _waterIntake = 0;
  double _sleepHours = 0.0;
  SharedPreferences? _prefs;

  // Getters
  Stream<int> get waterStream => _waterController.stream;
  Stream<double> get sleepStream => _sleepController.stream;
  int get waterIntake => _waterIntake;
  double get sleepHours => _sleepHours;

  // Initialize service
  Future<void> initialize() async {
    await _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    _prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().substring(0, 10);
    String savedDate = _prefs?.getString('health_date') ?? '';

    if (savedDate == today) {
      _waterIntake = _prefs?.getInt('waterIntake') ?? 0;
      _sleepHours = _prefs?.getDouble('sleepHours') ?? 0.0;
    } else {
      // New day, reset health data
      await _prefs?.setString('health_date', today);
      await _prefs?.setInt('waterIntake', 0);
      await _prefs?.setDouble('sleepHours', 0.0);
      _waterIntake = 0;
      _sleepHours = 0.0;
    }

    _waterController.add(_waterIntake);
    _sleepController.add(_sleepHours);
  }

  Future<void> _saveHealthData() async {
    String today = DateTime.now().toString().substring(0, 10);
    await _prefs?.setString('health_date', today);
    await _prefs?.setInt('waterIntake', _waterIntake);
    await _prefs?.setDouble('sleepHours', _sleepHours);
  }

  void addWater() {
    _waterIntake++;
    _waterController.add(_waterIntake);
    _saveHealthData();
  }

  void updateSleep(double hours) {
    _sleepHours = hours;
    _sleepController.add(_sleepHours);
    _saveHealthData();
  }

  void dispose() {
    _waterController.close();
    _sleepController.close();
  }
}
