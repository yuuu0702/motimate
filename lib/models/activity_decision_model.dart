import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_decision_model.freezed.dart';
part 'activity_decision_model.g.dart';

@freezed
class ActivityDecisionModel with _$ActivityDecisionModel {
  const factory ActivityDecisionModel({
    required String id,
    required String circleId, // 新規追加: サークルID
    required String decidedBy,
    required DateTime decidedAt,
    required DateTime activityDate, // practiceDate から変更
    required String dateKey,
    required List<String> availableMembers,
    @Default('pending') String status, // pending, confirmed, cancelled
    @Default(<String, String>{}) Map<String, String> responses,
    String? memo, // 活動に関するメモ
    @Default(<String>[]) List<String> actualParticipants, // 実際に参加した人のリスト
  }) = _ActivityDecisionModel;

  factory ActivityDecisionModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityDecisionModelFromJson(json);

  factory ActivityDecisionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityDecisionModel(
      id: doc.id,
      circleId: data['circleId'] ?? '',
      decidedBy: data['decidedBy'] ?? '',
      decidedAt: (data['decidedAt'] as Timestamp).toDate(),
      activityDate: (data['activityDate'] as Timestamp? ??
                     data['practiceDate'] as Timestamp).toDate(), // 後方互換性
      dateKey: data['dateKey'] ?? '',
      availableMembers: List<String>.from(data['availableMembers'] ?? []),
      status: data['status'] ?? 'pending',
      responses: Map<String, String>.from(data['responses'] ?? {}),
      memo: data['memo'],
      actualParticipants: List<String>.from(data['actualParticipants'] ?? []),
    );
  }
}

extension ActivityDecisionModelX on ActivityDecisionModel {
  Map<String, dynamic> toFirestore() {
    return {
      'circleId': circleId,
      'decidedBy': decidedBy,
      'decidedAt': Timestamp.fromDate(decidedAt),
      'activityDate': Timestamp.fromDate(activityDate),
      'dateKey': dateKey,
      'availableMembers': availableMembers,
      'status': status,
      'responses': responses,
      'memo': memo,
      'actualParticipants': actualParticipants,
    };
  }

  /// 参加予定人数
  int get joinCount => responses.values.where((r) => r == 'join').length;

  /// 見送り人数
  int get skipCount => responses.values.where((r) => r == 'skip').length;

  /// 未回答人数
  int get noResponseCount => availableMembers.length - responses.length;

  /// 特定ユーザーの回答を取得
  String? getUserResponse(String userId) => responses[userId];

  /// 特定ユーザーが参加予定かどうか
  bool isUserJoining(String userId) => responses[userId] == 'join';

  /// 特定ユーザーが見送りかどうか
  bool isUserSkipping(String userId) => responses[userId] == 'skip';

  /// 特定ユーザーが未回答かどうか
  bool isUserNotResponded(String userId) => !responses.containsKey(userId);

  /// 活動が今日かどうか
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDay = DateTime(
      activityDate.year,
      activityDate.month,
      activityDate.day,
    );
    return today == activityDay;
  }

  /// 活動が過去かどうか
  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDay = DateTime(
      activityDate.year,
      activityDate.month,
      activityDate.day,
    );
    return activityDay.isBefore(today);
  }

  /// 活動が未来かどうか
  bool get isFuture => !isPast && !isToday;
}