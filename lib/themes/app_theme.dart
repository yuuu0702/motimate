import 'package:flutter/material.dart';

class AppTheme {
  static const String fontFamily = 'MPLUSRounded1c';
  
  static const Color primaryColor = Color(0xFF667eea);
  static const Color lightScaffoldBackground = Color(0xFFF8FAFC);
  static const Color darkScaffoldBackground = Color(0xFF0F172A);
  static const Color lightCardBackground = Colors.white;
  static const Color darkCardBackground = Color(0xFF1E293B);
  static const Color lightForeground = Color(0xFF1E293B);
  static const Color darkForeground = Colors.white;
  static const Color unselectedItemColor = Color(0xFF64748B);
  static const Color darkUnselectedItemColor = Color(0xFF94A3B8);

  static ThemeData get lightTheme => ThemeData(
    fontFamily: fontFamily,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: lightScaffoldBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightCardBackground,
      foregroundColor: lightForeground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightForeground,
      ),
    ),
    cardTheme: CardThemeData(
      color: lightCardBackground,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightCardBackground,
      selectedItemColor: primaryColor,
      unselectedItemColor: unselectedItemColor,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: lightCardBackground,
      elevation: 8,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    fontFamily: fontFamily,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: darkScaffoldBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkCardBackground,
      foregroundColor: darkForeground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkForeground,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCardBackground,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCardBackground,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkUnselectedItemColor,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: darkForeground,
      elevation: 8,
    ),
  );

  // Helper methods for theme-aware colors
  static Color containerBackground(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF374151) : const Color(0xFFF9FAFB);

  static Color primaryText(bool isDarkMode) =>
      isDarkMode ? Colors.white : const Color(0xFF1F2937);

  static Color secondaryText(bool isDarkMode) =>
      isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF374151);

  static Color tertiaryText(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

  static Color cardColor(bool isDarkMode) =>
      isDarkMode ? darkCardBackground : lightCardBackground;

  static Color scaffoldBackground(bool isDarkMode) =>
      isDarkMode ? darkScaffoldBackground : lightScaffoldBackground;
}