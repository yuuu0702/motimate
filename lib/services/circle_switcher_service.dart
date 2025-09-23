import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// サークル切り替えサービス
///
/// ユーザーの現在のサークルを管理・切り替える機能を提供
class CircleSwitcherService {
  CircleSwitcherService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// 現在のユーザーIDを取得
  String? get currentUserId => _auth.currentUser?.uid;

  /// サークルを切り替え
  Future<void> switchCircle(String circleId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('ログインが必要です');

    try {
      // ユーザーが指定されたサークルのメンバーかどうかを確認
      final memberDoc = await _firestore
          .collection('circle_members')
          .doc('${circleId}_$userId')
          .get();

      if (!memberDoc.exists) {
        throw CircleSwitcherException('指定されたサークルのメンバーではありません', 'NOT_MEMBER');
      }

      final memberData = memberDoc.data()!;
      if (memberData['status'] != 'active') {
        throw CircleSwitcherException('このサークルへのアクセス権限がありません', 'ACCESS_DENIED');
      }

      // ユーザーの現在のサークルIDを更新
      await _firestore.collection('users').doc(userId).update({
        'currentCircleId': circleId,
        'lastAccessByCircle.$circleId': Timestamp.fromDate(DateTime.now()),
      });

      print('サークルを切り替えました: $circleId');
    } catch (e) {
      if (e is CircleSwitcherException) rethrow;
      throw Exception('サークルの切り替えに失敗しました: $e');
    }
  }

  /// ユーザーが参加しているサークル一覧を取得
  Future<List<Map<String, dynamic>>> getUserCirclesWithInfo() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('ログインが必要です');

    try {
      // ユーザーのメンバーシップを取得
      final membersSnapshot = await _firestore
          .collection('circle_members')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      final circlesWithInfo = <Map<String, dynamic>>[];

      for (final memberDoc in membersSnapshot.docs) {
        final memberData = memberDoc.data();
        final circleId = memberData['circleId'] as String;

        // サークル情報を取得
        final circleDoc = await _firestore
            .collection('circles')
            .doc(circleId)
            .get();

        if (circleDoc.exists && circleDoc.data()?['isActive'] == true) {
          final circleData = circleDoc.data()!;
          circlesWithInfo.add({
            'circleId': circleId,
            'circleName': circleData['name'] ?? '無名のサークル',
            'circleDescription': circleData['description'] ?? '',
            'iconType': circleData['settings']?['iconType'] ?? 'groups',
            'colorTheme': circleData['settings']?['colorTheme'] ?? 'blue',
            'memberRole': memberData['role'] ?? 'member',
            'memberCount': circleData['stats']?['memberCount'] ?? 0,
            'lastAccessed': memberData['joinedAt'] as Timestamp?,
          });
        }
      }

      // 最終アクセス順でソート（新しい順）
      circlesWithInfo.sort((a, b) {
        final aTime = a['lastAccessed'] as Timestamp?;
        final bTime = b['lastAccessed'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      return circlesWithInfo;
    } catch (e) {
      throw Exception('サークル一覧の取得に失敗しました: $e');
    }
  }

  /// 現在のサークル情報を取得
  Future<Map<String, dynamic>?> getCurrentCircleInfo() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      // ユーザー情報から現在のサークルIDを取得
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final currentCircleId = userData?['currentCircleId'] as String?;

      if (currentCircleId == null) return null;

      // サークル情報を取得
      final circleDoc = await _firestore
          .collection('circles')
          .doc(currentCircleId)
          .get();

      if (!circleDoc.exists) return null;

      final circleData = circleDoc.data()!;

      // メンバーシップ情報を取得
      final memberDoc = await _firestore
          .collection('circle_members')
          .doc('${currentCircleId}_$userId')
          .get();

      return {
        'circleId': currentCircleId,
        'circleName': circleData['name'] ?? '無名のサークル',
        'circleDescription': circleData['description'] ?? '',
        'iconType': circleData['settings']?['iconType'] ?? 'groups',
        'colorTheme': circleData['settings']?['colorTheme'] ?? 'blue',
        'memberRole': memberDoc.exists ? (memberDoc.data()?['role'] ?? 'member') : 'member',
        'memberCount': circleData['stats']?['memberCount'] ?? 0,
        'inviteCode': circleData['inviteCode'],
      };
    } catch (e) {
      print('現在のサークル情報取得エラー: $e');
      return null;
    }
  }

  /// 最近アクセスしたサークルを記録
  Future<void> recordCircleAccess(String circleId) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'lastAccessByCircle.$circleId': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('サークルアクセスの記録に失敗: $e');
    }
  }
}

/// サークル切り替え関連エラー
class CircleSwitcherException implements Exception {
  final String message;
  final String code;
  const CircleSwitcherException(this.message, this.code);

  @override
  String toString() => 'CircleSwitcherException: $message';
}

/// 具体的なサークル切り替え例外
class NotMember extends CircleSwitcherException {
  const NotMember() : super('指定されたサークルのメンバーではありません', 'NOT_MEMBER');
}

class AccessDenied extends CircleSwitcherException {
  const AccessDenied() : super('このサークルへのアクセス権限がありません', 'ACCESS_DENIED');
}