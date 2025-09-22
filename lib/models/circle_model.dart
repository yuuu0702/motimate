import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'circle_model.freezed.dart';
part 'circle_model.g.dart';

@freezed
class CircleModel with _$CircleModel {
  const factory CircleModel({
    required String id,
    required String name,
    required String description,
    required String category,
    required String creatorId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required CircleSettings settings,
    required PrivacySettings privacy,
    required CircleStats stats,
    String? inviteCode,
    @Default(true) bool isActive,
  }) = _CircleModel;

  factory CircleModel.fromJson(Map<String, dynamic> json) =>
      _$CircleModelFromJson(json);

  factory CircleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CircleModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      creatorId: data['creatorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      settings: CircleSettings.fromJson(data['settings'] ?? {}),
      privacy: PrivacySettings.fromJson(data['privacy'] ?? {}),
      stats: CircleStats.fromJson(data['stats'] ?? {}),
      inviteCode: data['inviteCode'],
      isActive: data['isActive'] ?? true,
    );
  }
}

extension CircleModelX on CircleModel {
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'creatorId': creatorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'settings': settings.toJson(),
      'privacy': privacy.toJson(),
      'stats': stats.toJson(),
      'inviteCode': inviteCode,
      'isActive': isActive,
    };
  }
}

@freezed
class CircleSettings with _$CircleSettings {
  const factory CircleSettings({
    @Default('groups') String iconType,
    @Default('blue') String colorTheme,
    @Default('活動') String activityName,
    @Default(true) bool allowInvites,
    @Default(true) bool enableNotifications,
    @Default(<String, dynamic>{}) Map<String, dynamic> customSettings,
  }) = _CircleSettings;

  factory CircleSettings.fromJson(Map<String, dynamic> json) =>
      _$CircleSettingsFromJson(json);
}

extension CircleSettingsX on CircleSettings {
  IconType get iconTypeEnum => IconType.fromId(iconType);
  ColorTheme get colorThemeEnum => ColorTheme.fromId(colorTheme);
}

@freezed
class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    @Default(true) bool isPublic,
    @Default(true) bool searchable,
    @Default(false) bool requiresApproval,
    @Default(true) bool showMemberCount,
    @Default(true) bool showActivity,
  }) = _PrivacySettings;

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);
}

@freezed
class CircleStats with _$CircleStats {
  const factory CircleStats({
    @Default(0) int memberCount,
    @Default(0) int activityCount,
    DateTime? lastActivityAt,
  }) = _CircleStats;

  factory CircleStats.fromJson(Map<String, dynamic> json) =>
      _$CircleStatsFromJson(json);
}

/// サークルカテゴリの定義
enum CircleCategory {
  sports('sports', 'スポーツ', '🏃'),
  culture('culture', '文化・芸術', '🎨'),
  study('study', '勉強・学習', '📚'),
  music('music', '音楽', '🎵'),
  cooking('cooking', '料理', '👨‍🍳'),
  travel('travel', '旅行', '✈️'),
  games('games', 'ゲーム', '🎮'),
  tech('tech', 'テック', '💻'),
  business('business', 'ビジネス', '💼'),
  volunteer('volunteer', 'ボランティア', '🤝'),
  other('other', 'その他', '📋');

  const CircleCategory(this.value, this.displayName, this.emoji);

  final String value;
  final String displayName;
  final String emoji;

  IconData get icon {
    switch (this) {
      case CircleCategory.sports:
        return Icons.sports;
      case CircleCategory.culture:
        return Icons.palette;
      case CircleCategory.study:
        return Icons.school;
      case CircleCategory.music:
        return Icons.music_note;
      case CircleCategory.cooking:
        return Icons.restaurant;
      case CircleCategory.travel:
        return Icons.flight;
      case CircleCategory.games:
        return Icons.games;
      case CircleCategory.tech:
        return Icons.computer;
      case CircleCategory.business:
        return Icons.business;
      case CircleCategory.volunteer:
        return Icons.volunteer_activism;
      case CircleCategory.other:
        return Icons.category;
    }
  }

  static CircleCategory fromId(String id) {
    return CircleCategory.values.firstWhere(
      (category) => category.value == id,
      orElse: () => CircleCategory.other,
    );
  }
}

/// アイコンタイプの定義
enum IconType {
  sports('sports', '🏃'),
  basketball('basketball', '🏀'),
  tennis('tennis', '🎾'),
  soccer('soccer', '⚽'),
  baseball('baseball', '⚾'),
  music('music', '🎵'),
  art('art', '🎨'),
  book('book', '📚'),
  cooking('cooking', '👨‍🍳'),
  tech('tech', '💻'),
  business('business', '💼'),
  groups('groups', '👥'),
  other('other', '📋');

  const IconType(this.id, this.emoji);

  final String id;
  final String emoji;

  IconData get iconData {
    switch (this) {
      case IconType.sports:
        return Icons.sports;
      case IconType.basketball:
        return Icons.sports_basketball;
      case IconType.tennis:
        return Icons.sports_tennis;
      case IconType.soccer:
        return Icons.sports_soccer;
      case IconType.baseball:
        return Icons.sports_baseball;
      case IconType.music:
        return Icons.music_note;
      case IconType.art:
        return Icons.palette;
      case IconType.book:
        return Icons.book;
      case IconType.cooking:
        return Icons.restaurant;
      case IconType.tech:
        return Icons.computer;
      case IconType.business:
        return Icons.business;
      case IconType.groups:
        return Icons.group;
      case IconType.other:
        return Icons.category;
    }
  }

  String get displayName {
    switch (this) {
      case IconType.sports:
        return 'スポーツ';
      case IconType.basketball:
        return 'バスケットボール';
      case IconType.tennis:
        return 'テニス';
      case IconType.soccer:
        return 'サッカー';
      case IconType.baseball:
        return '野球';
      case IconType.music:
        return '音楽';
      case IconType.art:
        return 'アート';
      case IconType.book:
        return '本・読書';
      case IconType.cooking:
        return '料理';
      case IconType.tech:
        return 'テクノロジー';
      case IconType.business:
        return 'ビジネス';
      case IconType.groups:
        return 'グループ';
      case IconType.other:
        return 'その他';
    }
  }

  static IconType fromId(String id) {
    return IconType.values.firstWhere(
      (iconType) => iconType.id == id,
      orElse: () => IconType.groups,
    );
  }
}

/// カラーテーマの定義
enum ColorTheme {
  blue('blue', 'ブルー', 0xFF667eea),
  green('green', 'グリーン', 0xFF10B981),
  purple('purple', 'パープル', 0xFF8B5CF6),
  red('red', 'レッド', 0xFFEF4444),
  orange('orange', 'オレンジ', 0xFFF59E0B),
  pink('pink', 'ピンク', 0xFFEC4899),
  indigo('indigo', 'インディゴ', 0xFF6366F1),
  teal('teal', 'ティール', 0xFF14B8A6);

  const ColorTheme(this.id, this.displayName, this.colorValue);

  final String id;
  final String displayName;
  final int colorValue;

  Color get primaryColor => Color(colorValue);

  static ColorTheme fromId(String id) {
    return ColorTheme.values.firstWhere(
      (theme) => theme.id == id,
      orElse: () => ColorTheme.blue,
    );
  }
}