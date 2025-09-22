import 'package:cloud_firestore/cloud_firestore.dart';
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
    @Default(<String, dynamic>{}) Map<String, dynamic> customSettings,
  }) = _CircleSettings;

  factory CircleSettings.fromJson(Map<String, dynamic> json) =>
      _$CircleSettingsFromJson(json);
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

  const CircleCategory(this.id, this.displayName, this.emoji);

  final String id;
  final String displayName;
  final String emoji;

  static CircleCategory fromId(String id) {
    return CircleCategory.values.firstWhere(
      (category) => category.id == id,
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

  static ColorTheme fromId(String id) {
    return ColorTheme.values.firstWhere(
      (theme) => theme.id == id,
      orElse: () => ColorTheme.blue,
    );
  }
}