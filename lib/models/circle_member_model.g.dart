// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CircleMemberModelImpl _$$CircleMemberModelImplFromJson(
  Map<String, dynamic> json,
) => _$CircleMemberModelImpl(
  id: json['id'] as String,
  circleId: json['circleId'] as String,
  userId: json['userId'] as String,
  role: $enumDecode(_$MemberRoleEnumMap, json['role']),
  status: $enumDecode(_$MemberStatusEnumMap, json['status']),
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  approvedAt: json['approvedAt'] == null
      ? null
      : DateTime.parse(json['approvedAt'] as String),
  approvedBy: json['approvedBy'] as String?,
  joinMessage: json['joinMessage'] as String?,
  stats: MemberStats.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$CircleMemberModelImplToJson(
  _$CircleMemberModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'circleId': instance.circleId,
  'userId': instance.userId,
  'role': _$MemberRoleEnumMap[instance.role]!,
  'status': _$MemberStatusEnumMap[instance.status]!,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'approvedAt': instance.approvedAt?.toIso8601String(),
  'approvedBy': instance.approvedBy,
  'joinMessage': instance.joinMessage,
  'stats': instance.stats,
};

const _$MemberRoleEnumMap = {
  MemberRole.creator: 'creator',
  MemberRole.admin: 'admin',
  MemberRole.member: 'member',
  MemberRole.guest: 'guest',
};

const _$MemberStatusEnumMap = {
  MemberStatus.pending: 'pending',
  MemberStatus.active: 'active',
  MemberStatus.inactive: 'inactive',
  MemberStatus.banned: 'banned',
};

_$MemberStatsImpl _$$MemberStatsImplFromJson(Map<String, dynamic> json) =>
    _$MemberStatsImpl(
      participationCount: (json['participationCount'] as num?)?.toInt() ?? 0,
      motivationAverage: (json['motivationAverage'] as num?)?.toDouble() ?? 0.0,
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
    );

Map<String, dynamic> _$$MemberStatsImplToJson(_$MemberStatsImpl instance) =>
    <String, dynamic>{
      'participationCount': instance.participationCount,
      'motivationAverage': instance.motivationAverage,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
    };
