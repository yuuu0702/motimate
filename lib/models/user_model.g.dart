// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['uid'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      department: json['department'] as String,
      group: json['group'] as String,
      profileSetup: json['profileSetup'] as bool? ?? false,
      latestMotivationLevel:
          (json['latestMotivationLevel'] as num?)?.toInt() ?? 3,
      latestMotivationTimestamp: json['latestMotivationTimestamp'] == null
          ? null
          : DateTime.parse(json['latestMotivationTimestamp'] as String),
      latestMotivationComment: json['latestMotivationComment'] as String?,
      nextPlayDates: (json['nextPlayDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
      lastLogin: json['lastLogin'] == null
          ? null
          : DateTime.parse(json['lastLogin'] as String),
      fcmToken: json['fcmToken'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'displayName': instance.displayName,
      'department': instance.department,
      'group': instance.group,
      'profileSetup': instance.profileSetup,
      'latestMotivationLevel': instance.latestMotivationLevel,
      'latestMotivationTimestamp': instance.latestMotivationTimestamp
          ?.toIso8601String(),
      'latestMotivationComment': instance.latestMotivationComment,
      'nextPlayDates': instance.nextPlayDates
          ?.map((e) => e.toIso8601String())
          .toList(),
      'lastLogin': instance.lastLogin?.toIso8601String(),
      'fcmToken': instance.fcmToken,
      'notificationsEnabled': instance.notificationsEnabled,
    };
