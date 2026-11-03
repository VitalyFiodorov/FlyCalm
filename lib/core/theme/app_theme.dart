import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color skyBlue = Color(0xFF60A5FA);
  static const Color lightBlue = Color(0xFFDBEAFE);
  static const Color mint = Color(0xFFA7F3D0);
  static const Color lavender = Color(0xFFDDD6FE);
  static const Color softPurple = Color(0xFFC4B5FD);
  static const Color cloudWhite = Color(0xFFF8FAFC);
  static const Color primaryText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color outline = Color(0xFFC7DAF4);

  // Compatibility aliases keep this redesign presentation-only.
  static const Color darkNavy = primaryText;
  static const Color deepBlue = lightBlue;
  static const Color softBlue = skyBlue;
  static const Color textLight = primaryText;
  static const Color textMuted = secondaryText;
  static const Color cardBg = Colors.white;

  static const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: skyBlue,
      brightness: Brightness.light,
      primary: skyBlue,
      surface: Colors.white,
      onSurface: primaryText,
    );
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: cloudWhite,
      primaryColor: softBlue,
      cardColor: cardBg,
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      dividerColor: outline,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryText,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: systemUiOverlayStyle,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: textLight, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(
            color: textLight, fontSize: 24, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textLight, fontSize: 18),
        bodyMedium: TextStyle(color: textLight, fontSize: 16),
        labelLarge: TextStyle(color: textMuted, fontSize: 14),
      ),
    );
  }
}
