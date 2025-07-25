import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/cache/cache_manager.dart';
import '../services/notification_service.dart';

/// キャッシュ対応通知サービス
/// 
/// NotificationServiceを拡張してキャッシュ機能を追加
class CachedNotificationService {
  CachedNotificationService({
    required CacheManager cacheManager,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _cacheManager = cacheManager,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final CacheManager _cacheManager;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // 通知数の変更を監視するためのStreamController
  final _notificationCountController = StreamController<int>.broadcast();

  /// 未読通知数を取得（キャッシュ対応）
  Future<int> getUnreadNotificationCount([String? userId]) async {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId == null) return 0;

    final cacheKey = 'notification_count_$targetUserId';
    
    // キャッシュから取得を試行
    final cachedCount = _cacheManager.get<int>(cacheKey);
    if (cachedCount != null) {
      return cachedCount;
    }

    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: targetUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final count = snapshot.docs.length;

      // キャッシュに保存
      _cacheManager.set(cacheKey, count, cacheType: 'notification_count');

      return count;
    } catch (e) {
      throw Exception('通知数の取得に失敗しました: $e');
    }
  }

  /// 未読通知数のStreamを取得（リアルタイム更新）
  Stream<int> watchUnreadNotificationCount([String? userId]) {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId == null) return Stream.value(0);

    // Streamを購読してキャッシュを更新
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: targetUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final count = snapshot.docs.length;
          
          // キャッシュを更新
          final cacheKey = 'notification_count_$targetUserId';
          _cacheManager.set(cacheKey, count, cacheType: 'notification_count');
          
          // ストリームに値を送信
          _notificationCountController.add(count);
          
          return count;
        });
  }

  /// 通知を既読にマーク
  Future<void> markAsRead(String notificationId, [String? userId]) async {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId == null) return;

    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      // 通知数キャッシュを無効化
      _cacheManager.invalidate('notification_count_$targetUserId');
      
      // 新しい通知数を取得してキャッシュを更新
      await getUnreadNotificationCount(targetUserId);
    } catch (e) {
      throw Exception('通知の既読マークに失敗しました: $e');
    }
  }

  /// 複数の通知を既読にマーク
  Future<void> markMultipleAsRead(List<String> notificationIds, [String? userId]) async {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId == null || notificationIds.isEmpty) return;

    try {
      final batch = _firestore.batch();
      
      for (final notificationId in notificationIds) {
        final docRef = _firestore.collection('notifications').doc(notificationId);
        batch.update(docRef, {'isRead': true});
      }
      
      await batch.commit();

      // 通知数キャッシュを無効化
      _cacheManager.invalidate('notification_count_$targetUserId');
      
      // 新しい通知数を取得してキャッシュを更新
      await getUnreadNotificationCount(targetUserId);
    } catch (e) {
      throw Exception('複数通知の既読マークに失敗しました: $e');
    }
  }

  /// 全ての未読通知を既読にマーク
  Future<void> markAllAsRead([String? userId]) async {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId == null) return;

    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: targetUserId)
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();

      // 通知数キャッシュを更新
      final cacheKey = 'notification_count_$targetUserId';
      _cacheManager.set(cacheKey, 0, cacheType: 'notification_count');
    } catch (e) {
      throw Exception('全通知の既読マークに失敗しました: $e');
    }
  }

  /// 通知を作成（NotificationServiceの機能を使用）
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    await NotificationService.createNotification(
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
      imageUrl: imageUrl,
    );

    // 該当ユーザーの通知数キャッシュを無効化
    _cacheManager.invalidate('notification_count_$userId');
  }

  /// 練習日決定通知を作成
  Future<void> createPracticeDecisionNotification({
    required String userId,
    required DateTime practiceDate,
    required String deciderName,
  }) async {
    await NotificationService.createPracticeDecisionNotification(
      userId: userId,
      practiceDate: practiceDate,
      deciderName: deciderName,
    );

    // 該当ユーザーの通知数キャッシュを無効化
    _cacheManager.invalidate('notification_count_$userId');
  }

  /// 通知数の変更ストリームを取得
  Stream<int> get notificationCountStream => _notificationCountController.stream;

  /// ユーザーの通知キャッシュを無効化
  void invalidateUserNotificationCache([String? userId]) {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId != null) {
      _cacheManager.invalidate('notification_count_$targetUserId');
    }
  }

  /// 全ての通知キャッシュを無効化
  void invalidateAllNotificationCache() {
    _cacheManager.invalidatePattern('notification_count_');
  }

  /// リソースを解放
  void dispose() {
    _notificationCountController.close();
  }
}

/// CachedNotificationServiceのプロバイダー
final cachedNotificationServiceProvider = Provider<CachedNotificationService>((ref) {
  final service = CachedNotificationService(
    cacheManager: ref.watch(cacheManagerProvider),
  );
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// 未読通知数プロバイダー（キャッシュ対応）
final cachedUnreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(cachedNotificationServiceProvider);
  return service.getUnreadNotificationCount();
});

/// 未読通知数Streamプロバイダー（リアルタイム更新）
final unreadNotificationCountStreamProvider = StreamProvider<int>((ref) {
  final service = ref.watch(cachedNotificationServiceProvider);
  return service.watchUnreadNotificationCount();
});

/// 特定ユーザーの未読通知数プロバイダー
final userUnreadNotificationCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.watch(cachedNotificationServiceProvider);
  return service.getUnreadNotificationCount(userId);
});