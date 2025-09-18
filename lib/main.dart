import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:steps_counter_app/firebase_options.dart'; // Import firebase_options
import 'package:steps_counter_app/src/providers/app_state.dart'; // Import AppState
import 'package:steps_counter_app/src/screens/splash_screen.dart';
import 'package:steps_counter_app/src/theme.dart'; // Import StepGoTheme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Activate App Check
  // On web, you need to provide a reCAPTCHA v3 site key.
  // See https://firebase.google.com/docs/app-check/flutter/default-providers#web
  if (kIsWeb) {
    // await FirebaseAppCheck.instance.activate(
    //   webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
    // );
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MaterialApp(
          title: 'Step Counter App',
          theme: StepGoTheme.light,
          darkTheme: StepGoTheme.dark,
          themeMode: appState.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(), // Start with the splash screen
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}