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
      final snapshot = await _firestore
          .collection('practices')
          .where('isActive', isEqualTo: true)
          .orderBy('decidedAt', descending: true)
          .get();

      final practices = <PracticeDecisionModel>[];
      
      for (final doc in snapshot.docs) {
        final practice = PracticeDecisionModel.fromFirestore(doc);
        practices.add(practice);
      }

      return practices;
    } catch (e) {
      throw Exception('練習一覧の取得に失敗しました: $e');
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
          .collection('practices')
          .doc(practiceId)
          .update({
        'responses.${user.uid}': response,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // 回答通知は将来的に実装予定
    } catch (e) {
      throw Exception('回答の送信に失敗しました: $e');
    }
  }
}