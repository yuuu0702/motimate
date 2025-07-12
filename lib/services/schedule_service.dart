import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/schedule_model.dart';

/// 日程管理サービス
/// 
/// 日程候補の取得、人気の日程取得、次回練習日の管理を担当
class ScheduleService {
  ScheduleService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// 次回の練習日程を取得
  Future<List<DateTime>> getNextPlayDates() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamps = data['nextPlayDates'] as List<dynamic>? ?? [];
        return timestamps
            .cast<Timestamp>()
            .map((timestamp) => timestamp.toDate())
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('次回練習日の取得に失敗しました: $e');
    }
  }

  /// 人気の日程を取得（参加可能人数順）
  Future<List<ScheduleModel>> getPopularDates() async {
    try {
      final snapshot = await _firestore
          .collection('schedules')
          .where('isActive', isEqualTo: true)
          .orderBy('memberCount', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        return ScheduleModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception('人気の日程取得に失敗しました: $e');
    }
  }

  /// 日程を決定
  Future<void> decidePracticeDate(ScheduleModel schedule) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    try {
      final batch = _firestore.batch();

      // 新しい練習決定を作成
      final practiceRef = _firestore.collection('practices').doc();
      batch.set(practiceRef, {
        'scheduleId': schedule.id,
        'practiceDate': Timestamp.fromDate(schedule.date),
        'decidedBy': user.uid,
        'decidedAt': FieldValue.serverTimestamp(),
        'responses': <String, dynamic>{},
        'isActive': true,
      });

      // 対応するスケジュールを非アクティブにする
      final scheduleRef = _firestore.collection('schedules').doc(schedule.id);
      batch.update(scheduleRef, {'isActive': false});

      await batch.commit();
    } catch (e) {
      throw Exception('日程決定に失敗しました: $e');
    }
  }
}