import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'circle_member_model.freezed.dart';
part 'circle_member_model.g.dart';

@freezed
class CircleMemberModel with _$CircleMemberModel {
  const factory CircleMemberModel({
    required String id,
    required String circleId,
    required String userId,
    required MemberRole role,
    required MemberStatus status,
    required DateTime joinedAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? joinMessage,
    required MemberStats stats,
  }) = _CircleMemberModel;

  factory CircleMemberModel.fromJson(Map<String, dynamic> json) =>
      _$CircleMemberModelFromJson(json);

  factory CircleMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CircleMemberModel(
      id: doc.id,
      circleId: data['circleId'] ?? '',
      userId: data['userId'] ?? '',
      role: MemberRole.fromString(data['role'] ?? 'member'),
      status: MemberStatus.fromString(data['status'] ?? 'active'),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      approvedAt: data['approvedAt'] != null
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
      approvedBy: data['approvedBy'],
      joinMessage: data['joinMessage'],
      stats: MemberStats.fromJson(data['stats'] ?? {}),
    );
  }
}

extension CircleMemberModelX on CircleMemberModel {
  Map<String, dynamic> toFirestore() {
    return {
      'circleId': circleId,
      'userId': userId,
      'role': role.value,
      'status': status.value,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'approvedAt': approvedAt != null
          ? Timestamp.fromDate(approvedAt!)
          : null,
      'approvedBy': approvedBy,
      'joinMessage': joinMessage,
      'stats': stats.toJson(),
    };
  }

  /// メンバーがアクティブかどうか
  bool get isActive => status == MemberStatus.active;

  /// メンバーが管理者権限を持っているかどうか
  bool get isAdmin => role == MemberRole.creator || role == MemberRole.admin;

  /// メンバーがサークル作成者かどうか
  bool get isCreator => role == MemberRole.creator;

  /// 複合ID（circleId_userId）を生成
  static String generateId(String circleId, String userId) {
    return '${circleId}_$userId';
  }
}

@freezed
class MemberStats with _$MemberStats {
  const factory MemberStats({
    @Default(0) int participationCount,
    @Default(0.0) double motivationAverage,
    DateTime? lastActiveAt,
  }) = _MemberStats;

  factory MemberStats.fromJson(Map<String, dynamic> json) =>
      _$MemberStatsFromJson(json);
}

/// メンバーの権限レベル
enum MemberRole {
  creator('creator', '作成者'),
  admin('admin', '管理者'),
  member('member', 'メンバー'),
  guest('guest', 'ゲスト');

  const MemberRole(this.value, this.displayName);

  final String value;
  final String displayName;

  static MemberRole fromString(String value) {
    return MemberRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => MemberRole.member,
    );
  }

  /// 管理者権限を持っているかどうか
  bool get isAdmin => this == MemberRole.creator || this == MemberRole.admin;

  /// 作成者権限を持っているかどうか
  bool get isCreator => this == MemberRole.creator;
}

/// メンバーのステータス
enum MemberStatus {
  pending('pending', '承認待ち'),
  active('active', 'アクティブ'),
  inactive('inactive', '非アクティブ'),
  banned('banned', '追放');

  const MemberStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static MemberStatus fromString(String value) {
    return MemberStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => MemberStatus.active,
    );
  }

  /// メンバーがアクティブかどうか
  bool get isActive => this == MemberStatus.active;

  /// 承認が必要かどうか
  bool get isPending => this == MemberStatus.pending;
}