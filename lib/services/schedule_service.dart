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
      // 全てのスケジュールを取得
      final schedulesSnapshot = await _firestore
          .collection('schedules')
          .get();

      print('取得したスケジュール数: ${schedulesSnapshot.docs.length}');
      
      if (schedulesSnapshot.docs.isEmpty) {
        print('スケジュールデータがありません。');
        return <ScheduleModel>[];
      }

      final schedules = schedulesSnapshot.docs.map((doc) {
        return ScheduleModel.fromFirestore(doc);
      }).toList();

      // 決定済みの日程を除外
      final availableSchedules = await _filterAvailableSchedules(schedules);

      // クライアント側でソート（memberCount降順）
      availableSchedules.sort((a, b) => b.memberCount.compareTo(a.memberCount));

      return availableSchedules;
    } catch (e) {
      throw Exception('人気の日程取得に失敗しました: $e');
    }
  }
  
  /// 決定済みの日程を除外する
  Future<List<ScheduleModel>> _filterAvailableSchedules(List<ScheduleModel> schedules) async {
    try {
      // 決定済みの日程キーを取得
      final practiceDecisionsSnapshot = await _firestore
          .collection('practice_decisions')
          .get();
      
      final decidedDateKeys = practiceDecisionsSnapshot.docs
          .map((doc) => doc.data()['dateKey'] as String?)
          .where((dateKey) => dateKey != null)
          .map((dateKey) => dateKey!)
          .toSet();
      
      // 決定済みでない日程のみを返す
      return schedules.where((schedule) => !decidedDateKeys.contains(schedule.id)).toList();
    } catch (e) {
      print('決定済み日程のフィルタリングエラー: $e');
      return schedules; // エラー時は全て返す
    }
  }
  

  /// 日程を決定
  Future<void> decidePracticeDate(ScheduleModel schedule) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    try {
      final batch = _firestore.batch();

      // 新しい練習決定を作成
      final practiceRef = _firestore.collection('practice_decisions').doc();
      batch.set(practiceRef, {
        'decidedBy': user.uid,
        'decidedAt': FieldValue.serverTimestamp(),
        'practiceDate': Timestamp.fromDate(schedule.date),
        'dateKey': schedule.id,
        'availableMembers': schedule.members,
        'status': 'pending',
        'responses': <String, dynamic>{},
      });

      // 対応するスケジュールはそのまま残す（削除しない）
      // スケジュールデータは履歴として保持される

      await batch.commit();
    } catch (e) {
      throw Exception('日程決定に失敗しました: $e');
    }
  }
}