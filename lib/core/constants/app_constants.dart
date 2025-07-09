import 'package:flutter/material.dart';

/// Application constants
class AppConstants {
  AppConstants._();

  /// Brand colors
  static const Color primaryColor = Color(0xFF667eea);
  static const Color secondaryColor = Color(0xFF764ba2);
  
  /// Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Motivation levels configuration
  static const List<Map<String, dynamic>> motivationLevels = [
    {
      'emoji': '😰',
      'label': 'やる気なし',
      'color': [0xFFEF4444, 0xFFDC2626],
      'description': 'モチベーションが低い状態',
    },
    {
      'emoji': '😕',
      'label': 'あまりやる気なし',
      'color': [0xFFF59E0B, 0xFFD97706],
      'description': 'やや低いモチベーション',
    },
    {
      'emoji': '😐',
      'label': 'ふつう',
      'color': [0xFF8B5CF6, 0xFF7C3AED],
      'description': '普通のモチベーション',
    },
    {
      'emoji': '😊',
      'label': 'やる気あり',
      'color': [0xFF06B6D4, 0xFF0891B2],
      'description': 'やる気のある状態',
    },
    {
      'emoji': '🔥',
      'label': 'めっちゃやる気',
      'color': [0xFF10B981, 0xFF059669],
      'description': '非常に高いモチベーション',
    },
  ];
  
  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  /// Spacing constants
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  
  /// Border radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 20.0;
  
  /// Shadow elevation
  static const double cardElevation = 8.0;
  static const double buttonElevation = 4.0;
}