import 'package:flutter/services.dart';

class HealthService {
  static const _channel = MethodChannel('steps_counter/health');

  Future<bool> isApiSupported() async {
    try {
      return await _channel.invokeMethod('isApiSupported') ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> checkPermissions() async {
    return await _channel.invokeMethod('checkPermissions') ?? false;
  }

  Future<void> requestPermissions() async {
    await _channel.invokeMethod('requestPermissions');
  }

  Future<int> getTodaysSteps() async {
    return await _channel.invokeMethod<int>('readTodaysSteps') ?? 0;
  }

  Future<void> scheduleWidgetUpdates() async {
    await _channel.invokeMethod('scheduleWidgetUpdates');
  }
}