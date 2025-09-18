// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:steps_counter_app/src/app.dart';
import 'package:steps_counter_app/src/providers/app_state.dart';

void main() {
  testWidgets('Steps Counter App smoke test', (WidgetTester tester) async {
    // Build the app shell without the full app/firebase wrapper for a simple widget test.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(
          home: StepGoApp(),
        ),
      ),
    );

    // Verify that the app starts with the Home page
    expect(find.text("Today's Steps"), findsOneWidget);

    // Verify navigation bar exists
    expect(find.byType(NavigationBar), findsOneWidget);

    // Tap on the Analytics icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();

    // Verify that we navigated to the Analytics screen.
    expect(find.text('Analytics'), findsOneWidget);
  });
}
