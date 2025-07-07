import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/step_counter_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await NotificationService.initialize();

  // Request permissions
  await _requestPermissions();

  runApp(const StepCounterApp());
}

Future<void> _requestPermissions() async {
  await [
    Permission.activityRecognition,
    Permission.notification,
    Permission.ignoreBatteryOptimizations,
  ].request();
}

class StepCounterApp extends StatelessWidget {
  const StepCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StepCounterProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'StepGo - Step Counter',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
