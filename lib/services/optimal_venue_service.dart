import '../models/gymnasium_model.dart';
import '../models/user_location_model.dart';
import '../data/gymnasium_data.dart';
import '../utils/distance_calculator.dart' as calc;

/// 最適会場算出サービス
/// 
/// 参加者の位置情報に基づいて最適なバスケ体育館を算出
class OptimalVenueService {
  static OptimalVenueService? _instance;
  static OptimalVenueService get instance => _instance ??= OptimalVenueService._internal();
  OptimalVenueService._internal();

  /// 参加者のユーザー位置情報から最適な体育館を算出
  /// 
  /// [participantUserLocations] 参加者の登録済み位置情報リスト
  /// [maxDistanceKm] 考慮する最大距離（キロメートル）
  /// 
  /// 戻り値: OptimalVenueResult（最適会場情報とメトリクス）
  Future<OptimalVenueResult?> findOptimalVenue(
    List<UserLocationModel> participantUserLocations, {
    double maxDistanceKm = 50.0,
  }) async {
    if (participantUserLocations.isEmpty) return null;

    // ユーザー位置情報をLatLngに変換
    // 参加者位置をLatLngリストに変換（現在は未使用だが将来のために保持）
    // final participantLatLngs = participantUserLocations
    //     .map((userLoc) => userLoc.location)
    //     .toList();

    // バスケ利用可能な体育館のみを対象
    final basketballGymnasiums = GymnasiumData.gymnasiums
        .where((gym) => gym.facilities.contains(GymnasiumFacilities.basketball))
        .toList();

    if (basketballGymnasiums.isEmpty) return null;

    // 各体育館について総移動距離を計算
    final venueAnalyses = <VenueAnalysis>[];

    for (final gymnasium in basketballGymnasiums) {
      final analysis = _analyzeVenue(gymnasium, participantUserLocations);
      
      // 最大距離制限をチェック
      if (analysis.maxDistance <= maxDistanceKm) {
        venueAnalyses.add(analysis);
      }
    }

    if (venueAnalyses.isEmpty) return null;

    // 総移動距離が最小の体育館を選択
    venueAnalyses.sort((a, b) => a.totalDistance.compareTo(b.totalDistance));
    final optimalAnalysis = venueAnalyses.first;

    return OptimalVenueResult(
      gymnasium: optimalAnalysis.gymnasium,
      participantCount: participantUserLocations.length,
      totalDistance: optimalAnalysis.totalDistance,
      averageDistance: optimalAnalysis.averageDistance,
      maxDistance: optimalAnalysis.maxDistance,
      minDistance: optimalAnalysis.minDistance,
      participantDistances: optimalAnalysis.participantDistances,
      alternativeVenues: venueAnalyses.skip(1).take(3).toList(),
    );
  }

  /// 単一体育館の分析
  VenueAnalysis _analyzeVenue(
    GymnasiumModel gymnasium,
    List<UserLocationModel> participantUserLocations,
  ) {
    final distances = <ParticipantDistance>[];
    double totalDistance = 0;

    for (final userLocation in participantUserLocations) {
      final distance = calc.DistanceCalculator.calculateDistanceToGymnasium(
        userLocation.location.latitude,
        userLocation.location.longitude,
        gymnasium,
      );

      distances.add(ParticipantDistance(
        userLocation: userLocation,
        distance: distance,
      ));

      totalDistance += distance;
    }

    distances.sort((a, b) => a.distance.compareTo(b.distance));

    return VenueAnalysis(
      gymnasium: gymnasium,
      totalDistance: totalDistance,
      averageDistance: totalDistance / participantUserLocations.length,
      maxDistance: distances.last.distance,
      minDistance: distances.first.distance,
      participantDistances: distances,
    );
  }

  /// 参加者の重心位置を計算
  LatLng calculateParticipantCentroid(List<UserLocationModel> participants) {
    final locations = participants.map((p) => p.location).toList();
    return calc.DistanceCalculator.calculateCentroid(locations) ?? 
           const LatLng(latitude: 36.5616, longitude: 136.6561); // 金沢市中心
  }

  /// 重心位置から最も近い体育館を検索
  GymnasiumModel? findNearestToParticipants(List<UserLocationModel> participants) {
    if (participants.isEmpty) return null;

    final centroid = calculateParticipantCentroid(participants);
    final basketballGymnasiums = GymnasiumData.gymnasiums
        .where((gym) => gym.facilities.contains(GymnasiumFacilities.basketball))
        .toList();

    return calc.DistanceCalculator.findNearestGymnasium(
      centroid.latitude,
      centroid.longitude,
      basketballGymnasiums,
    );
  }
}

/// 最適会場算出結果
class OptimalVenueResult {
  const OptimalVenueResult({
    required this.gymnasium,
    required this.participantCount,
    required this.totalDistance,
    required this.averageDistance,
    required this.maxDistance,
    required this.minDistance,
    required this.participantDistances,
    required this.alternativeVenues,
  });

  final GymnasiumModel gymnasium;
  final int participantCount;
  final double totalDistance;
  final double averageDistance;
  final double maxDistance;
  final double minDistance;
  final List<ParticipantDistance> participantDistances;
  final List<VenueAnalysis> alternativeVenues;

  /// 結果の要約テキスト
  String get summaryText {
    return '参加者${participantCount}名の平均移動距離: ${calc.DistanceCalculator.formatDistance(averageDistance)}';
  }

  /// 詳細説明テキスト
  String get detailText {
    final maxDistanceText = calc.DistanceCalculator.formatDistance(maxDistance);
    final minDistanceText = calc.DistanceCalculator.formatDistance(minDistance);
    return '最短: $minDistanceText、最長: $maxDistanceText';
  }
}

/// 体育館分析結果
class VenueAnalysis {
  const VenueAnalysis({
    required this.gymnasium,
    required this.totalDistance,
    required this.averageDistance,
    required this.maxDistance,
    required this.minDistance,
    required this.participantDistances,
  });

  final GymnasiumModel gymnasium;
  final double totalDistance;
  final double averageDistance;
  final double maxDistance;
  final double minDistance;
  final List<ParticipantDistance> participantDistances;
}

/// 参加者別距離情報
class ParticipantDistance {
  const ParticipantDistance({
    required this.userLocation,
    required this.distance,
  });

  final UserLocationModel userLocation;
  final double distance;

  String get formattedDistance => calc.DistanceCalculator.formatDistance(distance);
}