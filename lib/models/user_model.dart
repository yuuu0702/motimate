import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String username,
    required String displayName,
    required String department,
    required String group,
    @Default(false) bool profileSetup,
    @Default(3) int latestMotivationLevel,
    DateTime? latestMotivationTimestamp,
    String? latestMotivationComment,
    List<DateTime>? nextPlayDates,
    DateTime? lastLogin,
    String? fcmToken,
    @Default(false) bool notificationsEnabled,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      department: data['department'] ?? '',
      group: data['group'] ?? '',
      profileSetup: data['profileSetup'] ?? false,
      latestMotivationLevel: data['latestMotivationLevel'] ?? 3,
      latestMotivationTimestamp: data['latestMotivationTimestamp'] != null
          ? (data['latestMotivationTimestamp'] as Timestamp).toDate()
          : null,
      latestMotivationComment: data['latestMotivationComment'],
      nextPlayDates: data['nextPlayDates'] != null
          ? (data['nextPlayDates'] as List<dynamic>)
              .map((timestamp) => (timestamp as Timestamp).toDate())
              .toList()
          : null,
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
      fcmToken: data['fcmToken'],
      notificationsEnabled: data['notificationsEnabled'] ?? false,
    );
  }
}

extension UserModelX on UserModel {
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'displayName': displayName,
      'department': department,
      'group': group,
      'profileSetup': profileSetup,
      'latestMotivationLevel': latestMotivationLevel,
      'latestMotivationTimestamp': latestMotivationTimestamp != null
          ? Timestamp.fromDate(latestMotivationTimestamp!)
          : null,
      'latestMotivationComment': latestMotivationComment,
      'nextPlayDates': nextPlayDates
          ?.map((date) => Timestamp.fromDate(date))
          .toList(),
      'lastLogin': lastLogin != null
          ? Timestamp.fromDate(lastLogin!)
          : null,
      'fcmToken': fcmToken,
      'notificationsEnabled': notificationsEnabled,
    };
  }
}