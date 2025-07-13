import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_location_model.dart';
import '../models/gymnasium_model.dart';

/// ユーザー拠点管理サービス
/// 
/// プライバシーを重視した拠点情報の管理を行う
/// 具体的な住所ではなく、エリアや最寄り駅程度の情報で位置を管理
class UserLocationService {
  static UserLocationService? _instance;
  static UserLocationService get instance => _instance ??= UserLocationService._internal();
  UserLocationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 現在のユーザーID取得
  String? get currentUserId => _auth.currentUser?.uid;

  /// ユーザーの拠点コレクション参照
  CollectionReference<Map<String, dynamic>> get _userLocationsRef {
    if (currentUserId == null) throw Exception('ユーザーがログインしていません');
    return _firestore.collection('users').doc(currentUserId).collection('locations');
  }

  /// ユーザーの全拠点を取得
  Future<List<UserLocationModel>> getUserLocations() async {
    try {
      final snapshot = await _userLocationsRef.get();
      return snapshot.docs
          .map((doc) => UserLocationModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('拠点取得エラー: $e');
      return [];
    }
  }

  /// ユーザーの全拠点をストリームで監視
  Stream<List<UserLocationModel>> watchUserLocations() {
    return _userLocationsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserLocationModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  /// メイン拠点を取得
  Future<UserLocationModel?> getPrimaryLocation() async {
    try {
      final snapshot = await _userLocationsRef
          .where('isPrimary', isEqualTo: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return UserLocationModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      print('メイン拠点取得エラー: $e');
      return null;
    }
  }

  /// 拠点を追加
  Future<bool> addUserLocation(UserLocationModel location) async {
    try {
      // メイン拠点設定の場合、他の拠点のメイン設定を解除
      if (location.isPrimary) {
        await _clearPrimaryFlag();
      }

      final locationData = location.toJson();
      locationData.remove('id'); // IDは自動生成
      locationData['userId'] = currentUserId;
      locationData['createdAt'] = FieldValue.serverTimestamp();
      locationData['updatedAt'] = FieldValue.serverTimestamp();

      await _userLocationsRef.add(locationData);
      return true;
    } catch (e) {
      print('拠点追加エラー: $e');
      return false;
    }
  }

  /// 拠点を更新
  Future<bool> updateUserLocation(UserLocationModel location) async {
    try {
      if (location.id.isEmpty) return false;

      // メイン拠点設定の場合、他の拠点のメイン設定を解除
      if (location.isPrimary) {
        await _clearPrimaryFlag(excludeId: location.id);
      }

      final locationData = location.toJson();
      locationData.remove('id'); // IDは除外
      locationData['updatedAt'] = FieldValue.serverTimestamp();

      await _userLocationsRef.doc(location.id).update(locationData);
      return true;
    } catch (e) {
      print('拠点更新エラー: $e');
      return false;
    }
  }

  /// 拠点を削除
  Future<bool> deleteUserLocation(String locationId) async {
    try {
      await _userLocationsRef.doc(locationId).delete();
      return true;
    } catch (e) {
      print('拠点削除エラー: $e');
      return false;
    }
  }

  /// 他の拠点のメイン設定を解除
  Future<void> _clearPrimaryFlag({String? excludeId}) async {
    try {
      Query query = _userLocationsRef.where('isPrimary', isEqualTo: true);
      final snapshot = await query.get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        if (excludeId == null || doc.id != excludeId) {
          batch.update(doc.reference, {'isPrimary': false});
        }
      }
      
      await batch.commit();
    } catch (e) {
      print('メイン設定解除エラー: $e');
    }
  }

  /// メイン拠点を設定
  Future<bool> setPrimaryLocation(String locationId) async {
    try {
      // 他の拠点のメイン設定を解除
      await _clearPrimaryFlag(excludeId: locationId);
      
      // 指定された拠点をメイン設定
      await _userLocationsRef.doc(locationId).update({
        'isPrimary': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('メイン拠点設定エラー: $e');
      return false;
    }
  }

  /// 拠点の数を取得
  Future<int> getLocationCount() async {
    try {
      final snapshot = await _userLocationsRef.get();
      return snapshot.docs.length;
    } catch (e) {
      print('拠点数取得エラー: $e');
      return 0;
    }
  }

  /// 金沢市内の推奨エリア一覧
  static const List<Map<String, dynamic>> kanazawaAreas = [
    {
      'name': '金沢駅周辺',
      'description': '金沢駅・ポルテ金沢エリア',
      'location': LatLng(latitude: 36.5781, longitude: 136.6478),
    },
    {
      'name': '香林坊・片町',
      'description': '中心街・繁華街エリア',
      'location': LatLng(latitude: 36.5616, longitude: 136.6561),
    },
    {
      'name': '金沢城・兼六園周辺',
      'description': '観光地・文化エリア',
      'location': LatLng(latitude: 36.5620, longitude: 136.6626),
    },
    {
      'name': '野町・寺町',
      'description': '寺町台・住宅エリア',
      'location': LatLng(latitude: 36.5481, longitude: 136.6456),
    },
    {
      'name': '泉野・有松',
      'description': '南部住宅・学生エリア',
      'location': LatLng(latitude: 36.5314, longitude: 136.6319),
    },
    {
      'name': '金沢工大前',
      'description': '扇が丘・大学エリア',
      'location': LatLng(latitude: 36.5441, longitude: 136.6248),
    },
    {
      'name': '新神田・問屋町',
      'description': '北部・工業エリア',
      'location': LatLng(latitude: 36.5892, longitude: 136.6712),
    },
    {
      'name': '東金沢・大桑',
      'description': '東部住宅エリア',
      'location': LatLng(latitude: 36.5452, longitude: 136.6813),
    },
    {
      'name': '西金沢・古府',
      'description': '西部住宅エリア',
      'location': LatLng(latitude: 36.5759, longitude: 136.6089),
    },
    {
      'name': '小立野・石引',
      'description': '大学・住宅エリア',
      'location': LatLng(latitude: 36.5585, longitude: 136.6595),
    },
  ];

  /// エリア名から位置情報を取得
  static LatLng? getLocationByAreaName(String areaName) {
    try {
      final area = kanazawaAreas.firstWhere(
        (area) => area['name'] == areaName,
      );
      return area['location'] as LatLng;
    } catch (e) {
      return null;
    }
  }

  /// 位置から最も近いエリアを取得
  static String getNearestAreaName(LatLng location) {
    double minDistance = double.infinity;
    String nearestArea = '金沢駅周辺';

    for (final area in kanazawaAreas) {
      final areaLocation = area['location'] as LatLng;
      final distance = _calculateDistance(location, areaLocation);
      
      if (distance < minDistance) {
        minDistance = distance;
        nearestArea = area['name'] as String;
      }
    }

    return nearestArea;
  }

  /// 簡易距離計算
  static double _calculateDistance(LatLng point1, LatLng point2) {
    final latDiff = point1.latitude - point2.latitude;
    final lngDiff = point1.longitude - point2.longitude;
    return latDiff * latDiff + lngDiff * lngDiff;
  }

  /// テストデータ作成（開発用）
  Future<void> createTestLocations() async {
    if (currentUserId == null) return;

    final testLocations = [
      UserLocationModel(
        id: '',
        userId: currentUserId!,
        name: '自宅エリア',
        address: '香林坊・片町エリア',
        location: const LatLng(latitude: 36.5616, longitude: 136.6561),
        type: LocationType.home,
        isPrimary: true,
        createdAt: DateTime.now(),
      ),
      UserLocationModel(
        id: '',
        userId: currentUserId!,
        name: '職場エリア',
        address: '金沢駅周辺エリア',
        location: const LatLng(latitude: 36.5781, longitude: 136.6478),
        type: LocationType.work,
        isPrimary: false,
        createdAt: DateTime.now(),
      ),
    ];

    for (final location in testLocations) {
      await addUserLocation(location);
    }
  }
}