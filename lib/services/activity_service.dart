import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_decision_model.dart';
import 'permission_service.dart';

/// 活動管理サービス
///
/// 活動決定への回答、未回答活動の取得を担当（旧PracticeService）
class ActivityService {
  ActivityService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    PermissionService? permissionService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _permissionService = permissionService ?? PermissionService();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final PermissionService _permissionService;

  /// 現在のユーザーIDを取得
  String? get currentUserId => _auth.currentUser?.uid;

  /// 活動を決定
  Future<String> createActivityDecision({
    required String circleId,
    required DateTime activityDate,
    required List<String> availableMembers,
    String? memo,
  }) async {
    await _permissionService.requirePermission(circleId, Permission.decideActivity);

    final userId = currentUserId!;

    try {
      final now = DateTime.now();
      final dateKey = '${activityDate.year}-${activityDate.month.toString().padLeft(2, '0')}-${activityDate.day.toString().padLeft(2, '0')}';

      final decision = ActivityDecisionModel(
        id: '', // Firestoreが自動生成
        circleId: circleId,
        decidedBy: userId,
        decidedAt: now,
        activityDate: activityDate,
        dateKey: dateKey,
        availableMembers: availableMembers,
        status: 'pending',
        responses: <String, String>{},
        memo: memo?.trim(),
        actualParticipants: <String>[],
      );

      final docRef = await _firestore
          .collection('activity_decisions')
          .add(decision.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('活動の決定に失敗しました: $e');
    }
  }

  /// 未回答の活動決定を取得（現在・未来のもののみ）
  Future<List<ActivityDecisionModel>> getPendingActivities(String circleId) async {
    await _permissionService.requirePermission(circleId, Permission.accessCircle);

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 今日以降の活動決定を取得
      final snapshot = await _firestore
          .collection('activity_decisions')
          .where('circleId', isEqualTo: circleId)
          .where('activityDate', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
          .orderBy('activityDate')
          .get();

      return snapshot.docs
          .map((doc) => ActivityDecisionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('活動一覧の取得に失敗しました: $e');
    }
  }

  /// 過去の活動決定を取得（履歴用）
  Future<List<ActivityDecisionModel>> getPastActivities(String circleId, {int limit = 10}) async {
    await _permissionService.requirePermission(circleId, Permission.accessCircle);

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 昨日以前の活動決定を取得
      final snapshot = await _firestore
          .collection('activity_decisions')
          .where('circleId', isEqualTo: circleId)
          .where('activityDate', isLessThan: Timestamp.fromDate(today))
          .orderBy('activityDate', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ActivityDecisionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('過去の活動一覧の取得に失敗しました: $e');
    }
  }

  /// 活動への参加回答を送信
  Future<void> respondToActivity(String activityId, String response) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('ログインが必要です');

    if (response != 'join' && response != 'skip') {
      throw Exception('無効な回答です');
    }

    try {
      // 活動情報を取得して権限をチェック
      final doc = await _firestore
          .collection('activity_decisions')
          .doc(activityId)
          .get();

      if (!doc.exists) throw Exception('活動が見つかりません');

      final activity = ActivityDecisionModel.fromFirestore(doc);

      // サークルへのアクセス権と回答権限をチェック
      await _permissionService.requirePermission(
        activity.circleId,
        Permission.respondToActivity,
      );

      // 回答可能メンバーに含まれているかチェック
      if (!activity.availableMembers.contains(userId)) {
        throw Exception('この活動に回答する権限がありません');
      }

      await _firestore
          .collection('activity_decisions')
          .doc(activityId)
          .update({
        'responses.$userId': response,
      });
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('回答の送信に失敗しました: $e');
    }
  }

  /// 活動にメモを追加
  Future<void> updateActivityMemo(String activityId, String memo) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('ログインが必要です');

    try {
      // 活動情報を取得して権限をチェック
      final doc = await _firestore
          .collection('activity_decisions')
          .doc(activityId)
          .get();

      if (!doc.exists) throw Exception('活動が見つかりません');

      final activity = ActivityDecisionModel.fromFirestore(doc);

      await _permissionService.requirePermission(
        activity.circleId,
        Permission.decideActivity,
      );

      await _firestore
          .collection('activity_decisions')
          .doc(activityId)
          .update({
        'memo': memo.trim().isEmpty ? null : memo.trim(),
      });
    } catch (e) {
      throw Exception('メモの更新に失敗しました: $e');
    }
  }

  /// 実際の参加者を更新
  Future<void> updateActualParticipants(String activityId, List<String> participants) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('ログインが必要です');

    try {
      // 活動情報を取得して権限をチェック
      final doc = await _firestore
          .collection('activity_decisions')
          .doc(activityId)
          .get();

      if (!doc.exists) throw Exception('活動が見つかりません');

      final activity = ActivityDecisionModel.fromFirestore(doc);

      await _permissionService.requirePermission(
        activity.circleId,
        Permission.decideActivity,
      );

      await _firestore
          .collection('activity_decisions')
          .doc(activityId)
          .update({
        'actualParticipants': participants,
      });
    } catch (e) {
      throw Exception('参加者の更新に失敗しました: $e');
    }
  }

  /// 活動を削除
  Future<void> deleteActivity(String activityId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('ログインが必要です');

    try {
      // 活動情報を取得して権限をチェック
      final doc = await _firestore
          .collection('activity_decisions')
          .doc(activityId)
          .get();

      if (!doc.exists) throw Exception('活動が見つかりません');

      final activity = ActivityDecisionModel.fromFirestore(doc);

      await _permissionService.requirePermission(
        activity.circleId,
        Permission.decideActivity,
      );

      await _firestore
          .collection('activity_decisions')
          .doc(activityId)
          .delete();
    } catch (e) {
      throw Exception('活動の削除に失敗しました: $e');
    }
  }

  /// 活動のステータスを更新
  Future<void> updateActivityStatus(String activityId, String status) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('ログインが必要です');

    if (!['pending', 'confirmed', 'cancelled'].contains(status)) {
      throw Exception('無効なステータスです');
    }

    try {
      // 活動情報を取得して権限をチェック
      final doc = await _firestore
          .collection('activity_decisions')
          .doc(activityId)
          .get();

      if (!doc.exists) throw Exception('活動が見つかりません');

      final activity = ActivityDecisionModel.fromFirestore(doc);

      await _permissionService.requirePermission(
        activity.circleId,
        Permission.decideActivity,
      );

      await _firestore
          .collection('activity_decisions')
          .doc(activityId)
          .update({
        'status': status,
      });
    } catch (e) {
      throw Exception('ステータスの更新に失敗しました: $e');
    }
  }

  /// 特定の活動情報を取得
  Future<ActivityDecisionModel?> getActivity(String activityId) async {
    try {
      final doc = await _firestore
          .collection('activity_decisions')
          .doc(activityId)
          .get();

      if (!doc.exists) return null;

      final activity = ActivityDecisionModel.fromFirestore(doc);

      // サークルへのアクセス権をチェック
      await _permissionService.requirePermission(
        activity.circleId,
        Permission.accessCircle,
      );

      return activity;
    } catch (e) {
      return null;
    }
  }

  /// サークルの活動統計を取得
  Future<Map<String, dynamic>> getActivityStats(String circleId) async {
    await _permissionService.requirePermission(circleId, Permission.accessCircle);

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // 今月の活動数
      final thisMonthSnapshot = await _firestore
          .collection('activity_decisions')
          .where('circleId', isEqualTo: circleId)
          .where('activityDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      // 総活動数
      final totalSnapshot = await _firestore
          .collection('activity_decisions')
          .where('circleId', isEqualTo: circleId)
          .get();

      // 今月の参加者数の平均
      double averageParticipants = 0.0;
      if (thisMonthSnapshot.docs.isNotEmpty) {
        int totalParticipants = 0;
        for (final doc in thisMonthSnapshot.docs) {
          final activity = ActivityDecisionModel.fromFirestore(doc);
          totalParticipants += activity.actualParticipants.length;
        }
        averageParticipants = totalParticipants / thisMonthSnapshot.docs.length;
      }

      return {
        'totalActivities': totalSnapshot.docs.length,
        'thisMonthActivities': thisMonthSnapshot.docs.length,
        'averageParticipants': averageParticipants.round(),
      };
    } catch (e) {
      throw Exception('活動統計の取得に失敗しました: $e');
    }
  }

  /// ユーザーの参加履歴を取得
  Future<List<ActivityDecisionModel>> getUserActivityHistory(
    String circleId, [
    String? userId,
  ]) async {
    userId ??= currentUserId;
    if (userId == null) throw Exception('ログインが必要です');

    await _permissionService.requirePermission(circleId, Permission.accessCircle);

    try {
      final snapshot = await _firestore
          .collection('activity_decisions')
          .where('circleId', isEqualTo: circleId)
          .where('actualParticipants', arrayContains: userId)
          .orderBy('activityDate', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => ActivityDecisionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('参加履歴の取得に失敗しました: $e');
    }
  }
}