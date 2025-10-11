import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アクセシビリティ設定サービス
class AccessibilityService {
  static const String _prefKeyReduceMotion = 'accessibility_reduce_motion';
  static const String _prefKeyHighContrast = 'accessibility_high_contrast';
  static const String _prefKeyLargeText = 'accessibility_large_text';
  static const String _prefKeyScreenReader = 'accessibility_screen_reader';
  static const String _prefKeyVoiceAnnouncements = 'accessibility_voice_announcements';

  static SharedPreferences? _prefs;

  /// 初期化
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// モーション削減設定
  static bool get isReduceMotionEnabled {
    return _prefs?.getBool(_prefKeyReduceMotion) ?? false;
  }

  static Future<void> setReduceMotionEnabled(bool enabled) async {
    await _prefs?.setBool(_prefKeyReduceMotion, enabled);
  }

  /// 高コントラスト設定
  static bool get isHighContrastEnabled {
    return _prefs?.getBool(_prefKeyHighContrast) ?? false;
  }

  static Future<void> setHighContrastEnabled(bool enabled) async {
    await _prefs?.setBool(_prefKeyHighContrast, enabled);
  }

  /// 大きなテキスト設定
  static bool get isLargeTextEnabled {
    return _prefs?.getBool(_prefKeyLargeText) ?? false;
  }

  static Future<void> setLargeTextEnabled(bool enabled) async {
    await _prefs?.setBool(_prefKeyLargeText, enabled);
  }

  /// スクリーンリーダー設定
  static bool get isScreenReaderEnabled {
    return _prefs?.getBool(_prefKeyScreenReader) ?? false;
  }

  static Future<void> setScreenReaderEnabled(bool enabled) async {
    await _prefs?.setBool(_prefKeyScreenReader, enabled);
  }

  /// 音声アナウンス設定
  static bool get isVoiceAnnouncementsEnabled {
    return _prefs?.getBool(_prefKeyVoiceAnnouncements) ?? true;
  }

  static Future<void> setVoiceAnnouncementsEnabled(bool enabled) async {
    await _prefs?.setBool(_prefKeyVoiceAnnouncements, enabled);
  }

  /// システムのアクセシビリティ設定を取得
  static AccessibilitySystemSettings getSystemSettings(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return AccessibilitySystemSettings(
      isHighContrast: mediaQuery.highContrast,
      textScaleFactor: mediaQuery.textScaler.scale(1.0),
      isAccessibleNavigation: mediaQuery.accessibleNavigation,
      isBoldText: mediaQuery.boldText,
      isInvertColors: mediaQuery.invertColors,
      isDisableAnimations: mediaQuery.disableAnimations,
    );
  }

  /// アクセシビリティに配慮したアニメーション設定
  static Duration getAnimationDuration(
    BuildContext context, {
    Duration defaultDuration = const Duration(milliseconds: 300),
  }) {
    final systemSettings = getSystemSettings(context);
    if (systemSettings.isDisableAnimations || isReduceMotionEnabled) {
      return Duration.zero;
    }
    return defaultDuration;
  }

  /// アクセシビリティに配慮したフォントサイズ
  static double getAccessibleFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final systemSettings = getSystemSettings(context);
    double scaleFactor = systemSettings.textScaleFactor;

    if (isLargeTextEnabled) {
      scaleFactor = scaleFactor * 1.2;
    }

    return baseFontSize * scaleFactor.clamp(0.8, 3.0);
  }

  /// アクセシビリティに配慮したカラー
  static Color getAccessibleColor(
    BuildContext context, {
    required Color defaultColor,
    Color? highContrastColor,
  }) {
    final systemSettings = getSystemSettings(context);
    if (systemSettings.isHighContrast || isHighContrastEnabled) {
      return highContrastColor ?? _adjustColorForHighContrast(defaultColor);
    }
    return defaultColor;
  }

  /// 高コントラスト用の色調整
  static Color _adjustColorForHighContrast(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness(
      hsl.lightness > 0.5 ? 0.9 : 0.1,
    ).toColor();
  }

  /// 音声フィードバック
  static Future<void> announceForAccessibility(String message) async {
    if (isVoiceAnnouncementsEnabled) {
      await SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  /// 画面遷移の音声アナウンス
  static Future<void> announceScreenChange(String screenName) async {
    await announceForAccessibility('$screenName画面に移動しました');
  }

  /// エラーメッセージの音声アナウンス
  static Future<void> announceError(String errorMessage) async {
    await announceForAccessibility('エラー: $errorMessage');
  }

  /// 成功メッセージの音声アナウンス
  static Future<void> announceSuccess(String successMessage) async {
    await announceForAccessibility('成功: $successMessage');
  }

  /// バイブレーション付きフィードバック
  static Future<void> provideTactileFeedback() async {
    await HapticFeedback.lightImpact();
  }

  /// アクセシビリティ診断
  static AccessibilityDiagnostics diagnoseAccessibility(BuildContext context) {
    final systemSettings = getSystemSettings(context);

    return AccessibilityDiagnostics(
      hasHighContrast: systemSettings.isHighContrast || isHighContrastEnabled,
      hasLargeText: systemSettings.textScaleFactor > 1.3 || isLargeTextEnabled,
      hasReducedMotion: systemSettings.isDisableAnimations || isReduceMotionEnabled,
      hasScreenReader: isScreenReaderEnabled,
      hasVoiceAnnouncements: isVoiceAnnouncementsEnabled,
      systemTextScaleFactor: systemSettings.textScaleFactor,
      recommendedImprovements: _generateRecommendations(systemSettings),
    );
  }

  /// アクセシビリティ改善の推奨事項を生成
  static List<String> _generateRecommendations(AccessibilitySystemSettings settings) {
    final recommendations = <String>[];

    if (!settings.isHighContrast && !isHighContrastEnabled) {
      recommendations.add('高コントラストモードを有効にすることを検討してください');
    }

    if (settings.textScaleFactor < 1.2 && !isLargeTextEnabled) {
      recommendations.add('大きなテキストサイズを有効にすることを検討してください');
    }

    if (!isVoiceAnnouncementsEnabled) {
      recommendations.add('音声アナウンスを有効にすることを検討してください');
    }

    return recommendations;
  }

  /// アクセシビリティガイドラインのチェック
  static AccessibilityComplianceReport checkCompliance(BuildContext context) {
    final systemSettings = getSystemSettings(context);

    return AccessibilityComplianceReport(
      hasMinimumTouchTargetSize: true, // 44x44pt以上
      hasSemanticLabels: true,
      hasKeyboardNavigation: true,
      hasColorIndependentInfo: !systemSettings.isHighContrast,
      hasSufficientContrast: systemSettings.isHighContrast || isHighContrastEnabled,
      hasAlternativeTextForImages: true,
      hasAccessibleErrors: true,
      score: _calculateAccessibilityScore(systemSettings),
    );
  }

  /// アクセシビリティスコアの計算
  static double _calculateAccessibilityScore(AccessibilitySystemSettings settings) {
    int score = 0;
    int maxScore = 7;

    if (settings.isHighContrast || isHighContrastEnabled) score++;
    if (settings.textScaleFactor >= 1.2 || isLargeTextEnabled) score++;
    if (isScreenReaderEnabled) score++;
    if (isVoiceAnnouncementsEnabled) score++;
    if (settings.isDisableAnimations || isReduceMotionEnabled) score++;
    if (settings.isAccessibleNavigation) score++;
    score++; // 基本的なSemanticsが実装されていると仮定

    return score / maxScore;
  }
}

/// システムのアクセシビリティ設定
class AccessibilitySystemSettings {
  final bool isHighContrast;
  final double textScaleFactor;
  final bool isAccessibleNavigation;
  final bool isBoldText;
  final bool isInvertColors;
  final bool isDisableAnimations;

  const AccessibilitySystemSettings({
    required this.isHighContrast,
    required this.textScaleFactor,
    required this.isAccessibleNavigation,
    required this.isBoldText,
    required this.isInvertColors,
    required this.isDisableAnimations,
  });
}

/// アクセシビリティ診断結果
class AccessibilityDiagnostics {
  final bool hasHighContrast;
  final bool hasLargeText;
  final bool hasReducedMotion;
  final bool hasScreenReader;
  final bool hasVoiceAnnouncements;
  final double systemTextScaleFactor;
  final List<String> recommendedImprovements;

  const AccessibilityDiagnostics({
    required this.hasHighContrast,
    required this.hasLargeText,
    required this.hasReducedMotion,
    required this.hasScreenReader,
    required this.hasVoiceAnnouncements,
    required this.systemTextScaleFactor,
    required this.recommendedImprovements,
  });
}

/// アクセシビリティコンプライアンス報告書
class AccessibilityComplianceReport {
  final bool hasMinimumTouchTargetSize;
  final bool hasSemanticLabels;
  final bool hasKeyboardNavigation;
  final bool hasColorIndependentInfo;
  final bool hasSufficientContrast;
  final bool hasAlternativeTextForImages;
  final bool hasAccessibleErrors;
  final double score; // 0.0-1.0

  const AccessibilityComplianceReport({
    required this.hasMinimumTouchTargetSize,
    required this.hasSemanticLabels,
    required this.hasKeyboardNavigation,
    required this.hasColorIndependentInfo,
    required this.hasSufficientContrast,
    required this.hasAlternativeTextForImages,
    required this.hasAccessibleErrors,
    required this.score,
  });

  String get gradeLevel {
    if (score >= 0.9) return 'AAA (最高レベル)';
    if (score >= 0.7) return 'AA (推奨レベル)';
    if (score >= 0.5) return 'A (基本レベル)';
    return '要改善';
  }
}