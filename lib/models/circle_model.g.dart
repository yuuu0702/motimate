// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CircleModelImpl _$$CircleModelImplFromJson(
  Map<String, dynamic> json,
) => _$CircleModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  creatorId: json['creatorId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  settings: CircleSettings.fromJson(json['settings'] as Map<String, dynamic>),
  privacy: PrivacySettings.fromJson(json['privacy'] as Map<String, dynamic>),
  stats: CircleStats.fromJson(json['stats'] as Map<String, dynamic>),
  inviteCode: json['inviteCode'] as String?,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$CircleModelImplToJson(_$CircleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'creatorId': instance.creatorId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'settings': instance.settings,
      'privacy': instance.privacy,
      'stats': instance.stats,
      'inviteCode': instance.inviteCode,
      'isActive': instance.isActive,
    };

_$CircleSettingsImpl _$$CircleSettingsImplFromJson(Map<String, dynamic> json) =>
    _$CircleSettingsImpl(
      iconType: json['iconType'] as String? ?? 'groups',
      colorTheme: json['colorTheme'] as String? ?? 'blue',
      activityName: json['activityName'] as String? ?? '活動',
      customSettings:
          json['customSettings'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
    );

Map<String, dynamic> _$$CircleSettingsImplToJson(
  _$CircleSettingsImpl instance,
) => <String, dynamic>{
  'iconType': instance.iconType,
  'colorTheme': instance.colorTheme,
  'activityName': instance.activityName,
  'customSettings': instance.customSettings,
};

_$PrivacySettingsImpl _$$PrivacySettingsImplFromJson(
  Map<String, dynamic> json,
) => _$PrivacySettingsImpl(
  isPublic: json['isPublic'] as bool? ?? true,
  searchable: json['searchable'] as bool? ?? true,
  requiresApproval: json['requiresApproval'] as bool? ?? false,
  showMemberCount: json['showMemberCount'] as bool? ?? true,
  showActivity: json['showActivity'] as bool? ?? true,
);

Map<String, dynamic> _$$PrivacySettingsImplToJson(
  _$PrivacySettingsImpl instance,
) => <String, dynamic>{
  'isPublic': instance.isPublic,
  'searchable': instance.searchable,
  'requiresApproval': instance.requiresApproval,
  'showMemberCount': instance.showMemberCount,
  'showActivity': instance.showActivity,
};

_$CircleStatsImpl _$$CircleStatsImplFromJson(Map<String, dynamic> json) =>
    _$CircleStatsImpl(
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      activityCount: (json['activityCount'] as num?)?.toInt() ?? 0,
      lastActivityAt: json['lastActivityAt'] == null
          ? null
          : DateTime.parse(json['lastActivityAt'] as String),
    );

Map<String, dynamic> _$$CircleStatsImplToJson(_$CircleStatsImpl instance) =>
    <String, dynamic>{
      'memberCount': instance.memberCount,
      'activityCount': instance.activityCount,
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
    };
