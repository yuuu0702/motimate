// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gymnasium_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GymnasiumModelImpl _$$GymnasiumModelImplFromJson(Map<String, dynamic> json) =>
    _$GymnasiumModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      location: LatLng.fromJson(json['location'] as Map<String, dynamic>),
      facilities:
          (json['facilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      fees:
          (json['fees'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      description: json['description'] as String?,
      openingHours: json['openingHours'] as String?,
      closedDays: json['closedDays'] as String?,
      parkingSpaces: (json['parkingSpaces'] as num?)?.toInt(),
      accessInfo: json['accessInfo'] as String?,
    );

Map<String, dynamic> _$$GymnasiumModelImplToJson(
  _$GymnasiumModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'location': instance.location,
  'facilities': instance.facilities,
  'fees': instance.fees,
  'phone': instance.phone,
  'website': instance.website,
  'images': instance.images,
  'description': instance.description,
  'openingHours': instance.openingHours,
  'closedDays': instance.closedDays,
  'parkingSpaces': instance.parkingSpaces,
  'accessInfo': instance.accessInfo,
};

_$LatLngImpl _$$LatLngImplFromJson(Map<String, dynamic> json) => _$LatLngImpl(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$$LatLngImplToJson(_$LatLngImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
