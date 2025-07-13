// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserLocationModelImpl _$$UserLocationModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserLocationModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  location: LatLng.fromJson(json['location'] as Map<String, dynamic>),
  type:
      $enumDecodeNullable(_$LocationTypeEnumMap, json['type']) ??
      LocationType.other,
  isPrimary: json['isPrimary'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$UserLocationModelImplToJson(
  _$UserLocationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'address': instance.address,
  'location': instance.location,
  'type': _$LocationTypeEnumMap[instance.type]!,
  'isPrimary': instance.isPrimary,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$LocationTypeEnumMap = {
  LocationType.home: 'home',
  LocationType.work: 'work',
  LocationType.school: 'school',
  LocationType.other: 'other',
};

_$GymnasiumRecommendationImpl _$$GymnasiumRecommendationImplFromJson(
  Map<String, dynamic> json,
) => _$GymnasiumRecommendationImpl(
  gymnasium: GymnasiumModel.fromJson(json['gymnasium'] as Map<String, dynamic>),
  score: (json['score'] as num).toDouble(),
  averageDistance: (json['averageDistance'] as num).toDouble(),
  maxDistance: (json['maxDistance'] as num).toDouble(),
  minDistance: (json['minDistance'] as num).toDouble(),
  accessibilityComment: json['accessibilityComment'] as String?,
  participantLocations:
      (json['participantLocations'] as List<dynamic>?)
          ?.map((e) => ParticipantLocation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$GymnasiumRecommendationImplToJson(
  _$GymnasiumRecommendationImpl instance,
) => <String, dynamic>{
  'gymnasium': instance.gymnasium,
  'score': instance.score,
  'averageDistance': instance.averageDistance,
  'maxDistance': instance.maxDistance,
  'minDistance': instance.minDistance,
  'accessibilityComment': instance.accessibilityComment,
  'participantLocations': instance.participantLocations,
};

_$ParticipantLocationImpl _$$ParticipantLocationImplFromJson(
  Map<String, dynamic> json,
) => _$ParticipantLocationImpl(
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  location: UserLocationModel.fromJson(
    json['location'] as Map<String, dynamic>,
  ),
  distanceToGymnasium: (json['distanceToGymnasium'] as num).toDouble(),
);

Map<String, dynamic> _$$ParticipantLocationImplToJson(
  _$ParticipantLocationImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userName': instance.userName,
  'location': instance.location,
  'distanceToGymnasium': instance.distanceToGymnasium,
};
