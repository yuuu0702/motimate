import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/circle_model.dart';
import '../models/circle_member_model.dart';
import 'permission_service.dart';

/// サークル管理サービス
///
/// サークルの作成、更新、削除、検索を担当
class CircleService {
  CircleService({
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

  /// サークルを作成
  Future<String> createCircle({
    required String name,
    required String description,
    required String category,
    required CircleSettings settings,
    required PrivacySettings privacy,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('ログインが必要です');

    try {
      final now = DateTime.now();
      final circleId = _firestore.collection('circles').doc().id;

      // サークル情報を作成
      final circle = CircleModel(
        id: circleId,
        name: name.trim(),
        description: description.trim(),
        category: category,
        creatorId: userId,
        createdAt: now,
        updatedAt: now,
        settings: settings,
        privacy: privacy,
        stats: const CircleStats(),
        inviteCode: _generateInviteCode(),
        isActive: true,
      );

      // Firestoreにサークルを保存
      await _firestore
          .collection('circles')
          .doc(circleId)
          .set(circle.toFirestore());

      // 作成者をメンバーとして追加
      final creatorMember = CircleMemberModel(
        id: CircleMemberModelX.generateId(circleId, userId),
        circleId: circleId,
        userId: userId,
        role: MemberRole.creator,
        status: MemberStatus.active,
        joinedAt: now,
        approvedAt: now,
        approvedBy: userId,
        stats: const MemberStats(),
      );

      await _firestore
          .collection('circle_members')
          .doc(creatorMember.id)
          .set(creatorMember.toFirestore());

      // ユーザーのサークルリストを更新
      await _updateUserCircleList(userId, circleId, add: true);

      return circleId;
    } catch (e) {
      throw Exception('サークルの作成に失敗しました: $e');
    }
  }

  /// サークル情報を更新
  Future<void> updateCircle(
    String circleId, {
    String? name,
    String? description,
    String? category,
    CircleSettings? settings,
    PrivacySettings? privacy,
  }) async {
    await _permissionService.requirePermission(circleId, Permission.editCircle);

    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) updates['name'] = name.trim();
      if (description != null) updates['description'] = description.trim();
      if (category != null) updates['category'] = category;
      if (settings != null) updates['settings'] = settings.toJson();
      if (privacy != null) updates['privacy'] = privacy.toJson();

      await _firestore
          .collection('circles')
          .doc(circleId)
          .update(updates);
    } catch (e) {
      throw Exception('サークル情報の更新に失敗しました: $e');
    }
  }

  /// サークルを削除（非アクティブ化）
  Future<void> deleteCircle(String circleId) async {
    await _permissionService.requirePermission(circleId, Permission.deleteCircle);

    try {
      // サークルを非アクティブ化
      await _firestore
          .collection('circles')
          .doc(circleId)
          .update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // 全メンバーを非アクティブ化
      final membersSnapshot = await _firestore
          .collection('circle_members')
          .where('circleId', isEqualTo: circleId)
          .get();

      final batch = _firestore.batch();

      for (final doc in membersSnapshot.docs) {
        batch.update(doc.reference, {
          'status': MemberStatus.inactive.value,
        });

        // ユーザーのサークルリストからも削除
        final member = CircleMemberModel.fromFirestore(doc);
        _updateUserCircleList(member.userId, circleId, add: false);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('サークルの削除に失敗しました: $e');
    }
  }

  /// サークル情報を取得
  Future<CircleModel?> getCircle(String circleId) async {
    try {
      final doc = await _firestore
          .collection('circles')
          .doc(circleId)
          .get();

      if (!doc.exists) return null;

      final circle = CircleModel.fromFirestore(doc);

      // プライベートサークルの場合はアクセス権をチェック
      if (!circle.privacy.isPublic) {
        final canAccess = await _permissionService.canAccessCircle(circleId);
        if (!canAccess) return null;
      }

      return circle;
    } catch (e) {
      return null;
    }
  }

  /// サークルを検索
  Future<List<CircleModel>> searchCircles({
    String? keyword,
    String? category,
    bool publicOnly = true,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('circles')
          .where('isActive', isEqualTo: true);

      if (publicOnly) {
        query = query.where('privacy.isPublic', isEqualTo: true);
      }

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      query = query
          .orderBy('stats.memberCount', descending: true)
          .limit(limit);

      final snapshot = await query.get();

      List<CircleModel> circles = snapshot.docs
          .map((doc) => CircleModel.fromFirestore(doc))
          .toList();

      // キーワード検索（クライアントサイドフィルタリング）
      if (keyword != null && keyword.isNotEmpty) {
        final lowerKeyword = keyword.toLowerCase();
        circles = circles.where((circle) {
          return circle.name.toLowerCase().contains(lowerKeyword) ||
                 circle.description.toLowerCase().contains(lowerKeyword);
        }).toList();
      }

      return circles;
    } catch (e) {
      throw Exception('サークルの検索に失敗しました: $e');
    }
  }

  /// 招待コードでサークルを検索
  Future<CircleModel?> findByInviteCode(String inviteCode) async {
    try {
      final snapshot = await _firestore
          .collection('circles')
          .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return CircleModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      return null;
    }
  }

  /// ユーザーの参加サークル一覧を取得
  Future<List<CircleModel>> getUserCircles([String? userId]) async {
    userId ??= currentUserId;
    if (userId == null) return [];

    try {
      // ユーザーのメンバーシップを取得
      final membersSnapshot = await _firestore
          .collection('circle_members')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: MemberStatus.active.value)
          .get();

      if (membersSnapshot.docs.isEmpty) return [];

      // サークルIDリストを取得
      final circleIds = membersSnapshot.docs
          .map((doc) => CircleMemberModel.fromFirestore(doc).circleId)
          .toList();

      // サークル情報を一括取得
      final circles = <CircleModel>[];

      for (final circleId in circleIds) {
        final circle = await getCircle(circleId);
        if (circle != null && circle.isActive) {
          circles.add(circle);
        }
      }

      // 最終アクセス順でソート
      circles.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return circles;
    } catch (e) {
      throw Exception('参加サークル一覧の取得に失敗しました: $e');
    }
  }

  /// サークルの統計情報を更新
  Future<void> updateCircleStats(String circleId) async {
    try {
      // メンバー数を取得
      final membersSnapshot = await _firestore
          .collection('circle_members')
          .where('circleId', isEqualTo: circleId)
          .where('status', isEqualTo: MemberStatus.active.value)
          .get();

      // 活動数を取得
      final activitiesSnapshot = await _firestore
          .collection('activity_decisions')
          .where('circleId', isEqualTo: circleId)
          .get();

      // 最終活動日を取得
      DateTime? lastActivityAt;
      if (activitiesSnapshot.docs.isNotEmpty) {
        final activities = activitiesSnapshot.docs
            .map((doc) => doc.data()['activityDate'] as Timestamp?)
            .where((timestamp) => timestamp != null)
            .map((timestamp) => timestamp!.toDate())
            .toList();

        if (activities.isNotEmpty) {
          activities.sort((a, b) => b.compareTo(a));
          lastActivityAt = activities.first;
        }
      }

      // 統計情報を更新
      await _firestore
          .collection('circles')
          .doc(circleId)
          .update({
        'stats.memberCount': membersSnapshot.docs.length,
        'stats.activityCount': activitiesSnapshot.docs.length,
        'stats.lastActivityAt': lastActivityAt != null
            ? Timestamp.fromDate(lastActivityAt)
            : null,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      // 統計更新エラーは致命的ではないのでログのみ
      print('Statistics update failed for circle $circleId: $e');
    }
  }

  /// 招待コードを再生成
  Future<String> regenerateInviteCode(String circleId) async {
    await _permissionService.requirePermission(circleId, Permission.editCircle);

    try {
      final newCode = _generateInviteCode();

      await _firestore
          .collection('circles')
          .doc(circleId)
          .update({
        'inviteCode': newCode,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return newCode;
    } catch (e) {
      throw Exception('招待コードの再生成に失敗しました: $e');
    }
  }

  /// ユーザーのサークルリストを更新
  Future<void> _updateUserCircleList(String userId, String circleId, {required bool add}) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      if (add) {
        await userDoc.update({
          'circleIds': FieldValue.arrayUnion([circleId]),
          'currentCircleId': circleId, // 新規参加時は現在のサークルに設定
          'lastAccessByCircle.$circleId': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        // サークルから削除
        await userDoc.update({
          'circleIds': FieldValue.arrayRemove([circleId]),
        });

        // 現在のサークルだった場合は別のサークルに切り替え
        final userSnapshot = await userDoc.get();
        final userData = userSnapshot.data();
        if (userData?['currentCircleId'] == circleId) {
          final circleIds = List<String>.from(userData?['circleIds'] ?? []);
          final newCurrentCircle = circleIds.isNotEmpty ? circleIds.first : null;

          await userDoc.update({
            'currentCircleId': newCurrentCircle,
          });
        }

        // アクセス履歴からも削除
        await userDoc.update({
          'lastAccessByCircle.$circleId': FieldValue.delete(),
        });
      }
    } catch (e) {
      print('Failed to update user circle list: $e');
    }
  }

  /// 招待コードを生成
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }
}

/// サークル関連エラー
class CircleException implements Exception {
  final String message;
  final String code;
  const CircleException(this.message, this.code);

  @override
  String toString() => 'CircleException: $message';
}

/// 具体的なサークル例外
class CircleNotFound extends CircleException {
  const CircleNotFound() : super('サークルが見つかりません', 'CIRCLE_NOT_FOUND');
}

class CircleAlreadyExists extends CircleException {
  const CircleAlreadyExists() : super('同名のサークルが既に存在します', 'CIRCLE_ALREADY_EXISTS');
}

class InvalidInviteCode extends CircleException {
  const InvalidInviteCode() : super('招待コードが無効です', 'INVALID_INVITE_CODE');
}