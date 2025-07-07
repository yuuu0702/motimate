import 'package:flutter/material.dart';

class AppTheme {
  // Material Design 3 Static Baseline Colors - Light Theme
  static const Color _lightPrimary = Color(0xFF6442d6);
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightPrimaryContainer = Color(0xFF9f86ff);
  static const Color _lightOnPrimaryContainer = Color(0xFF1e0060);
  
  static const Color _lightSecondary = Color(0xFF5d5d74);
  static const Color _lightOnSecondary = Color(0xFFFFFFFF);
  static const Color _lightSecondaryContainer = Color(0xFFdcdaf5);
  static const Color _lightOnSecondaryContainer = Color(0xFF21182b);
  
  static const Color _lightTertiary = Color(0xFF7b5467);
  static const Color _lightOnTertiary = Color(0xFFFFFFFF);
  static const Color _lightTertiaryContainer = Color(0xFFfed7e9);
  static const Color _lightOnTertiaryContainer = Color(0xFF331222);
  
  static const Color _lightError = Color(0xFFff6240);
  static const Color _lightOnError = Color(0xFFFFFFFF);
  static const Color _lightErrorContainer = Color(0xFFf9dedc);
  static const Color _lightOnErrorContainer = Color(0xFF490909);
  
  static const Color _lightBackground = Color(0xFFfefbff);
  static const Color _lightOnBackground = Color(0xFF1c1b1d);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightOnSurface = Color(0xFF1c1b1d);
  static const Color _lightSurfaceVariant = Color(0xFFe8e0e8);
  static const Color _lightOnSurfaceVariant = Color(0xFF4d4256);
  static const Color _lightOutline = Color(0xFF7e7487);
  
  // Material Design 3 Static Baseline Colors - Dark Theme
  static const Color _darkPrimary = Color(0xFFcbbeff);
  static const Color _darkOnPrimary = Color(0xFF340098);
  static const Color _darkPrimaryContainer = Color(0xFF4b21bd);
  static const Color _darkOnPrimaryContainer = Color(0xFFe8ddff);
  
  static const Color _darkSecondary = Color(0xFFc0bee8);
  static const Color _darkOnSecondary = Color(0xFF362d41);
  static const Color _darkSecondaryContainer = Color(0xFF4c4359);
  static const Color _darkOnSecondaryContainer = Color(0xFFdcdaf5);
  
  static const Color _darkTertiary = Color(0xFFe1bbcf);
  static const Color _darkOnTertiary = Color(0xFF4a2738);
  static const Color _darkTertiaryContainer = Color(0xFF623d50);
  static const Color _darkOnTertiaryContainer = Color(0xFFfed7e9);
  
  static const Color _darkError = Color(0xFFffb4ab);
  static const Color _darkOnError = Color(0xFF690005);
  static const Color _darkErrorContainer = Color(0xFF93000a);
  static const Color _darkOnErrorContainer = Color(0xFFffdad6);
  
  static const Color _darkBackground = Color(0xFF141218);
  static const Color _darkOnBackground = Color(0xFFe6e1e6);
  static const Color _darkSurface = Color(0xFF141218);
  static const Color _darkOnSurface = Color(0xFFe6e1e6);
  static const Color _darkSurfaceVariant = Color(0xFF4d4256);
  static const Color _darkOnSurfaceVariant = Color(0xFFcfc4cf);
  static const Color _darkOutline = Color(0xFF988e9a);

  /// Get the light theme for the app (static colors only)
  static ThemeData getLightTheme({ColorScheme? dynamicColorScheme}) {
    // Use static Material Design 3 colors instead of dynamic colors
    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      primaryContainer: _lightPrimaryContainer,
      onPrimaryContainer: _lightOnPrimaryContainer,
      secondary: _lightSecondary,
      onSecondary: _lightOnSecondary,
      secondaryContainer: _lightSecondaryContainer,
      onSecondaryContainer: _lightOnSecondaryContainer,
      tertiary: _lightTertiary,
      onTertiary: _lightOnTertiary,
      tertiaryContainer: _lightTertiaryContainer,
      onTertiaryContainer: _lightOnTertiaryContainer,
      error: _lightError,
      onError: _lightOnError,
      errorContainer: _lightErrorContainer,
      onErrorContainer: _lightOnErrorContainer,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      surfaceContainerHighest: _lightSurfaceVariant,
      onSurfaceVariant: _lightOnSurfaceVariant,
      outline: _lightOutline,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _darkSurface,
      onInverseSurface: _darkOnSurface,
      inversePrimary: _darkPrimary,
    );

    return _createTheme(colorScheme, Brightness.light);
  }

  /// Get the dark theme for the app (static colors only)
  static ThemeData getDarkTheme({ColorScheme? dynamicColorScheme}) {
    // Use static Material Design 3 colors instead of dynamic colors
    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      primaryContainer: _darkPrimaryContainer,
      onPrimaryContainer: _darkOnPrimaryContainer,
      secondary: _darkSecondary,
      onSecondary: _darkOnSecondary,
      secondaryContainer: _darkSecondaryContainer,
      onSecondaryContainer: _darkOnSecondaryContainer,
      tertiary: _darkTertiary,
      onTertiary: _darkOnTertiary,
      tertiaryContainer: _darkTertiaryContainer,
      onTertiaryContainer: _darkOnTertiaryContainer,
      error: _darkError,
      onError: _darkOnError,
      errorContainer: _darkErrorContainer,
      onErrorContainer: _darkOnErrorContainer,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      surfaceContainerHighest: _darkSurfaceVariant,
      onSurfaceVariant: _darkOnSurfaceVariant,
      outline: _darkOutline,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _lightSurface,
      onInverseSurface: _lightOnSurface,
      inversePrimary: _lightPrimary,
    );

    return _createTheme(colorScheme, Brightness.dark);
  }

  /// Create a theme with the given color scheme and brightness
  static ThemeData _createTheme(ColorScheme colorScheme, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'MPLUSRounded1c',
      
      // Scaffold
      scaffoldBackgroundColor: isDark ? _darkBackground : _lightBackground,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'MPLUSRounded1c',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: isDark ? 8 : 4,
        shadowColor: colorScheme.shadow.withValues(alpha: isDark ? 0.3 : 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'MPLUSRounded1c',
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontFamily: 'MPLUSRounded1c',
        ),
      ),
      
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colorScheme.inverseSurface : colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
      
      // List Tile
      listTileTheme: ListTileThemeData(
        tileColor: colorScheme.surface,
        selectedTileColor: colorScheme.primaryContainer,
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.5);
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
      
      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        trackHeight: 6,
      ),
    );
  }
}