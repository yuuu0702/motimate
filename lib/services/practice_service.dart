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

  /// 未回答の練習決定を取得
  Future<List<PracticeDecisionModel>> getPendingPractices() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    try {
      // 全ての練習決定を取得
      final snapshot = await _firestore
          .collection('practice_decisions')
          .get();

      print('取得した練習決定数: ${snapshot.docs.length}');
      
      if (snapshot.docs.isEmpty) {
        print('練習決定データがありません。テストデータを作成します。');
        await _createTestPracticeData();
        
        // テストデータ作成後に再取得
        final retrySnapshot = await _firestore
            .collection('practice_decisions')
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
  
  /// テスト用の練習決定データを作成
  Future<void> _createTestPracticeData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final now = DateTime.now();
      final batch = _firestore.batch();
      
      // 今週末の土曜日の練習決定
      final practiceDate = now.add(Duration(days: (6 - now.weekday) % 7 + 1));
      
      // yyyy-MM-dd形式の日付キーを生成
      String formatDateKey(DateTime date) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      
      final testPractice = {
        'decidedBy': user.uid,
        'decidedAt': FieldValue.serverTimestamp(),
        'practiceDate': Timestamp.fromDate(practiceDate),
        'dateKey': formatDateKey(practiceDate),
        'availableMembers': ['user1', 'user2', 'user3', 'user4', 'user5'],
        'status': 'pending',
        'responses': <String, dynamic>{},
      };
      
      final docRef = _firestore.collection('practice_decisions').doc();
      batch.set(docRef, testPractice);
      
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
}