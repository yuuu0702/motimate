import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// モチベーション管理サービス
/// 
/// ユーザーのモチベーションレベルの取得、更新を担当
class MotivationService {
  MotivationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// 現在のモチベーションレベルを取得
  Future<double> getCurrentMotivation() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['currentMotivation'] as num?)?.toDouble() ?? 3.0;
      }
      return 3.0;
    } catch (e) {
      throw Exception('モチベーションの取得に失敗しました: $e');
    }
  }

  /// モチベーションレベルを更新
  Future<void> updateMotivation(double newLevel) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'currentMotivation': newLevel,
        'lastMotivationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('モチベーションの更新に失敗しました: $e');
    }
  }
}