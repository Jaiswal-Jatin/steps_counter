// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_counter_app/src/screens/onboarding_screen.dart'; // Import OnboardingScreen

void main() {
  testWidgets('Onboarding Screen smoke test', (WidgetTester tester) async {
    // Build the OnboardingScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // Verify that the OnboardingScreen displays the expected text
    expect(find.text('Earn rewards for every step you take.'), findsOneWidget);
    expect(find.text('More than tracking transform walking into winning.'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    // Optionally, tap the login button and verify navigation (requires mocking Navigator)
    // For now, we'll just check for its presence.
  });
}
