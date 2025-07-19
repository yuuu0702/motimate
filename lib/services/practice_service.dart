import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/practice_decision_model.dart';

/// 練習管理サービス
/// 
/// 練習決定への回答、未回答練習の取得を担当
class PracticeService {
  PracticeService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// 未回答の練習決定を取得（現在・未来のもののみ）
  Future<List<PracticeDecisionModel>> getPendingPractices() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // 今日以降の練習決定を取得
      final snapshot = await _firestore
          .collection('practice_decisions')
          .where('practiceDate', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
          .get();

      print('取得した練習決定数: ${snapshot.docs.length}');
      
      if (snapshot.docs.isEmpty) {
        print('練習決定データがありません。テストデータを作成します。');
        await _createTestPracticeData();
        
        // テストデータ作成後に再取得
        final retrySnapshot = await _firestore
            .collection('practice_decisions')
            .where('practiceDate', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
            .get();
        
        final practices = <PracticeDecisionModel>[];
        
        for (final doc in retrySnapshot.docs) {
          final practice = PracticeDecisionModel.fromFirestore(doc);
          practices.add(practice);
        }
        
        // クライアント側でソート（decidedAt降順）
        practices.sort((a, b) => b.decidedAt.compareTo(a.decidedAt));
        
        return practices;
      }

      final practices = <PracticeDecisionModel>[];
      
      for (final doc in snapshot.docs) {
        final practice = PracticeDecisionModel.fromFirestore(doc);
        practices.add(practice);
      }

      // クライアント側でソート（decidedAt降順）
      practices.sort((a, b) => b.decidedAt.compareTo(a.decidedAt));

      return practices;
    } catch (e) {
      throw Exception('練習一覧の取得に失敗しました: $e');
    }
  }

  /// 過去の練習決定を取得（履歴用）
  Future<List<PracticeDecisionModel>> getPastPractices() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // 昨日以前の練習決定を取得
      final snapshot = await _firestore
          .collection('practice_decisions')
          .where('practiceDate', isLessThan: Timestamp.fromDate(today))
          .orderBy('practiceDate', descending: true)
          .limit(10) // 最新10件のみ
          .get();

      final practices = <PracticeDecisionModel>[];
      
      for (final doc in snapshot.docs) {
        final practice = PracticeDecisionModel.fromFirestore(doc);
        practices.add(practice);
      }

      return practices;
    } catch (e) {
      throw Exception('過去の練習一覧の取得に失敗しました: $e');
    }
  }
  
  /// テスト用の練習決定データを作成
  Future<void> _createTestPracticeData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final now = DateTime.now();
      final batch = _firestore.batch();
      
      // yyyy-MM-dd形式の日付キーを生成
      String formatDateKey(DateTime date) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      
      // 今週末の土曜日の練習決定
      final practiceDate = now.add(Duration(days: (6 - now.weekday) % 7 + 1));
      
      final testPractice = {
        'decidedBy': user.uid,
        'decidedAt': FieldValue.serverTimestamp(),
        'practiceDate': Timestamp.fromDate(practiceDate),
        'dateKey': formatDateKey(practiceDate),
        'availableMembers': ['user1', 'user2', 'user3', 'user4', 'user5'],
        'status': 'pending',
        'responses': <String, dynamic>{},
        'memo': null,
      };
      
      final docRef = _firestore.collection('practice_decisions').doc();
      batch.set(docRef, testPractice);
      
      // 過去の練習データも作成（履歴表示用）
      final pastDates = [
        now.subtract(const Duration(days: 7)), // 1週間前
        now.subtract(const Duration(days: 14)), // 2週間前
        now.subtract(const Duration(days: 21)), // 3週間前
      ];
      
      for (int i = 0; i < pastDates.length; i++) {
        final pastDate = pastDates[i];
        final testResponses = {
          'user1': i == 0 ? 'join' : 'skip',
          'user2': 'join',
          'user3': i == 2 ? 'skip' : 'join',
          'user4': 'join',
          'user5': i == 1 ? 'skip' : 'join',
        };
        
        final pastPractice = {
          'decidedBy': user.uid,
          'decidedAt': Timestamp.fromDate(pastDate.subtract(const Duration(days: 1))),
          'practiceDate': Timestamp.fromDate(pastDate),
          'dateKey': formatDateKey(pastDate),
          'availableMembers': ['user1', 'user2', 'user3', 'user4', 'user5'],
          'status': 'completed',
          'responses': testResponses,
          'memo': i == 0 ? '良い練習でした！' : null,
        };
        
        final pastDocRef = _firestore.collection('practice_decisions').doc();
        batch.set(pastDocRef, pastPractice);
      }
      
      await batch.commit();
      print('テスト練習決定データを作成しました');
    } catch (e) {
      print('テスト練習決定データ作成エラー: $e');
    }
  }

  /// 練習への参加回答を送信
  Future<void> respondToPractice(String practiceId, String response) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    if (response != 'join' && response != 'skip') {
      throw Exception('無効な回答です');
    }

    try {
      await _firestore
          .collection('practice_decisions')
          .doc(practiceId)
          .update({
        'responses.${user.uid}': response,
      });

      // 回答通知は将来的に実装予定
    } catch (e) {
      throw Exception('回答の送信に失敗しました: $e');
    }
  }

  /// 練習にメモを追加
  Future<void> updatePracticeMemo(String practiceId, String memo) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    try {
      await _firestore
          .collection('practice_decisions')
          .doc(practiceId)
          .update({
        'memo': memo.trim().isEmpty ? null : memo.trim(),
      });
    } catch (e) {
      throw Exception('メモの更新に失敗しました: $e');
    }
  }
}