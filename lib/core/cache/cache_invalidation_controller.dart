import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cache_manager.dart';

/// キャッシュ無効化戦略を管理するコントローラー
/// 
/// データの変更に応じて適切なキャッシュを無効化し、
/// データの整合性を保つ
class CacheInvalidationController {
  CacheInvalidationController({
    required CacheManager cacheManager,
    FirebaseAuth? auth,
  }) : _cacheManager = cacheManager,
        _auth = auth ?? FirebaseAuth.instance;

  final CacheManager _cacheManager;
  final FirebaseAuth _auth;

  /// ユーザー情報更新時のキャッシュ無効化
  void onUserInfoUpdated(String userId) {
    // 個人のユーザー情報キャッシュ
    _cacheManager.invalidatePattern('user_info_$userId');
    
    // ユーザー名マップキャッシュ
    _cacheManager.invalidatePattern('user_names');
    
    // アクティブユーザーリスト
    _cacheManager.invalidate('active_users');
    
    // チーム関連データ（ユーザー名表示が含まれる可能性）
    _cacheManager.invalidatePattern('team_motivation');
  }

  /// モチベーション更新時のキャッシュ無効化
  void onMotivationUpdated(String userId) {
    // 個人のモチベーションキャッシュ
    _cacheManager.invalidatePattern('motivation_$userId');
    
    // チームモチベーション関連キャッシュ
    _cacheManager.invalidatePattern('team_motivation');
    
    // ランキングが変わる可能性があるため
    _cacheManager.invalidate('team_motivation_top3');
  }

  /// 通知関連更新時のキャッシュ無効化
  void onNotificationUpdated(String userId) {
    // 通知数キャッシュ
    _cacheManager.invalidate('notification_count_$userId');
    
    // 通知一覧キャッシュ（将来的に実装される場合）
    _cacheManager.invalidatePattern('notifications_$userId');
  }

  /// 新しい通知作成時のキャッシュ無効化
  void onNotificationCreated(String userId) {
    onNotificationUpdated(userId);
  }

  /// 通知削除時のキャッシュ無効化
  void onNotificationDeleted(String userId) {
    onNotificationUpdated(userId);
  }

  /// スケジュール更新時のキャッシュ無効化
  void onScheduleUpdated() {
    // スケジュール関連キャッシュ
    _cacheManager.invalidatePattern('schedule_');
    _cacheManager.invalidatePattern('popular_dates');
    _cacheManager.invalidate('next_play_dates');
  }

  /// 練習データ更新時のキャッシュ無効化
  void onPracticeUpdated() {
    // 練習関連キャッシュ
    _cacheManager.invalidatePattern('practice_');
    _cacheManager.invalidate('pending_practices');
    _cacheManager.invalidate('past_practices');
    
    // 練習に関連するユーザー情報も更新される可能性
    _cacheManager.invalidatePattern('user_names');
  }

  /// 練習決定時のキャッシュ無効化
  void onPracticeDecided() {
    onPracticeUpdated();
    onScheduleUpdated();
  }

  /// 練習参加者更新時のキャッシュ無効化
  void onPracticeParticipantsUpdated(String practiceId) {
    // 特定の練習データ
    _cacheManager.invalidatePattern('practice_$practiceId');
    
    // 練習リスト全体
    _cacheManager.invalidate('pending_practices');
    _cacheManager.invalidate('past_practices');
    
    // 参加者名表示用キャッシュ
    _cacheManager.invalidatePattern('user_names');
  }

  /// ユーザーログイン時のキャッシュ処理
  void onUserLogin(String userId) {
    // 前のユーザーのキャッシュをクリア
    _cacheManager.clearAll();
    
    // 新しいユーザーの基本情報を事前ロード（必要に応じて）
    // プリロード処理はここに実装可能
  }

  /// ユーザーログアウト時のキャッシュ処理
  void onUserLogout() {
    // 全てのキャッシュをクリア
    _cacheManager.clearAll();
  }

  /// アプリ起動時の初期化
  void onAppStartup() {
    // 期限切れキャッシュのクリーンアップ
    _cacheManager.cleanup();
  }

  /// アプリ終了時の処理
  void onAppTerminate() {
    // キャッシュマネージャーのリソース解放
    _cacheManager.dispose();
  }

  /// データ整合性チェック時の一括無効化
  void onDataConsistencyCheck() {
    // 重要なデータの整合性を保つため、主要キャッシュを無効化
    _cacheManager.invalidatePattern('user_');
    _cacheManager.invalidatePattern('motivation_');
    _cacheManager.invalidatePattern('notification_');
    _cacheManager.invalidatePattern('team_');
  }

  /// メモリ圧迫時の緊急キャッシュクリア
  void onMemoryPressure() {
    // 使用頻度の低いキャッシュから削除
    _cacheManager.invalidatePattern('user_names');
    _cacheManager.invalidatePattern('team_motivation');
    
    // 必要に応じて全クリア
    // _cacheManager.clearAll();
  }

  /// 定期的なキャッシュメンテナンス
  void performMaintenance() {
    // 期限切れキャッシュのクリーンアップ
    _cacheManager.cleanup();
    
    // キャッシュ統計の取得とログ出力（デバッグ用）
    final stats = _cacheManager.getStats();
    if (kDebugMode) {
      debugPrint('Cache Stats: $stats');
    }
  }

  /// 特定のキャッシュタイプを一括無効化
  void invalidateCacheType(String cacheType) {
    switch (cacheType) {
      case 'user':
        _cacheManager.invalidatePattern('user_');
        break;
      case 'motivation':
        _cacheManager.invalidatePattern('motivation_');
        _cacheManager.invalidatePattern('team_motivation');
        break;
      case 'notification':
        _cacheManager.invalidatePattern('notification_');
        break;
      case 'schedule':
        _cacheManager.invalidatePattern('schedule_');
        break;
      case 'practice':
        _cacheManager.invalidatePattern('practice_');
        break;
      default:
        if (kDebugMode) {
          debugPrint('Unknown cache type: $cacheType');
        }
    }
  }

  /// 現在のユーザーに関連するキャッシュを無効化
  void invalidateCurrentUserCache() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _cacheManager.invalidateUserCache(userId);
    }
  }

  /// キャッシュ統計情報を取得
  Map<String, dynamic> getCacheStats() {
    return _cacheManager.getStats();
  }
}

/// CacheInvalidationControllerのプロバイダー
final cacheInvalidationControllerProvider = Provider<CacheInvalidationController>((ref) {
  return CacheInvalidationController(
    cacheManager: ref.watch(cacheManagerProvider),
  );
});

/// アプリライフサイクルに応じたキャッシュ管理プロバイダー
final cacheLifecycleManagerProvider = Provider<void>((ref) {
  final controller = ref.watch(cacheInvalidationControllerProvider);
  
  // アプリ起動時の初期化
  controller.onAppStartup();
  
  // 定期メンテナンスタイマー
  ref.watch(cacheCleanupTimerProvider);
  
  // プロバイダー破棄時の処理
  ref.onDispose(() {
    controller.onAppTerminate();
  });
  
  return;
});