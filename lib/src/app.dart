import 'package:firebase_ui_auth/firebase_ui_auth.dart' hide ProfileScreen;
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:steps_counter_app/src/providers/app_state.dart';
import 'package:steps_counter_app/src/screens/analytics_screen.dart';
import 'package:steps_counter_app/src/screens/home_screen.dart';
import 'package:steps_counter_app/src/screens/profile_screen.dart';
import 'package:steps_counter_app/src/theme.dart';

class StepGoApp extends StatefulWidget {
  const StepGoApp({super.key});

  @override
  State<StepGoApp> createState() => _StepGoAppState();
}

class _StepGoAppState extends State<StepGoApp> {
  final _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appState,
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'StepGo',
            theme: StepGoTheme.light,
            darkTheme: StepGoTheme.dark,
            themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const _ScaffoldShell(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class _ScaffoldShell extends StatefulWidget {
  const _ScaffoldShell();

  @override
  State<_ScaffoldShell> createState() => _ScaffoldShellState();
}

class _ScaffoldShellState extends State<_ScaffoldShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
