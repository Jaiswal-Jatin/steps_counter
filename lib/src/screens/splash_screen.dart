import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:steps_counter_app/src/app.dart'; // Corrected import
import 'package:steps_counter_app/src/auth_gate.dart'; // Corrected path
import 'package:steps_counter_app/src/theme.dart'; // Corrected import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for a minimum duration to show the splash screen.
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // After the splash screen, AuthGate will handle whether to show
    // the login screen or the main app. AppState initialization is
    // triggered by the auth state change.
    Navigator.of(context).pushReplacement( // Removed const from MaterialPageRoute and AuthGate
      MaterialPageRoute(
        builder: (context) => AuthGate(), // Removed const from AuthGate and ScaffoldShell
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StepGoTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: Lottie.asset('assets/animations/zombie walk.json'),
            ),
            const SizedBox(height: 20),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                'StepGo',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2.0, 2.0),
                        ),
                      ],
                    ),
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ],
        ),
      ),
    );
  }
}