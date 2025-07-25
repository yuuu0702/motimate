import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/cache/cache_manager.dart';
import '../models/user_model.dart';

/// ユーザー情報キャッシュサービス
/// 
/// ユーザー情報の取得とキャッシュを効率的に管理
class UserCacheService {
  UserCacheService({
    required CacheManager cacheManager,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _cacheManager = cacheManager,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final CacheManager _cacheManager;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// 単一ユーザーの情報を取得（キャッシュ対応）
  Future<UserModel?> getUserInfo(String userId) async {
    final cacheKey = 'user_info_$userId';
    
    // キャッシュから取得を試行
    final cachedUser = _cacheManager.get<UserModel>(cacheKey);
    if (cachedUser != null) {
      return cachedUser;
    }

    try {
      // Firestoreから取得
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      doc.data() as Map<String, dynamic>;
      final user = UserModel.fromFirestore(doc);

      // キャッシュに保存
      _cacheManager.set(cacheKey, user, cacheType: 'user_info');

      return user;
    } catch (e) {
      throw Exception('ユーザー情報の取得に失敗しました: $e');
    }
  }

  /// 複数ユーザーの情報を一括取得（キャッシュ対応）
  Future<Map<String, UserModel>> getUsersInfo(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final result = <String, UserModel>{};
    final uncachedUserIds = <String>[];

    // キャッシュから可能な限り取得
    for (final userId in userIds) {
      final cacheKey = 'user_info_$userId';
      final cachedUser = _cacheManager.get<UserModel>(cacheKey);
      
      if (cachedUser != null) {
        result[userId] = cachedUser;
      } else {
        uncachedUserIds.add(userId);
      }
    }

    // キャッシュにないものはFirestoreから取得
    if (uncachedUserIds.isNotEmpty) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: uncachedUserIds)
            .get();

        for (final doc in snapshot.docs) {
          final user = UserModel.fromFirestore(doc);
          result[doc.id] = user;

          // キャッシュに保存
          final cacheKey = 'user_info_${doc.id}';
          _cacheManager.set(cacheKey, user, cacheType: 'user_info');
        }
      } catch (e) {
        throw Exception('ユーザー情報の一括取得に失敗しました: $e');
      }
    }

    return result;
  }

  /// ユーザー名のマップを取得（表示用に最適化）
  Future<Map<String, String>> getUserNames(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final cacheKey = 'user_names_${userIds.join(',')}';
    
    // キャッシュから取得を試行
    final cachedNames = _cacheManager.get<Map<String, String>>(cacheKey);
    if (cachedNames != null) {
      return cachedNames;
    }

    try {
      final result = <String, String>{};
      
      // ユーザー情報を取得してディスプレイ名をマッピング
      final usersInfo = await getUsersInfo(userIds);
      
      for (final entry in usersInfo.entries) {
        final user = entry.value;
        result[entry.key] = user.displayName.isNotEmpty 
                          ? user.displayName
                          : user.username.isNotEmpty 
                          ? user.username 
                          : 'ユーザー${entry.key.substring(0, 4)}';
      }

      // 見つからなかったユーザーのフォールバック
      for (final userId in userIds) {
        if (!result.containsKey(userId)) {
          result[userId] = 'ユーザー${userId.substring(0, 4)}';
        }
      }

      // キャッシュに保存
      _cacheManager.set(cacheKey, result, cacheType: 'user_names');

      return result;
    } catch (e) {
      // エラー時のフォールバック
      final result = <String, String>{};
      for (final userId in userIds) {
        result[userId] = 'ユーザー${userId.substring(0, 4)}';
      }
      return result;
    }
  }

  /// 現在のユーザー情報を取得
  Future<UserModel?> getCurrentUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return getUserInfo(user.uid);
  }

  /// プロフィール設定が完了しているユーザーのリストを取得
  Future<List<UserModel>> getActiveUsers() async {
    const cacheKey = 'active_users';
    
    // キャッシュから取得を試行
    final cachedUsers = _cacheManager.get<List<UserModel>>(cacheKey);
    if (cachedUsers != null) {
      return cachedUsers;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('profileSetup', isEqualTo: true)
          .get();

      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      // 個別のユーザー情報もキャッシュに保存
      for (final user in users) {
        final userCacheKey = 'user_info_${user.uid}';
        _cacheManager.set(userCacheKey, user, cacheType: 'user_info');
      }

      // リスト全体をキャッシュに保存
      _cacheManager.set(cacheKey, users, cacheType: 'user_info');

      return users;
    } catch (e) {
      throw Exception('アクティブユーザーの取得に失敗しました: $e');
    }
  }

  /// ユーザー情報を更新してキャッシュを無効化
  Future<void> updateUserInfo(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(data);

      // 関連するキャッシュを無効化
      _cacheManager.invalidatePattern('user_info_$userId');
      _cacheManager.invalidatePattern('user_names');
      _cacheManager.invalidate('active_users');
    } catch (e) {
      throw Exception('ユーザー情報の更新に失敗しました: $e');
    }
  }

  /// ユーザーのキャッシュを強制更新
  Future<UserModel?> refreshUserInfo(String userId) async {
    // キャッシュを無効化
    _cacheManager.invalidatePattern('user_info_$userId');
    
    // 新しいデータを取得
    return getUserInfo(userId);
  }

  /// 全ユーザー関連キャッシュを無効化
  void invalidateAllUserCache() {
    _cacheManager.invalidatePattern('user_');
    _cacheManager.invalidate('active_users');
  }
}

/// UserCacheServiceのプロバイダー
final userCacheServiceProvider = Provider<UserCacheService>((ref) {
  return UserCacheService(
    cacheManager: ref.watch(cacheManagerProvider),
  );
});

/// 現在のユーザー情報プロバイダー（キャッシュ対応）
final currentUserInfoProvider = FutureProvider<UserModel?>((ref) async {
  final userCacheService = ref.watch(userCacheServiceProvider);
  return userCacheService.getCurrentUserInfo();
});

/// アクティブユーザーリストプロバイダー（キャッシュ対応）
final activeUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final userCacheService = ref.watch(userCacheServiceProvider);
  return userCacheService.getActiveUsers();
});

/// 特定ユーザー名取得プロバイダー（キャッシュ対応）
final userNamesProvider = FutureProvider.family<Map<String, String>, List<String>>((ref, userIds) async {
  final userCacheService = ref.watch(userCacheServiceProvider);
  return userCacheService.getUserNames(userIds);
});