import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// キャッシュエントリー
/// 
/// データとその有効期限を管理するクラス
class CacheEntry<T> {
  const CacheEntry({
    required this.data,
    required this.expiresAt,
    this.lastUpdated,
  });

  final T data;
  final DateTime expiresAt;
  final DateTime? lastUpdated;

  /// キャッシュが有効かどうかを判定
  bool get isValid => DateTime.now().isBefore(expiresAt);

  /// キャッシュエントリーを新しいデータで更新
  CacheEntry<T> copyWith({
    T? data,
    DateTime? expiresAt,
    DateTime? lastUpdated,
  }) {
    return CacheEntry<T>(
      data: data ?? this.data,
      expiresAt: expiresAt ?? this.expiresAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// 中央集権的なキャッシュマネージャー
/// 
/// Firestoreクエリの結果をメモリにキャッシュし、
/// 効率的なデータアクセスを提供
class CacheManager {
  CacheManager({
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  
  // キャッシュストレージ
  final Map<String, CacheEntry<dynamic>> _cache = {};
  
  // Streamサブスクリプション管理
  final Map<String, StreamSubscription> _subscriptions = {};

  /// キャッシュのデフォルト有効期限（分）
  static const Map<String, int> _defaultTtlMinutes = {
    'user_info': 10,        // ユーザー情報: 10分
    'user_names': 15,       // ユーザー名マップ: 15分
    'motivation_data': 5,   // モチベーションデータ: 5分
    'notification_count': 2, // 通知カウント: 2分
    'team_motivation': 5,   // チームモチベーション: 5分
    'schedule_data': 10,    // スケジュールデータ: 10分
    'practice_data': 8,     // 練習データ: 8分
  };

  /// キャッシュからデータを取得
  T? get<T>(String key) {
    final entry = _cache[key] as CacheEntry<T>?;
    if (entry?.isValid == true) {
      return entry!.data;
    }
    
    // 期限切れのキャッシュを削除
    if (entry != null) {
      _cache.remove(key);
    }
    return null;
  }

  /// キャッシュにデータを保存
  void set<T>(String key, T data, {int? ttlMinutes, String? cacheType}) {
    final ttl = ttlMinutes ?? _defaultTtlMinutes[cacheType] ?? 10;
    final expiresAt = DateTime.now().add(Duration(minutes: ttl));
    
    _cache[key] = CacheEntry<T>(
      data: data,
      expiresAt: expiresAt,
      lastUpdated: DateTime.now(),
    );
  }

  /// 特定のキーのキャッシュを無効化
  void invalidate(String key) {
    _cache.remove(key);
    _subscriptions[key]?.cancel();
    _subscriptions.remove(key);
  }

  /// パターンにマッチするキーのキャッシュを無効化
  void invalidatePattern(String pattern) {
    final keysToRemove = _cache.keys
        .where((key) => key.contains(pattern))
        .toList();
    
    for (final key in keysToRemove) {
      invalidate(key);
    }
  }

  /// ユーザー関連のキャッシュを無効化
  void invalidateUserCache([String? userId]) {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId != null) {
      invalidatePattern('user_$targetUserId');
      invalidatePattern('motivation_$targetUserId');
    }
    
    // 全ユーザー関連データも無効化
    invalidatePattern('user_names');
    invalidatePattern('team_motivation');
  }

  /// 全てのキャッシュをクリア
  void clearAll() {
    _cache.clear();
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// キャッシュ統計情報を取得
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    int validEntries = 0;
    int expiredEntries = 0;
    
    for (final entry in _cache.values) {
      if (entry.expiresAt.isAfter(now)) {
        validEntries++;
      } else {
        expiredEntries++;
      }
    }
    
    return {
      'totalEntries': _cache.length,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'activeSubscriptions': _subscriptions.length,
    };
  }

  /// キャッシュのクリーンアップを実行
  void cleanup() {
    final now = DateTime.now();
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.expiresAt.isBefore(now))
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      invalidate(key);
    }
  }

  /// リソースを解放
  void dispose() {
    clearAll();
  }
}

/// CacheManagerのRiverpodプロバイダー
final cacheManagerProvider = Provider<CacheManager>((ref) {
  final cacheManager = CacheManager();
  
  // プロバイダーが破棄される際にリソースを解放
  ref.onDispose(() {
    cacheManager.dispose();
  });
  
  return cacheManager;
});

/// 定期的なキャッシュクリーンアップタイマー
final cacheCleanupTimerProvider = Provider<Timer>((ref) {
  final cacheManager = ref.watch(cacheManagerProvider);
  
  // 5分毎にクリーンアップを実行
  final timer = Timer.periodic(
    const Duration(minutes: 5),
    (_) => cacheManager.cleanup(),
  );
  
  ref.onDispose(() {
    timer.cancel();
  });
  
  return timer;
});