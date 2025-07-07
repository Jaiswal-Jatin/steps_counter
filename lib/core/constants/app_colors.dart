import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFF2D3748);
  static const Color primaryLight = Color(0xFFF7FAFC);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF1A202C);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D3748);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  static const Color textDark = Color(0xFFFFFFFF);

  // Chart Colors
  static const Color chartActive = Color(0xFFFF6B35);
  static const Color chartInactive = Color(0xFFE2E8F0);
  static const Color chartBackground = Color(0xFFF7FAFC);

  // Status Colors
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF3182CE);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
  );

  // Additional Colors
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);

  // Aliases for backward compatibility
  static const Color primary = primaryOrange;
  static const Color accent = primaryOrange;
  static const Color background = backgroundLight;
  static const Color surface = cardLight;
  static const Color secondary = primaryDark;
  static const LinearGradient secondaryGradient = primaryGradient;
}
