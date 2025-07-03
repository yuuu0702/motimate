import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motimate/models/notification_model.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 通知許可を求める（必要時のみ呼び出し）
  static Future<bool> requestNotificationPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Notification permission: ${settings.authorizationStatus}');
      
      // 許可が得られた場合はFCMトークンを保存
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _saveFCMToken();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  /// 現在の通知許可状態を確認
  static Future<AuthorizationStatus> getNotificationStatus() async {
    try {
      NotificationSettings settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus;
    } catch (e) {
      print('Error getting notification status: $e');
      return AuthorizationStatus.notDetermined;
    }
  }

  /// FCMトークンをFirestoreに保存
  static Future<void> _saveFCMToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('FCM Token saved: $token');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// 通知許可が必要かどうかをチェック
  static Future<bool> shouldRequestPermission() async {
    final status = await getNotificationStatus();
    return status == AuthorizationStatus.notDetermined;
  }

  /// 通知許可が拒否されているかチェック
  static Future<bool> isPermissionDenied() async {
    final status = await getNotificationStatus();
    return status == AuthorizationStatus.denied;
  }

  /// 通知が有効かどうかをチェック
  static Future<bool> isNotificationEnabled() async {
    final status = await getNotificationStatus();
    return status == AuthorizationStatus.authorized ||
           status == AuthorizationStatus.provisional;
  }

  /// 設定画面を開くためのヘルパー関数
  static Future<void> openSettings() async {
    await _messaging.requestPermission();
  }

  /// 通知を作成してFirestoreに保存
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      final notification = NotificationModel(
        id: '', // Firestoreで自動生成
        title: title,
        body: body,
        type: type,
        data: data,
        createdAt: DateTime.now(),
        isRead: false,
        imageUrl: imageUrl,
      );

      await _firestore.collection('notifications').add({
        'userId': userId,
        ...notification.toFirestore(),
      });
    } catch (e) {
      print('Failed to create notification: $e');
    }
  }

  /// 練習日決定通知を作成
  static Future<void> createPracticeDecisionNotification({
    required String userId,
    required DateTime practiceDate,
    required String deciderName,
  }) async {
    final dayNames = ['日', '月', '火', '水', '木', '金', '土'];
    final dayName = dayNames[practiceDate.weekday % 7];
    
    await createNotification(
      userId: userId,
      title: '🏀 練習日が決定されました！',
      body: '${practiceDate.month}/${practiceDate.day}(${dayName})に練習が決定されました。参加/見送りを選択してください。',
      type: 'practice_decision',
      data: {
        'practiceDate': practiceDate.toIso8601String(),
        'deciderName': deciderName,
      },
    );
  }

  /// スケジュール更新通知を作成
  static Future<void> createScheduleUpdateNotification({
    required String userId,
    required String message,
  }) async {
    await createNotification(
      userId: userId,
      title: '📅 スケジュール更新',
      body: message,
      type: 'schedule_update',
    );
  }

  /// 未読通知数を取得
  static Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}