import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
}