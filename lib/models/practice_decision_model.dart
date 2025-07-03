import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'practice_decision_model.freezed.dart';
part 'practice_decision_model.g.dart';

@freezed
class PracticeDecisionModel with _$PracticeDecisionModel {
  const factory PracticeDecisionModel({
    required String id,
    required String decidedBy,
    required DateTime decidedAt,
    required DateTime practiceDate,
    required String dateKey,
    required List<String> availableMembers,
    @Default('pending') String status, // pending, confirmed, cancelled
    @Default(<String, String>{}) Map<String, String> responses,
  }) = _PracticeDecisionModel;

  factory PracticeDecisionModel.fromJson(Map<String, dynamic> json) =>
      _$PracticeDecisionModelFromJson(json);

  factory PracticeDecisionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PracticeDecisionModel(
      id: doc.id,
      decidedBy: data['decidedBy'] ?? '',
      decidedAt: (data['decidedAt'] as Timestamp).toDate(),
      practiceDate: (data['practiceDate'] as Timestamp).toDate(),
      dateKey: data['dateKey'] ?? '',
      availableMembers: List<String>.from(data['availableMembers'] ?? []),
      status: data['status'] ?? 'pending',
      responses: Map<String, String>.from(data['responses'] ?? {}),
    );
  }
}

extension PracticeDecisionModelX on PracticeDecisionModel {
  Map<String, dynamic> toFirestore() {
    return {
      'decidedBy': decidedBy,
      'decidedAt': Timestamp.fromDate(decidedAt),
      'practiceDate': Timestamp.fromDate(practiceDate),
      'dateKey': dateKey,
      'availableMembers': availableMembers,
      'status': status,
      'responses': responses,
    };
  }

  int get joinCount => responses.values.where((r) => r == 'join').length;
  int get skipCount => responses.values.where((r) => r == 'skip').length;
  int get noResponseCount => availableMembers.length - responses.length;
}