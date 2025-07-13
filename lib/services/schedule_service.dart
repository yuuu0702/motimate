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
        print('スケジュールデータがありません。テストデータを作成します。');
        await _createTestScheduleData();
        
        // テストデータ作成後に再取得
        final retrySnapshot = await _firestore
            .collection('schedules')
            .get();
        
        final schedules = retrySnapshot.docs.map((doc) {
          return ScheduleModel.fromFirestore(doc);
        }).toList();
        
        // 決定済みの日程を除外
        final availableSchedules = await _filterAvailableSchedules(schedules);
        
        // クライアント側でソート（memberCount降順）
        availableSchedules.sort((a, b) => b.memberCount.compareTo(a.memberCount));
        
        return availableSchedules;
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
          .map((doc) => (doc.data() as Map<String, dynamic>)['dateKey'] as String?)
          .where((dateKey) => dateKey != null)
          .cast<String>()
          .toSet();
      
      // 決定済みでない日程のみを返す
      return schedules.where((schedule) => !decidedDateKeys.contains(schedule.id)).toList();
    } catch (e) {
      print('決定済み日程のフィルタリングエラー: $e');
      return schedules; // エラー時は全て返す
    }
  }
  
  /// テスト用のスケジュールデータを作成
  Future<void> _createTestScheduleData() async {
    try {
      final now = DateTime.now();
      final batch = _firestore.batch();
      
      // 今週末の土曜日
      final saturday = now.add(Duration(days: (6 - now.weekday) % 7 + 1));
      // 来週末の日曜日
      final sunday = now.add(Duration(days: (7 - now.weekday) % 7 + 8));
      // 再来週の土曜日
      final nextSaturday = saturday.add(const Duration(days: 7));
      
      // yyyy-MM-dd形式の日付キーを生成
      String formatDateKey(DateTime date) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      
      final testSchedules = [
        {
          'dateKey': formatDateKey(saturday),
          'members': ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7', 'user8'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'dateKey': formatDateKey(sunday),
          'members': ['user1', 'user2', 'user3', 'user4', 'user5', 'user6'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'dateKey': formatDateKey(nextSaturday),
          'members': ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7', 'user8', 'user9', 'user10'],
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];
      
      for (final schedule in testSchedules) {
        // ドキュメントIDを日付キーとして使用
        final docRef = _firestore.collection('schedules').doc(schedule['dateKey'] as String);
        final scheduleData = Map<String, dynamic>.from(schedule);
        scheduleData.remove('dateKey'); // ドキュメントIDとして使うので削除
        batch.set(docRef, scheduleData);
      }
      
      await batch.commit();
      print('テストスケジュールデータを作成しました');
    } catch (e) {
      print('テストデータ作成エラー: $e');
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