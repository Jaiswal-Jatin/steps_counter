import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steps_counter_app/src/providers/app_state.dart';
import 'package:steps_counter_app/src/screens/profile_screen.dart';
import 'package:steps_counter_app/src/screens/splash_screen.dart';
import 'package:steps_counter_app/src/services/notification_service.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize the NotificationService
  await NotificationService().init();

  // Initialize AppState. The constructor handles loading preferences.
  final appState = AppState();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    // For demonstration, directly showing ProfileScreen
    return const MaterialApp(home: SplashScreen(),
    debugShowCheckedModeBanner: false,);
  }
}