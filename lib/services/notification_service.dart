import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notification_model.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize notification service
  static Future<void> initialize() async {
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('Foreground message: ${message.messageId}');
        }
      });
      
      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('Notification opened: ${message.messageId}');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing notifications: $e');
      }
    }
  }

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

      if (kDebugMode) {
        debugPrint('Notification permission: ${settings.authorizationStatus}');
      }

      // 許可が得られた場合はFCMトークンを保存
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _saveFCMToken();
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting notification permission: $e');
      }
      return false;
    }
  }

  /// 現在の通知許可状態を確認
  static Future<AuthorizationStatus> getNotificationStatus() async {
    try {
      NotificationSettings settings = await _messaging
          .getNotificationSettings();
      return settings.authorizationStatus;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting notification status: $e');
      }
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
        if (kDebugMode) {
          debugPrint('FCM Token saved: $token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving FCM token: $e');
      }
    }
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
    String? circleId,
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
        circleId: circleId,
        userId: userId,
      );

      await _firestore.collection('notifications').add({
        'userId': userId,
        ...notification.toFirestore(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to create notification: $e');
      }
    }
  }

  /// 練習日決定通知を作成
  static Future<void> createPracticeDecisionNotification({
    required String userId,
    required DateTime practiceDate,
    required String deciderName,
    String? circleId,
  }) async {
    final dayNames = ['日', '月', '火', '水', '木', '金', '土'];
    final dayName = dayNames[practiceDate.weekday == 7 ? 0 : practiceDate.weekday];

    await createNotification(
      userId: userId,
      title: '🏀 日程が決定されました！',
      body:
          '${practiceDate.month}/${practiceDate.day}($dayName)に日程が決定されました。参加/見送りを選択してください。',
      type: 'practice_decision',
      circleId: circleId,
      data: {
        'practiceDate': practiceDate.toIso8601String(),
        'deciderName': deciderName,
        'circleId': circleId,
      },
    );
  }

  /// サークル全体に通知を配信
  static Future<void> sendCircleNotification({
    required String circleId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? excludeUserId, // 送信者を除外する場合
  }) async {
    try {
      // サークルのアクティブメンバーを取得
      final membersSnapshot = await _firestore
          .collection('circle_members')
          .where('circleId', isEqualTo: circleId)
          .where('status', isEqualTo: 'active')
          .get();

      final batch = _firestore.batch();
      int batchCount = 0;

      for (final memberDoc in membersSnapshot.docs) {
        final memberData = memberDoc.data();
        final userId = memberData['userId'] as String;

        // 送信者を除外
        if (excludeUserId != null && userId == excludeUserId) {
          continue;
        }

        // 通知ドキュメントを作成
        final notificationRef = _firestore.collection('notifications').doc();
        final notification = NotificationModel(
          id: notificationRef.id,
          title: title,
          body: body,
          type: type,
          data: data,
          createdAt: DateTime.now(),
          isRead: false,
          imageUrl: imageUrl,
          circleId: circleId,
          userId: userId,
        );

        batch.set(notificationRef, {
          'userId': userId,
          ...notification.toFirestore(),
        });

        batchCount++;

        // Firestoreのバッチ制限（500）に達したらコミット
        if (batchCount >= 500) {
          await batch.commit();
          batchCount = 0;
        }
      }

      // 残りのバッチをコミット
      if (batchCount > 0) {
        await batch.commit();
      }

      if (kDebugMode) {
        debugPrint('Circle notification sent to ${membersSnapshot.docs.length} members');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to send circle notification: $e');
      }
    }
  }

  /// サークル加入通知
  static Future<void> sendMemberJoinedNotification({
    required String circleId,
    required String joinedUserName,
    required String joinedUserId,
  }) async {
    await sendCircleNotification(
      circleId: circleId,
      title: '📢 新しいメンバーが参加しました',
      body: '$joinedUserName さんがサークルに参加しました',
      type: 'member_joined',
      excludeUserId: joinedUserId,
      data: {
        'joinedUserId': joinedUserId,
        'joinedUserName': joinedUserName,
        'circleId': circleId,
      },
    );
  }

  /// サークル退出通知
  static Future<void> sendMemberLeftNotification({
    required String circleId,
    required String leftUserName,
    required String leftUserId,
  }) async {
    await sendCircleNotification(
      circleId: circleId,
      title: '📢 メンバーが退出しました',
      body: '$leftUserName さんがサークルを退出しました',
      type: 'member_left',
      excludeUserId: leftUserId,
      data: {
        'leftUserId': leftUserId,
        'leftUserName': leftUserName,
        'circleId': circleId,
      },
    );
  }

  /// 活動決定通知をサークル全体に送信
  static Future<void> sendActivityDecisionNotification({
    required String circleId,
    required DateTime activityDate,
    required String deciderName,
    required String deciderId,
  }) async {
    final dayNames = ['日', '月', '火', '水', '木', '金', '土'];
    final dayName = dayNames[activityDate.weekday == 7 ? 0 : activityDate.weekday];

    await sendCircleNotification(
      circleId: circleId,
      title: '🎯 活動日程が決定されました！',
      body: '${activityDate.month}/${activityDate.day}($dayName)に活動が決定されました。参加/見送りを選択してください。',
      type: 'activity_decision',
      excludeUserId: deciderId,
      data: {
        'activityDate': activityDate.toIso8601String(),
        'deciderName': deciderName,
        'deciderId': deciderId,
        'circleId': circleId,
      },
    );
  }

  /// 未読通知数を取得
  static Stream<int> getUnreadNotificationCount(String userId, {String? circleId}) {
    Query query = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false);

    // サークル指定がある場合はフィルタリング
    if (circleId != null) {
      query = query.where('circleId', isEqualTo: circleId);
    }

    return query
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// サークル別の通知一覧を取得
  static Stream<List<NotificationModel>> getCircleNotifications(
    String userId,
    String circleId, {
    int limit = 50,
  }) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('circleId', isEqualTo: circleId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// 通知を既読にする
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to mark notification as read: $e');
      }
    }
  }

  /// サークルの全ての通知を既読にする
  static Future<void> markCircleNotificationsAsRead(String userId, String circleId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('circleId', isEqualTo: circleId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to mark circle notifications as read: $e');
      }
    }
  }
}
