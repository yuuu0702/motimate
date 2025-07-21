import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/practice_decision_model.dart';

/// バスケ管理サービス
/// 
/// バスケ決定への回答、未回答バスケの取得を担当
class PracticeService {
  PracticeService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// 未回答のバスケ決定を取得（現在・未来のもののみ）
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
        print('練習決定データがありません。');
        return <PracticeDecisionModel>[];
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

  /// 過去のバスケ決定を取得（履歴用）
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

  /// バスケへの参加回答を送信
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

  /// バスケにメモを追加
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

  /// 実際の参加者を更新
  Future<void> updateActualParticipants(String practiceId, List<String> participants) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    try {
      await _firestore
          .collection('practice_decisions')
          .doc(practiceId)
          .update({
        'actualParticipants': participants,
      });
    } catch (e) {
      throw Exception('参加者の更新に失敗しました: $e');
    }
  }
}