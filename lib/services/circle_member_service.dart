import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/circle_model.dart';
import '../models/circle_member_model.dart';
import '../models/user_model.dart';
import 'permission_service.dart';
import 'circle_service.dart';

/// サークルメンバー管理サービス
///
/// サークル参加、脱退、メンバー管理を担当
class CircleMemberService {
  CircleMemberService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    PermissionService? permissionService,
    CircleService? circleService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _permissionService = permissionService ?? PermissionService(),
        _circleService = circleService ?? CircleService();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final PermissionService _permissionService;
  final CircleService _circleService;

  /// 現在のユーザーIDを取得
  String? get currentUserId => _auth.currentUser?.uid;

  /// サークルに参加
  Future<void> joinCircle({
    required String circleId,
    String? inviteCode,
    String? joinMessage,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('ログインが必要です');

    try {
      // サークル情報を取得
      final circle = await _circleService.getCircle(circleId);
      if (circle == null) throw CircleMemberException('サークルが見つかりません', 'CIRCLE_NOT_FOUND');

      // 既に参加しているかチェック
      final existingMember = await _permissionService.getMemberInfo(circleId, userId);
      if (existingMember != null) {
        if (existingMember.status == MemberStatus.active) {
          throw CircleMemberException('既に参加しています', 'ALREADY_MEMBER');
        } else if (existingMember.status == MemberStatus.pending) {
          throw CircleMemberException('参加申請中です', 'ALREADY_PENDING');
        }
      }

      // 招待コードが必要な場合はチェック
      if (!circle.privacy.isPublic &&
          (inviteCode == null || inviteCode != circle.inviteCode)) {
        throw CircleMemberException('正しい招待コードが必要です', 'INVALID_INVITE_CODE');
      }

      final now = DateTime.now();
      final memberId = CircleMemberModel.generateId(circleId, userId);

      // 承認が必要かどうかを判断
      final requiresApproval = circle.privacy.requiresApproval;
      final status = requiresApproval ? MemberStatus.pending : MemberStatus.active;

      final member = CircleMemberModel(
        id: memberId,
        circleId: circleId,
        userId: userId,
        role: MemberRole.member,
        status: status,
        joinedAt: now,
        approvedAt: requiresApproval ? null : now,
        approvedBy: requiresApproval ? null : userId,
        joinMessage: joinMessage?.trim(),
        stats: const MemberStats(),
      );

      await _firestore
          .collection('circle_members')
          .doc(memberId)
          .set(member.toFirestore());

      // 承認不要の場合はユーザーのサークルリストを更新
      if (!requiresApproval) {
        await _updateUserCircleList(userId, circleId, add: true);
        await _circleService.updateCircleStats(circleId);
      }
    } catch (e) {
      if (e is CircleMemberException) rethrow;
      throw Exception('サークル参加に失敗しました: $e');
    }
  }

  /// 参加申請を承認
  Future<void> approveMember(String circleId, String userId) async {
    await _permissionService.requirePermission(circleId, Permission.manageMembers);

    try {
      final memberId = CircleMemberModel.generateId(circleId, userId);
      final approverId = currentUserId!;

      await _firestore
          .collection('circle_members')
          .doc(memberId)
          .update({
        'status': MemberStatus.active.value,
        'approvedAt': Timestamp.fromDate(DateTime.now()),
        'approvedBy': approverId,
      });

      // ユーザーのサークルリストを更新
      await _updateUserCircleList(userId, circleId, add: true);
      await _circleService.updateCircleStats(circleId);
    } catch (e) {
      throw Exception('メンバーの承認に失敗しました: $e');
    }
  }

  /// 参加申請を拒否
  Future<void> rejectMember(String circleId, String userId) async {
    await _permissionService.requirePermission(circleId, Permission.manageMembers);

    try {
      final memberId = CircleMemberModel.generateId(circleId, userId);

      await _firestore
          .collection('circle_members')
          .doc(memberId)
          .delete();
    } catch (e) {
      throw Exception('参加申請の拒否に失敗しました: $e');
    }
  }

  /// メンバーの権限を変更
  Future<void> updateMemberRole(String circleId, String userId, MemberRole newRole) async {
    // 権限変更の可否をチェック
    final canChange = await _permissionService.canChangeRole(circleId, newRole);
    if (!canChange) {
      throw CircleMemberException('権限を変更する権限がありません', 'PERMISSION_DENIED');
    }

    try {
      final memberId = CircleMemberModel.generateId(circleId, userId);

      await _firestore
          .collection('circle_members')
          .doc(memberId)
          .update({
        'role': newRole.value,
      });
    } catch (e) {
      throw Exception('メンバー権限の変更に失敗しました: $e');
    }
  }

  /// メンバーを除名
  Future<void> removeMember(String circleId, String userId) async {
    await _permissionService.requirePermission(circleId, Permission.manageMembers);

    // 作成者は除名できない
    final targetRole = await _permissionService.getUserRole(circleId, userId);
    if (targetRole?.isCreator == true) {
      throw CircleMemberException('作成者は除名できません', 'CANNOT_REMOVE_CREATOR');
    }

    try {
      final memberId = CircleMemberModel.generateId(circleId, userId);

      await _firestore
          .collection('circle_members')
          .doc(memberId)
          .update({
        'status': MemberStatus.banned.value,
      });

      // ユーザーのサークルリストから削除
      await _updateUserCircleList(userId, circleId, add: false);
      await _circleService.updateCircleStats(circleId);
    } catch (e) {
      throw Exception('メンバーの除名に失敗しました: $e');
    }
  }

  /// サークルから脱退
  Future<void> leaveCircle(String circleId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('ログインが必要です');

    // 作成者は脱退できない
    final role = await _permissionService.getUserRole(circleId, userId);
    if (role?.isCreator == true) {
      throw CircleMemberException('作成者は脱退できません', 'CREATOR_CANNOT_LEAVE');
    }

    try {
      final memberId = CircleMemberModel.generateId(circleId, userId);

      await _firestore
          .collection('circle_members')
          .doc(memberId)
          .update({
        'status': MemberStatus.inactive.value,
      });

      // ユーザーのサークルリストから削除
      await _updateUserCircleList(userId, circleId, add: false);
      await _circleService.updateCircleStats(circleId);
    } catch (e) {
      throw Exception('サークル脱退に失敗しました: $e');
    }
  }

  /// サークルメンバー一覧を取得
  Future<List<CircleMemberModel>> getCircleMembers(
    String circleId, {
    MemberStatus? status,
    MemberRole? role,
    int? limit,
  }) async {
    await _permissionService.requirePermission(circleId, Permission.accessCircle);

    try {
      Query query = _firestore
          .collection('circle_members')
          .where('circleId', isEqualTo: circleId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      if (role != null) {
        query = query.where('role', isEqualTo: role.value);
      }

      query = query.orderBy('joinedAt');

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => CircleMemberModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('メンバー一覧の取得に失敗しました: $e');
    }
  }

  /// アクティブメンバー一覧を取得
  Future<List<CircleMemberModel>> getActiveMembers(String circleId) async {
    return await getCircleMembers(
      circleId,
      status: MemberStatus.active,
    );
  }

  /// 参加申請一覧を取得
  Future<List<CircleMemberModel>> getPendingMembers(String circleId) async {
    await _permissionService.requirePermission(circleId, Permission.manageMembers);

    return await getCircleMembers(
      circleId,
      status: MemberStatus.pending,
    );
  }

  /// メンバー情報を取得（ユーザー情報付き）
  Future<List<Map<String, dynamic>>> getMembersWithUserInfo(String circleId) async {
    final members = await getActiveMembers(circleId);
    final membersWithUserInfo = <Map<String, dynamic>>[];

    for (final member in members) {
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(member.userId)
            .get();

        if (userDoc.exists) {
          final user = UserModel.fromFirestore(userDoc);
          membersWithUserInfo.add({
            'member': member,
            'user': user,
          });
        }
      } catch (e) {
        // ユーザー情報の取得に失敗してもメンバー情報は含める
        membersWithUserInfo.add({
          'member': member,
          'user': null,
        });
      }
    }

    return membersWithUserInfo;
  }

  /// メンバーの統計を更新
  Future<void> updateMemberStats(String circleId, String userId) async {
    try {
      // 参加回数を計算
      final activitiesSnapshot = await _firestore
          .collection('activity_decisions')
          .where('circleId', isEqualTo: circleId)
          .where('actualParticipants', arrayContains: userId)
          .get();

      final participationCount = activitiesSnapshot.docs.length;

      // モチベーション平均を計算（実装は後で追加）
      const motivationAverage = 0.0; // TODO: モチベーション履歴から計算

      final memberId = CircleMemberModel.generateId(circleId, userId);

      await _firestore
          .collection('circle_members')
          .doc(memberId)
          .update({
        'stats.participationCount': participationCount,
        'stats.motivationAverage': motivationAverage,
        'stats.lastActiveAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Failed to update member stats: $e');
    }
  }

  /// ユーザーのサークルリストを更新
  Future<void> _updateUserCircleList(String userId, String circleId, {required bool add}) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      if (add) {
        await userDoc.update({
          'circleIds': FieldValue.arrayUnion([circleId]),
          'currentCircleId': circleId,
          'lastAccessByCircle.$circleId': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        await userDoc.update({
          'circleIds': FieldValue.arrayRemove([circleId]),
        });

        // 現在のサークルだった場合は切り替え
        final userSnapshot = await userDoc.get();
        final userData = userSnapshot.data();
        if (userData?['currentCircleId'] == circleId) {
          final circleIds = List<String>.from(userData?['circleIds'] ?? []);
          final newCurrentCircle = circleIds.isNotEmpty ? circleIds.first : null;

          await userDoc.update({
            'currentCircleId': newCurrentCircle,
          });
        }

        await userDoc.update({
          'lastAccessByCircle.$circleId': FieldValue.delete(),
        });
      }
    } catch (e) {
      print('Failed to update user circle list: $e');
    }
  }
}

/// サークルメンバー関連エラー
class CircleMemberException implements Exception {
  final String message;
  final String code;
  const CircleMemberException(this.message, this.code);

  @override
  String toString() => 'CircleMemberException: $message';
}

/// 具体的なメンバー例外
class AlreadyMember extends CircleMemberException {
  const AlreadyMember() : super('既に参加しています', 'ALREADY_MEMBER');
}

class AlreadyPending extends CircleMemberException {
  const AlreadyPending() : super('参加申請中です', 'ALREADY_PENDING');
}

class CannotRemoveCreator extends CircleMemberException {
  const CannotRemoveCreator() : super('作成者は除名できません', 'CANNOT_REMOVE_CREATOR');
}

class CreatorCannotLeave extends CircleMemberException {
  const CreatorCannotLeave() : super('作成者は脱退できません', 'CREATOR_CANNOT_LEAVE');
}