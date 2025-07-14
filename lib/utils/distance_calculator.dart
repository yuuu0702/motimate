import 'dart:math';
import '../models/gymnasium_model.dart';

/// 距離計算ユーティリティクラス
/// 
/// Haversine公式を使用して2点間の距離を計算し、
/// 最寄りの体育館検索や最適会場算出を提供
class DistanceCalculator {
  static const double _earthRadiusKm = 6371.0;

  /// 2つの位置座標間の距離をキロメートルで計算
  /// 
  /// Haversine公式を使用して球面上の最短距離を算出
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  /// 指定位置から体育館までの距離を計算
  static double calculateDistanceToGymnasium(
    double userLat,
    double userLon,
    GymnasiumModel gymnasium,
  ) {
    return calculateDistance(
      userLat,
      userLon,
      gymnasium.location.latitude,
      gymnasium.location.longitude,
    );
  }

  /// 指定位置から最も近い体育館を検索
  static GymnasiumModel? findNearestGymnasium(
    double userLat,
    double userLon,
    List<GymnasiumModel> gymnasiums,
  ) {
    if (gymnasiums.isEmpty) return null;

    GymnasiumModel? nearest;
    double nearestDistance = double.infinity;

    for (final gymnasium in gymnasiums) {
      final distance = calculateDistanceToGymnasium(
        userLat,
        userLon,
        gymnasium,
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = gymnasium;
      }
    }

    return nearest;
  }

  /// 複数の参加者位置から最適な体育館を算出
  /// 
  /// 全参加者からの総移動距離が最小となる体育館を選択
  static GymnasiumModel? findOptimalGymnasium(
    List<LatLng> participantLocations,
    List<GymnasiumModel> gymnasiums,
  ) {
    if (participantLocations.isEmpty || gymnasiums.isEmpty) return null;

    GymnasiumModel? optimal;
    double minTotalDistance = double.infinity;

    for (final gymnasium in gymnasiums) {
      double totalDistance = 0;

      for (final location in participantLocations) {
        totalDistance += calculateDistanceToGymnasium(
          location.latitude,
          location.longitude,
          gymnasium,
        );
      }

      if (totalDistance < minTotalDistance) {
        minTotalDistance = totalDistance;
        optimal = gymnasium;
      }
    }

    return optimal;
  }

  /// 参加者位置の重心を計算
  static LatLng? calculateCentroid(List<LatLng> locations) {
    if (locations.isEmpty) return null;

    double totalLat = 0;
    double totalLon = 0;

    for (final location in locations) {
      totalLat += location.latitude;
      totalLon += location.longitude;
    }

    return LatLng(
      latitude: totalLat / locations.length,
      longitude: totalLon / locations.length,
    );
  }

  /// 距離を人間が読みやすい形式でフォーマット
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 10.0) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  /// 度数をラジアンに変換
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// 体育館リストを距離順でソート
  static List<GymnasiumWithDistance> sortGymnasiumsByDistance(
    double userLat,
    double userLon,
    List<GymnasiumModel> gymnasiums,
  ) {
    final gymnasiumsWithDistance = gymnasiums.map((gymnasium) {
      final distance = calculateDistanceToGymnasium(
        userLat,
        userLon,
        gymnasium,
      );
      return GymnasiumWithDistance(gymnasium, distance);
    }).toList();

    gymnasiumsWithDistance.sort((a, b) => a.distance.compareTo(b.distance));
    return gymnasiumsWithDistance;
  }
}

/// 体育館と距離の組み合わせクラス
class GymnasiumWithDistance {
  const GymnasiumWithDistance(this.gymnasium, this.distance);

  final GymnasiumModel gymnasium;
  final double distance;

  String get formattedDistance => DistanceCalculator.formatDistance(distance);
}