// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_decision_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PracticeDecisionModelImpl _$$PracticeDecisionModelImplFromJson(
  Map<String, dynamic> json,
) => _$PracticeDecisionModelImpl(
  id: json['id'] as String,
  decidedBy: json['decidedBy'] as String,
  decidedAt: DateTime.parse(json['decidedAt'] as String),
  practiceDate: DateTime.parse(json['practiceDate'] as String),
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
);

Map<String, dynamic> _$$PracticeDecisionModelImplToJson(
  _$PracticeDecisionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'decidedBy': instance.decidedBy,
  'decidedAt': instance.decidedAt.toIso8601String(),
  'practiceDate': instance.practiceDate.toIso8601String(),
  'dateKey': instance.dateKey,
  'availableMembers': instance.availableMembers,
  'status': instance.status,
  'responses': instance.responses,
};
