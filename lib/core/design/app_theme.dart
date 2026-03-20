import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Soft Premium Color Palette
  static const Color bgOffWhite = Color(0xFFFBFBF9); // Warm, calming background
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color primaryNavy = Color(0xFF1E293B); // Strong but not harsh black
  static const Color softSage = Color(0xFF8BA888); // Success, completion, calm energy
  static const Color mutedSand = Color(0xFFEAE7E0); // Soft borders, secondary elements
  static const Color textCharcoal = Color(0xFF334155); // Primary text
  static const Color textMutedGray = Color(0xFF8492A6); // Secondary text

  static ThemeData comebackTheme() {
    final baseTextTheme = Typography.material2021().black;

    // DM Sans brings a warm, geometric, premium feel
    final dmSansTheme = GoogleFonts.dmSansTextTheme(baseTextTheme).apply(
      bodyColor: textCharcoal,
      displayColor: textCharcoal,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgOffWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        onPrimary: cardWhite,
        secondary: softSage,
        onSecondary: cardWhite,
        surface: cardWhite,
        onSurface: textCharcoal,
        error: Color(0xFFE57373),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: textCharcoal,
        elevation: 0,
        titleTextStyle: GoogleFonts.dmSans(
          color: textCharcoal,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: dmSansTheme.copyWith(
        headlineLarge: dmSansTheme.headlineLarge?.copyWith(
          fontSize: 32,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: textCharcoal,
        ),
        headlineMedium: dmSansTheme.headlineMedium?.copyWith(
          fontSize: 26,
          height: 1.2,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: textCharcoal,
        ),
        headlineSmall: dmSansTheme.headlineSmall?.copyWith(
          fontSize: 22,
          height: 1.3,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: textCharcoal,
        ),
        titleLarge: dmSansTheme.titleLarge?.copyWith(
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: textCharcoal,
        ),
        titleMedium: dmSansTheme.titleMedium?.copyWith(
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w500,
          color: textCharcoal,
        ),
        titleSmall: dmSansTheme.titleSmall?.copyWith(
          fontSize: 14,
          height: 1.3,
          fontWeight: FontWeight.w500,
          color: textCharcoal,
        ),
        bodyLarge: dmSansTheme.bodyLarge?.copyWith(
          fontSize: 16,
          height: 1.6,
          color: textCharcoal,
        ),
        bodyMedium: dmSansTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.6,
          color: textMutedGray,
        ),
        bodySmall: dmSansTheme.bodySmall?.copyWith(
          fontSize: 13,
          height: 1.5,
          color: textMutedGray,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: mutedSand, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: cardWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999), // Fully rounded, pill shape
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          side: const BorderSide(color: mutedSand, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textMutedGray,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: softSage,
        linearTrackColor: mutedSand,
        circularTrackColor: mutedSand,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryNavy,
        contentTextStyle: GoogleFonts.dmSans(color: cardWhite),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
