import 'package:flutter/material.dart';

class StepGoTheme {
  // Colors: primary + 3 neutrals + 1 accent
  static const Color primary = Color(0xFFFF6A3D); // orange
  static const Color foreground = Color(0xFF111827); // neutral 900
  static const Color muted = Color(0xFF6B7280); // neutral 500
  static const Color surface = Color(0xFFF3F4F6); // neutral 100
  static const Color accent = Color(0xFF10B981); // green

  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary).copyWith(primary: primary),
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: foreground),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: foreground),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: foreground),
        bodyMedium: TextStyle(color: foreground),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark).copyWith(primary: primary),
      scaffoldBackgroundColor: const Color(0xFF0B0F14),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: const Color(0xFF111827),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
