import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData animeTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5AB4E0),
        surface: Color(0xFF0D0D0D),
      ),
      scaffoldBackgroundColor: const Color(0xFF080808),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFF080808),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0D0D0D),
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0xFF1A1A1A), width: 1),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFF0D0D0D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0xFF1A1A1A)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0D0D0D),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}
