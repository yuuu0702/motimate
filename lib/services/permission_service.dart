import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/circle_member_model.dart';

/// 権限管理サービス
///
/// サークル内でのユーザーの権限チェック、役割管理を担当
class PermissionService {
  PermissionService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// 現在のユーザーIDを取得
  String? get currentUserId => _auth.currentUser?.uid;

  /// ユーザーの権限を取得
  Future<MemberRole?> getUserRole(String circleId, [String? userId]) async {
    userId ??= currentUserId;
    if (userId == null) return null;

    try {
      final memberId = CircleMemberModel.generateId(circleId, userId);
      final doc = await _firestore
          .collection('circle_members')
          .doc(memberId)
          .get();

      if (!doc.exists) return null;

      final member = CircleMemberModel.fromFirestore(doc);
      return member.isActive ? member.role : null;
    } catch (e) {
      return null;
    }
  }

  /// ユーザーのメンバーシップ情報を取得
  Future<CircleMemberModel?> getMemberInfo(String circleId, [String? userId]) async {
    userId ??= currentUserId;
    if (userId == null) return null;

    try {
      final memberId = CircleMemberModel.generateId(circleId, userId);
      final doc = await _firestore
          .collection('circle_members')
          .doc(memberId)
          .get();

      if (!doc.exists) return null;
      return CircleMemberModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// サークルにアクセス可能かどうか
  Future<bool> canAccessCircle(String circleId, [String? userId]) async {
    final role = await getUserRole(circleId, userId);
    return role != null;
  }

  /// サークル情報を編集可能かどうか
  Future<bool> canEditCircle(String circleId, [String? userId]) async {
    final role = await getUserRole(circleId, userId);
    return role?.isAdmin == true;
  }

  /// サークルを削除可能かどうか
  Future<bool> canDeleteCircle(String circleId, [String? userId]) async {
    final role = await getUserRole(circleId, userId);
    return role?.isCreator == true;
  }

  /// メンバーを管理可能かどうか
  Future<bool> canManageMembers(String circleId, [String? userId]) async {
    final role = await getUserRole(circleId, userId);
    return role?.isAdmin == true;
  }

  /// 活動日程を決定可能かどうか
  Future<bool> canDecideActivity(String circleId, [String? userId]) async {
    final role = await getUserRole(circleId, userId);
    return role?.isAdmin == true;
  }

  /// 活動に参加回答可能かどうか
  Future<bool> canRespondToActivity(String circleId, [String? userId]) async {
    final role = await getUserRole(circleId, userId);
    return role != null && role != MemberRole.guest;
  }

  /// モチベーションを更新可能かどうか
  Future<bool> canUpdateMotivation(String circleId, [String? userId]) async {
    final role = await getUserRole(circleId, userId);
    return role != null && role != MemberRole.guest;
  }

  /// 他のメンバーの権限を変更可能かどうか
  Future<bool> canChangeRole(
    String circleId,
    MemberRole targetRole, [
    String? userId,
  ]) async {
    final currentRole = await getUserRole(circleId, userId);
    if (currentRole == null) return false;

    // 作成者は全ての権限を変更可能
    if (currentRole.isCreator) return true;

    // 管理者はメンバーとゲストのみ変更可能
    if (currentRole == MemberRole.admin) {
      return [MemberRole.member, MemberRole.guest].contains(targetRole);
    }

    return false;
  }

  /// 特定の権限があるかどうかをチェック
  Future<bool> hasPermission(String circleId, Permission permission, [String? userId]) async {
    switch (permission) {
      case Permission.accessCircle:
        return await canAccessCircle(circleId, userId);
      case Permission.editCircle:
        return await canEditCircle(circleId, userId);
      case Permission.deleteCircle:
        return await canDeleteCircle(circleId, userId);
      case Permission.manageMembers:
        return await canManageMembers(circleId, userId);
      case Permission.decideActivity:
        return await canDecideActivity(circleId, userId);
      case Permission.respondToActivity:
        return await canRespondToActivity(circleId, userId);
      case Permission.updateMotivation:
        return await canUpdateMotivation(circleId, userId);
    }
  }

  /// 複数の権限を一括チェック
  Future<Map<Permission, bool>> checkPermissions(
    String circleId,
    List<Permission> permissions, [
    String? userId,
  ]) async {
    final results = <Permission, bool>{};

    for (final permission in permissions) {
      results[permission] = await hasPermission(circleId, permission, userId);
    }

    return results;
  }

  /// ユーザーが参加している全てのサークルの権限を取得
  Future<Map<String, MemberRole>> getUserAllCircleRoles([String? userId]) async {
    userId ??= currentUserId;
    if (userId == null) return {};

    try {
      final snapshot = await _firestore
          .collection('circle_members')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      final roles = <String, MemberRole>{};

      for (final doc in snapshot.docs) {
        final member = CircleMemberModel.fromFirestore(doc);
        roles[member.circleId] = member.role;
      }

      return roles;
    } catch (e) {
      return {};
    }
  }

  /// サークル内の管理者一覧を取得
  Future<List<CircleMemberModel>> getCircleAdmins(String circleId) async {
    try {
      final snapshot = await _firestore
          .collection('circle_members')
          .where('circleId', isEqualTo: circleId)
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs
          .map((doc) => CircleMemberModel.fromFirestore(doc))
          .where((member) => member.isAdmin)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 権限エラーを投げる
  void throwPermissionError([String? message]) {
    throw PermissionException(message ?? 'この操作を行う権限がありません');
  }

  /// 権限をチェックして、権限がない場合はエラーを投げる
  Future<void> requirePermission(String circleId, Permission permission, [String? userId]) async {
    final hasPermissionResult = await hasPermission(circleId, permission, userId);
    if (!hasPermissionResult) {
      throwPermissionError(_getPermissionErrorMessage(permission));
    }
  }

  /// 権限エラーメッセージを取得
  String _getPermissionErrorMessage(Permission permission) {
    switch (permission) {
      case Permission.accessCircle:
        return 'このサークルにアクセスする権限がありません';
      case Permission.editCircle:
        return 'サークル情報を編集する権限がありません';
      case Permission.deleteCircle:
        return 'サークルを削除する権限がありません';
      case Permission.manageMembers:
        return 'メンバーを管理する権限がありません';
      case Permission.decideActivity:
        return '活動日程を決定する権限がありません';
      case Permission.respondToActivity:
        return '活動に参加回答する権限がありません';
      case Permission.updateMotivation:
        return 'モチベーションを更新する権限がありません';
    }
  }
}

/// 権限の種類
enum Permission {
  accessCircle,      // サークルアクセス
  editCircle,        // サークル編集
  deleteCircle,      // サークル削除
  manageMembers,     // メンバー管理
  decideActivity,    // 活動決定
  respondToActivity, // 活動回答
  updateMotivation,  // モチベーション更新
}

/// 権限エラー
class PermissionException implements Exception {
  final String message;
  const PermissionException(this.message);

  @override
  String toString() => 'PermissionException: $message';
}