import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData animeTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E90FF),
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF090B13),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Color(0xFF090B13),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF11182A),
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF213254), width: 1),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFF16213A),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF102035),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF0E1322),
        indicatorColor: Color(0x661E90FF),
      ),
    );
  }
}
