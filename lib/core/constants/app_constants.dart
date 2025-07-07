import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 24.0;
  static const BorderRadius largeRadius = BorderRadius.all(
    Radius.circular(large),
  );
  static const BorderRadius mediumRadius = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius smallRadius = BorderRadius.all(
    Radius.circular(small),
  );
}

class AppShadows {
  static const List<BoxShadow> small = [
    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
  ];
}

class AppTextStyles {
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // Aliases for backward compatibility
  static const TextStyle headline2 = headingMedium;
  static const TextStyle headline6 = headingSmall;
}
