import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';

class HomeWidgetService {
  static const String _groupId = 'group.steps_counter_app';

  static Future<void> initializeHomeWidget() async {
    await HomeWidget.setAppGroupId(_groupId);
  }

  static Future<void> updateStepsWidget({
    required int currentSteps,
    required int dailyGoal,
    required double distance,
    required int calories,
  }) async {
    try {
      // Update widget data
      await HomeWidget.saveWidgetData('current_steps', currentSteps);
      await HomeWidget.saveWidgetData('daily_goal', dailyGoal);
      await HomeWidget.saveWidgetData('distance', distance.toStringAsFixed(2));
      await HomeWidget.saveWidgetData('calories', calories);
      await HomeWidget.saveWidgetData('progress', (currentSteps / dailyGoal * 100).round());
      
      // Update the widget UI
      await HomeWidget.updateWidget(
        name: 'StepsCounterWidget',
        androidName: 'StepsCounterWidget',
        iOSName: 'StepsCounterWidget',
      );
      
      if (kDebugMode) {
        print('Home widget updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating home widget: $e');
      }
    }
  }

  static Future<void> registerBackgroundCallback() async {
    await HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri?.host == 'open_app') {
      // Handle widget tap - could open specific screen
      if (kDebugMode) {
        print('Widget tapped, opening app');
      }
    }
  }

  static Future<bool> isWidgetSupported() async {
    try {
      // For now, assume widgets are supported on Android
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> requestPinWidget() async {
    try {
      // This functionality might not be available in the current version
      // of home_widget, so we'll handle it gracefully
      if (kDebugMode) {
        print('Widget pin request feature not available');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting pin widget: $e');
      }
    }
  }
}

// Background callback function (must be top-level)
void backgroundCallback(Uri? uri) {
  HomeWidgetService.backgroundCallback(uri);
}
