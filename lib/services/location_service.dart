import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/gymnasium_model.dart';
import '../utils/distance_calculator.dart';

/// 位置情報サービス
/// 
/// ユーザーの現在位置取得、権限管理、距離計算を行う
class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._internal();
  LocationService._internal();

  /// 位置情報権限をチェックし、必要に応じて要求する
  Future<bool> requestLocationPermission() async {
    // 権限状態をチェック
    final permissionStatus = await Permission.location.status;
    
    if (permissionStatus.isGranted) {
      return true;
    }
    
    if (permissionStatus.isDenied) {
      // 権限を要求
      final result = await Permission.location.request();
      return result.isGranted;
    }
    
    if (permissionStatus.isPermanentlyDenied) {
      // 設定画面を開く
      await openAppSettings();
      return false;
    }
    
    return false;
  }

  /// 位置情報サービスが有効かチェック
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// 現在位置を取得
  Future<LatLng?> getCurrentPosition() async {
    try {
      // 位置情報サービスの確認
      if (!await isLocationServiceEnabled()) {
        throw Exception('位置情報サービスが無効です');
      }

      // 権限の確認
      if (!await requestLocationPermission()) {
        throw Exception('位置情報の権限が拒否されました');
      }

      // 現在位置を取得
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LatLng(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('位置情報取得エラー: $e');
      return null;
    }
  }

  /// 2点間の距離を計算（メートル単位）
  double calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// 体育館までの距離を計算（キロメートル単位）
  double calculateDistanceToGymnasium(LatLng userLocation, GymnasiumModel gymnasium) {
    return DistanceCalculator.calculateDistanceToGymnasium(
      userLocation.latitude,
      userLocation.longitude,
      gymnasium,
    );
  }

  /// 複数の体育館を距離順にソート
  List<GymnasiumModel> sortGymnasiumsByDistance(
    List<GymnasiumModel> gymnasiums,
    LatLng userLocation,
  ) {
    final List<GymnasiumModel> sortedList = List.from(gymnasiums);
    
    sortedList.sort((a, b) {
      final distanceA = calculateDistanceToGymnasium(userLocation, a);
      final distanceB = calculateDistanceToGymnasium(userLocation, b);
      return distanceA.compareTo(distanceB);
    });
    
    return sortedList;
  }

  /// 指定範囲内の体育館をフィルタリング
  List<GymnasiumModel> filterGymnasiumsByRadius(
    List<GymnasiumModel> gymnasiums,
    LatLng userLocation,
    double radiusKm,
  ) {
    return gymnasiums.where((gymnasium) {
      final distance = calculateDistanceToGymnasium(userLocation, gymnasium);
      return distance <= radiusKm;
    }).toList();
  }

  /// 金沢市の中心位置（デフォルト位置）
  static const LatLng kanazawaCenterLocation = LatLng(
    latitude: 36.5616, 
    longitude: 136.6561
  );

  /// 位置情報取得に失敗した場合のフォールバック位置
  LatLng getFallbackLocation() {
    return kanazawaCenterLocation;
  }

  /// 位置情報の更新を監視（リアルタイム位置情報）
  Stream<LatLng> watchPosition() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // 100m移動したら更新
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((position) => LatLng(
              latitude: position.latitude,
              longitude: position.longitude,
            ));
  }

  /// 位置情報権限の状態を文字列で取得
  Future<String> getLocationPermissionStatus() async {
    final status = await Permission.location.status;
    
    switch (status) {
      case PermissionStatus.granted:
        return '許可済み';
      case PermissionStatus.denied:
        return '拒否';
      case PermissionStatus.restricted:
        return '制限';
      case PermissionStatus.limited:
        return '制限付き許可';
      case PermissionStatus.permanentlyDenied:
        return '永久拒否';
      default:
        return '不明';
    }
  }
}