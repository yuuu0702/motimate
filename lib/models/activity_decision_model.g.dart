// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_decision_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityDecisionModelImpl _$$ActivityDecisionModelImplFromJson(
  Map<String, dynamic> json,
) => _$ActivityDecisionModelImpl(
  id: json['id'] as String,
  circleId: json['circleId'] as String,
  decidedBy: json['decidedBy'] as String,
  decidedAt: DateTime.parse(json['decidedAt'] as String),
  activityDate: DateTime.parse(json['activityDate'] as String),
  dateKey: json['dateKey'] as String,
  availableMembers: (json['availableMembers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: json['status'] as String? ?? 'pending',
  responses:
      (json['responses'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  memo: json['memo'] as String?,
  actualParticipants:
      (json['actualParticipants'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$$ActivityDecisionModelImplToJson(
  _$ActivityDecisionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'circleId': instance.circleId,
  'decidedBy': instance.decidedBy,
  'decidedAt': instance.decidedAt.toIso8601String(),
  'activityDate': instance.activityDate.toIso8601String(),
  'dateKey': instance.dateKey,
  'availableMembers': instance.availableMembers,
  'status': instance.status,
  'responses': instance.responses,
  'memo': instance.memo,
  'actualParticipants': instance.actualParticipants,
};
