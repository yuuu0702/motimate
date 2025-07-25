# Firestore Query Optimization and Caching System

このドキュメントでは、MotiMateアプリに実装されたFirestoreクエリの最適化とキャッシュシステムについて説明します。

## 概要

Firestoreクエリの最適化とキャッシュ機能により、以下の問題を解決します：

- **重複クエリの削減**: 同じデータに対する繰り返しクエリを防止
- **レスポンス時間の短縮**: キャッシュからの高速データ取得
- **ネットワーク使用量の削減**: Firestoreアクセス回数の最小化
- **ユーザー体験の向上**: 滑らかな画面遷移とデータ表示

## アーキテクチャ

### 1. CacheManager (`cache_manager.dart`)
中央集権的なキャッシュ管理システム

```dart
final cacheManager = ref.watch(cacheManagerProvider);

// キャッシュに保存
cacheManager.set('user_info_123', userData, cacheType: 'user_info');

// キャッシュから取得
final cachedData = cacheManager.get<UserModel>('user_info_123');

// キャッシュを無効化
cacheManager.invalidate('user_info_123');
```

### 2. UserCacheService (`user_cache_service.dart`)
ユーザー情報の効率的なキャッシュ管理

```dart
final userCacheService = ref.watch(userCacheServiceProvider);

// 単一ユーザー情報を取得（キャッシュ対応）
final user = await userCacheService.getUserInfo(userId);

// 複数ユーザー情報を一括取得
final usersMap = await userCacheService.getUsersInfo(userIds);

// ユーザー名マップを取得（表示用）
final userNames = await userCacheService.getUserNames(userIds);
```

### 3. CachedMotivationService (`cached_motivation_service.dart`)
モチベーションデータのキャッシュ対応サービス

```dart
final motivationService = ref.watch(cachedMotivationServiceProvider);

// チームTOP3取得（キャッシュ対応）
final top3 = await motivationService.getTeamMotivationTop3();

// モチベーション更新（キャッシュ無効化含む）
await motivationService.updateMotivationWithComment(5.0, 'がんばる！');
```

### 4. CachedNotificationService (`cached_notification_service.dart`)
通知データのキャッシュとリアルタイム更新

```dart
final notificationService = ref.watch(cachedNotificationServiceProvider);

// 未読通知数取得（キャッシュ対応）
final count = await notificationService.getUnreadNotificationCount();

// リアルタイム更新のStream
final countStream = notificationService.watchUnreadNotificationCount();
```

### 5. CacheInvalidationController (`cache_invalidation_controller.dart`)
データ整合性を保つためのキャッシュ無効化戦略

```dart
final controller = ref.watch(cacheInvalidationControllerProvider);

// ユーザー情報更新時
controller.onUserInfoUpdated(userId);

// モチベーション更新時
controller.onMotivationUpdated(userId);

// 練習決定時
controller.onPracticeDecided();
```

## 使用方法

### 基本的な使用パターン

1. **既存のプロバイダーを置き換え**
```dart
// Before
final userInfo = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();

// After  
final userCacheService = ref.watch(userCacheServiceProvider);
final userInfo = await userCacheService.getUserInfo(userId);
```

2. **Riverpodプロバイダーの活用**
```dart
// キャッシュ対応プロバイダーを使用
final teamMotivation = ref.watch(teamMotivationTop3Provider);
final currentUser = ref.watch(currentUserInfoProvider);
final notificationCount = ref.watch(unreadNotificationCountStreamProvider);
```

3. **キャッシュ無効化の適切な処理**
```dart
// データ更新後にキャッシュを無効化
await firebase.update(data);
controller.onUserInfoUpdated(userId);
```

## キャッシュ戦略

### TTL（Time To Live）設定
- **ユーザー情報**: 10分
- **モチベーションデータ**: 5分  
- **通知カウント**: 2分
- **チームデータ**: 5分

### 無効化タイミング
- **ユーザー情報更新時**: 関連するユーザーキャッシュを無効化
- **モチベーション更新時**: 個人・チーム関連キャッシュを無効化
- **通知作成/既読時**: 通知カウントキャッシュを無効化
- **ログイン/ログアウト時**: 全キャッシュをクリア

## パフォーマンス最適化効果

### 期待される改善
1. **データ取得速度**: 50-90%の高速化
2. **ネットワーク使用量**: 60-80%削減
3. **Firestore読み取り回数**: 70-85%削減
4. **ユーザー体験**: スムーズな画面遷移

### 測定方法
```dart
// デバッグモードでのパフォーマンステスト
import 'package:motimate/core/cache/cache_performance_test.dart';

await runCachePerformanceTests(
  cacheManager: ref.read(cacheManagerProvider),
);
```

## 実装済み最適化箇所

### 1. HomeScreen
- **Before**: 複数のFirestoreクエリが実行
- **After**: キャッシュされたモチベーション・通知データを使用

### 2. TeamMotivationSection  
- **Before**: ユーザー情報を毎回Firestoreから取得
- **After**: `teamMotivationTop3Provider`でキャッシュされたデータを使用

### 3. PracticeHistoryCard
- **Before**: ユーザー名を毎回Firestoreから取得
- **After**: `UserCacheService.getUserNames()`でキャッシュ対応

### 4. NotificationService
- **Before**: 通知数を毎回カウント
- **After**: リアルタイム更新でキャッシュと同期

## 運用とメンテナンス

### 自動クリーンアップ
- 5分毎に期限切れキャッシュを自動削除
- アプリ起動時に無効キャッシュをクリーンアップ

### 監視とデバッグ
```dart
// キャッシュ統計情報の取得
final stats = cacheManager.getStats();
print('Cache entries: ${stats['totalEntries']}');
print('Hit rate: ${stats['hitRate']}%');
```

### 手動でのキャッシュ管理
```dart
// 特定タイプのキャッシュを無効化
controller.invalidateCacheType('user');

// 全キャッシュをクリア
cacheManager.clearAll();

// 現在ユーザーのキャッシュを無効化
controller.invalidateCurrentUserCache();
```

## 注意事項

1. **データ整合性**: 更新操作後は必ず関連キャッシュを無効化
2. **メモリ使用量**: 大量データのキャッシュ時はメモリ消費に注意
3. **リアルタイム性**: 重要な即座の更新が必要な場合はキャッシュを避ける
4. **エラーハンドリング**: キャッシュ操作失敗時のフォールバック処理を実装

## まとめ

このキャッシュシステムにより、MotiMateアプリのパフォーマンスが大幅に向上しました。特に：

- ユーザー情報の重複取得を防止
- チームモチベーション表示の高速化  
- 通知数の効率的な管理
- ネットワーク使用量の削減

今後も継続的にパフォーマンス監視を行い、必要に応じてキャッシュ戦略を調整していきます。