import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Theme mode notifier
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const String _key = 'theme_mode';

  /// Load theme from shared preferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_key) ?? 0;
      state = ThemeMode.values[themeIndex];
      
      // Sync with Firestore in background
      _syncWithFirestore();
    } catch (e) {
      state = ThemeMode.system;
    }
  }

  /// Save theme to shared preferences
  Future<void> _saveTheme(ThemeMode theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, theme.index);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Sync with Firestore
  Future<void> _syncWithFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final firestoreTheme = data['themeMode'] as int? ?? 0;
        final firestoreThemeMode = ThemeMode.values[firestoreTheme];
        
        if (firestoreThemeMode != state) {
          state = firestoreThemeMode;
          await _saveTheme(firestoreThemeMode);
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Toggle theme mode
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newTheme);
  }

  /// Set specific theme mode
  Future<void> setTheme(ThemeMode theme) async {
    state = theme;
    await _saveTheme(theme);
    
    // Save to Firestore in background
    _saveToFirestore(theme);
  }

  /// Save to Firestore
  Future<void> _saveToFirestore(ThemeMode theme) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'themeMode': theme.index,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error silently
    }
  }
}

/// Theme controller provider
final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});

/// Convenience provider for checking if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final theme = ref.watch(themeControllerProvider);
  return theme == ThemeMode.dark;
});