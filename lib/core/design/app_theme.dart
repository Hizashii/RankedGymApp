import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData animeTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1A3A6B),
        onPrimary: Colors.white,
        secondary: Color(0xFF5C5446),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1C1814),
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F3EE),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFFF7F3EE),
        foregroundColor: Color(0xFF1C1814),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          height: 1.1,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1C1814),
        ),
        headlineMedium: TextStyle(
          fontSize: 30,
          height: 1.15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1C1814),
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1C1814),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1C1814),
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1814),
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1814),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.45,
          color: Color(0xFF5C5446),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: Color(0xFF6A645D),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: Color(0xFF9C9082),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFDED6CC), width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFFFFFFF),
      ),
    );
  }
}
