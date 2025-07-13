import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'gymnasium_model.dart';

part 'user_location_model.freezed.dart';
part 'user_location_model.g.dart';

/// ユーザー拠点情報モデル
/// 
/// ユーザーが登録する拠点（自宅、職場等）の情報を管理
@freezed
class UserLocationModel with _$UserLocationModel {
  const factory UserLocationModel({
    /// 拠点ID
    required String id,
    /// ユーザーID
    required String userId,
    /// 拠点名（例: "自宅", "職場", "実家"）
    required String name,
    /// 住所
    required String address,
    /// 緯度経度
    required LatLng location,
    /// 拠点タイプ
    @Default(LocationType.other) LocationType type,
    /// メイン拠点フラグ
    @Default(false) bool isPrimary,
    /// 作成日時
    DateTime? createdAt,
    /// 更新日時
    DateTime? updatedAt,
  }) = _UserLocationModel;

  factory UserLocationModel.fromJson(Map<String, dynamic> json) =>
      _$UserLocationModelFromJson(json);
}

/// 拠点タイプ
enum LocationType {
  @JsonValue('home')
  home('自宅'),
  @JsonValue('work')
  work('職場'),
  @JsonValue('school')
  school('学校'),
  @JsonValue('other')
  other('その他');

  const LocationType(this.displayName);
  final String displayName;
}

/// おすすめ体育館計算結果
@freezed
class GymnasiumRecommendation with _$GymnasiumRecommendation {
  const factory GymnasiumRecommendation({
    /// 体育館情報
    required GymnasiumModel gymnasium,
    /// 推奨スコア（0-100）
    required double score,
    /// 参加者からの平均距離（km）
    required double averageDistance,
    /// 最大距離（km）
    required double maxDistance,
    /// 最小距離（km）
    required double minDistance,
    /// アクセス性評価コメント
    String? accessibilityComment,
    /// 参加者の拠点情報
    @Default([]) List<ParticipantLocation> participantLocations,
  }) = _GymnasiumRecommendation;

  factory GymnasiumRecommendation.fromJson(Map<String, dynamic> json) =>
      _$GymnasiumRecommendationFromJson(json);
}

/// 参加者の拠点情報
@freezed
class ParticipantLocation with _$ParticipantLocation {
  const factory ParticipantLocation({
    /// ユーザーID
    required String userId,
    /// ユーザー名
    required String userName,
    /// 拠点情報
    required UserLocationModel location,
    /// 体育館までの距離（km）
    required double distanceToGymnasium,
  }) = _ParticipantLocation;

  factory ParticipantLocation.fromJson(Map<String, dynamic> json) =>
      _$ParticipantLocationFromJson(json);
}

/// 距離計算ユーティリティ
class DistanceCalculator {
  /// ハーバサイン公式を使用して2点間の距離を計算（km）
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // 地球の半径（km）
    
    final double lat1Rad = point1.latitude * (pi / 180);
    final double lat2Rad = point2.latitude * (pi / 180);
    final double deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    final double deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// 複数の拠点から体育館までの平均距離を計算
  static double calculateAverageDistance(
    List<LatLng> userLocations,
    LatLng gymnasiumLocation,
  ) {
    if (userLocations.isEmpty) return 0.0;
    
    final double totalDistance = userLocations
        .map((location) => calculateDistance(location, gymnasiumLocation))
        .reduce((a, b) => a + b);
    
    return totalDistance / userLocations.length;
  }

  /// おすすめスコアを計算（距離が短いほど高スコア）
  static double calculateRecommendationScore(
    double averageDistance,
    double maxDistance,
    double minDistance,
  ) {
    // 基本スコア（平均距離が短いほど高い）
    final double baseScore = 100 - (averageDistance * 10);
    
    // 距離のばらつきペナルティ（全員が近い方が良い）
    final double spreadPenalty = (maxDistance - minDistance) * 2;
    
    // 最終スコア（0-100の範囲に収める）
    final double finalScore = (baseScore - spreadPenalty).clamp(0.0, 100.0);
    
    return finalScore;
  }
}