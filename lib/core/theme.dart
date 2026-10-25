import 'package:flutter/material.dart';

abstract final class Palette {
  static const background = Color(0xFF141127);
  static const panel = Color(0xFF3C3E68);
  static const muted = Color(0xFF9293BC);
  static const purple = Color(0xFF6157F1);
  static const pink = Color(0xFFFB508C);
  static const blue = Color(0xFF657CF7);
  static const yellow = Color(0xFFFFD45B);
  static const green = Color(0xFF99D379);
  static const text = Color(0xFFFCFCFC);
  static const heading = LinearGradient(
    colors: [Color(0xFF9C4EAC), Color(0xFFFA558D)],
  );
  static const button = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8174FF), Color(0xFF5146E5)],
  );
}

ThemeData befitTheme() => ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Gilroy',
  scaffoldBackgroundColor: Palette.background,
  colorScheme: const ColorScheme.dark(
    primary: Palette.purple,
    secondary: Palette.pink,
    surface: Palette.background,
    onSurface: Palette.text,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      fontSize: 15,
      color: Palette.text,
      fontWeight: FontWeight.w500,
    ),
    bodySmall: TextStyle(fontSize: 13, color: Palette.muted),
  ),
  splashFactory: InkRipple.splashFactory,
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF42416A),
    contentTextStyle: const TextStyle(
      fontFamily: 'Gilroy',
      color: Colors.white,
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Palette.background.withValues(alpha: .45),
    contentPadding: const EdgeInsets.all(18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Palette.panel),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Palette.panel),
    ),
    hintStyle: const TextStyle(color: Palette.muted),
  ),
);
