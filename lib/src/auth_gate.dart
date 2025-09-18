import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:steps_counter_app/scaffold_shell.dart';
import 'package:steps_counter_app/src/screens/onboarding_screen.dart'; // Import the new onboarding screen

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const OnboardingScreen(); // Show OnboardingScreen if not logged in
        }
        return const ScaffoldShell(); // Show the main app with bottom navigation
      },
    );
  }
}
