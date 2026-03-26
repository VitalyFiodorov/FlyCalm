import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color deepBlue = Color(0xFF1E3A8A);
  static const Color softBlue = Color(0xFF60A5FA);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color cardBg = Color(0xFF1E293B);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkNavy,
      primaryColor: softBlue,
      cardColor: cardBg,
      fontFamily: 'Roboto', // Using default font instead of downloading for MVP, but configured for easy swap
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textLight, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textLight, fontSize: 24, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textLight, fontSize: 18),
        bodyMedium: TextStyle(color: textLight, fontSize: 16),
        labelLarge: TextStyle(color: textMuted, fontSize: 14),
      ),
      colorScheme: ColorScheme.dark(
        primary: softBlue,
        surface: cardBg,
        onSurface: textLight,
        background: darkNavy,
        onBackground: textLight,
      ),
    );
  }
}
