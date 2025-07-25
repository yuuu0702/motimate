import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'cache_manager.dart';

/// キャッシュパフォーマンステスト
/// 
/// 開発・デバッグ用のキャッシュ効果測定ツール
class CachePerformanceTest {
  CachePerformanceTest({
    required CacheManager cacheManager,
    FirebaseFirestore? firestore,
  }) : _cacheManager = cacheManager,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final CacheManager _cacheManager;
  final FirebaseFirestore _firestore;

  /// ユーザー情報取得のパフォーマンステスト
  Future<Map<String, dynamic>> testUserInfoPerformance({
    required List<String> userIds,
    int iterations = 5,
  }) async {
    if (!kDebugMode) {
      throw Exception('Performance tests should only run in debug mode');
    }

    final results = <String, dynamic>{};
    
    // キャッシュなしでの測定
    final noCacheTimings = <int>[];
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      
      try {
        await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIds)
            .get();
      } catch (e) {
        debugPrint('Error in no-cache test: $e');
      }
      
      stopwatch.stop();
      noCacheTimings.add(stopwatch.elapsedMilliseconds);
      
      // 間隔を空ける
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // キャッシュありでの測定（初回はキャッシュミス、以降はヒット）
    final cacheTimings = <int>[];
    const cacheKey = 'test_user_batch';
    
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      
      // キャッシュから取得を試行
      final cached = _cacheManager.get<List<Map<String, dynamic>>>(cacheKey);
      
      if (cached == null) {
        // キャッシュミス - Firestoreから取得
        try {
          final snapshot = await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: userIds)
              .get();
          
          final data = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();
          
          _cacheManager.set(cacheKey, data, ttlMinutes: 5);
        } catch (e) {
          debugPrint('Error in cache test: $e');
        }
      }
      
      stopwatch.stop();
      cacheTimings.add(stopwatch.elapsedMilliseconds);
      
      // 間隔を空ける
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // 統計計算
    final noCacheAvg = noCacheTimings.reduce((a, b) => a + b) / noCacheTimings.length;
    final cacheAvg = cacheTimings.reduce((a, b) => a + b) / cacheTimings.length;
    
    // キャッシュクリア
    _cacheManager.invalidate(cacheKey);

    results['no_cache_timings_ms'] = noCacheTimings;
    results['cache_timings_ms'] = cacheTimings;
    results['no_cache_avg_ms'] = noCacheAvg.round();
    results['cache_avg_ms'] = cacheAvg.round();
    results['improvement_ratio'] = (noCacheAvg / cacheAvg).toStringAsFixed(2);
    results['time_saved_ms'] = (noCacheAvg - cacheAvg).round();
    
    return results;
  }

  /// チームモチベーション取得のパフォーマンステスト  
  Future<Map<String, dynamic>> testTeamMotivationPerformance({
    int iterations = 3,
  }) async {
    if (!kDebugMode) {
      throw Exception('Performance tests should only run in debug mode');
    }

    final results = <String, dynamic>{};
    
    // キャッシュなしでの測定
    final noCacheTimings = <int>[];
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      
      try {
        await _firestore
            .collection('users')
            .where('profileSetup', isEqualTo: true)
            .get();
      } catch (e) {
        debugPrint('Error in team motivation no-cache test: $e');
      }
      
      stopwatch.stop();
      noCacheTimings.add(stopwatch.elapsedMilliseconds);
      
      // 間隔を空ける
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // キャッシュありでの測定
    final cacheTimings = <int>[];
    const cacheKey = 'test_team_motivation';
    
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      
      final cached = _cacheManager.get<List<Map<String, dynamic>>>(cacheKey);
      
      if (cached == null) {
        try {
          final snapshot = await _firestore
              .collection('users')
              .where('profileSetup', isEqualTo: true)
              .get();
          
          final data = snapshot.docs.map((doc) => doc.data()).toList();
          _cacheManager.set(cacheKey, data, ttlMinutes: 5);
        } catch (e) {
          debugPrint('Error in team motivation cache test: $e');
        }
      }
      
      stopwatch.stop();
      cacheTimings.add(stopwatch.elapsedMilliseconds);
      
      // 間隔を空ける
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // 統計計算
    final noCacheAvg = noCacheTimings.reduce((a, b) => a + b) / noCacheTimings.length;
    final cacheAvg = cacheTimings.reduce((a, b) => a + b) / cacheTimings.length;
    
    // キャッシュクリア
    _cacheManager.invalidate(cacheKey);

    results['no_cache_avg_ms'] = noCacheAvg.round();
    results['cache_avg_ms'] = cacheAvg.round();
    results['improvement_ratio'] = (noCacheAvg / cacheAvg).toStringAsFixed(2);
    results['time_saved_ms'] = (noCacheAvg - cacheAvg).round();
    
    return results;
  }

  /// キャッシュヒット率の測定
  Future<Map<String, dynamic>> testCacheHitRate({
    required List<String> testKeys,
    int iterations = 10,
  }) async {
    if (!kDebugMode) {
      throw Exception('Performance tests should only run in debug mode');
    }

    int cacheHits = 0;
    int cacheMisses = 0;

    // テストデータをキャッシュに保存
    for (int i = 0; i < testKeys.length; i++) {
      final key = testKeys[i];
      if (i % 2 == 0) {
        // 偶数番目のキーのみキャッシュに保存
        _cacheManager.set(key, 'test_data_$i', ttlMinutes: 5);
      }
    }

    // キャッシュアクセステスト
    for (int i = 0; i < iterations; i++) {
      for (final key in testKeys) {
        final cached = _cacheManager.get<String>(key);
        if (cached != null) {
          cacheHits++;
        } else {
          cacheMisses++;
        }
      }
    }

    // テストキャッシュをクリア
    for (final key in testKeys) {
      _cacheManager.invalidate(key);
    }

    final totalAccess = cacheHits + cacheMisses;
    final hitRate = totalAccess > 0 ? (cacheHits / totalAccess * 100) : 0;

    return {
      'cache_hits': cacheHits,
      'cache_misses': cacheMisses,
      'total_access': totalAccess,
      'hit_rate_percent': hitRate.toStringAsFixed(1),
    };
  }

  /// 包括的なパフォーマンステストを実行
  Future<Map<String, dynamic>> runComprehensiveTest() async {
    if (!kDebugMode) {
      throw Exception('Performance tests should only run in debug mode');
    }

    debugPrint('🚀 Starting cache performance tests...');
    
    final testResults = <String, dynamic>{};
    
    try {
      // ユーザー情報テスト
      debugPrint('📊 Testing user info performance...');
      final userTest = await testUserInfoPerformance(
        userIds: ['user1', 'user2', 'user3'],
        iterations: 3,
      );
      testResults['user_info_test'] = userTest;
      
      // チームモチベーションテスト
      debugPrint('📊 Testing team motivation performance...');
      final teamTest = await testTeamMotivationPerformance(iterations: 3);
      testResults['team_motivation_test'] = teamTest;
      
      // キャッシュヒット率テスト
      debugPrint('📊 Testing cache hit rate...');
      final hitRateTest = await testCacheHitRate(
        testKeys: ['test1', 'test2', 'test3', 'test4', 'test5'],
        iterations: 5,
      );
      testResults['hit_rate_test'] = hitRateTest;
      
      // キャッシュ統計
      testResults['cache_stats'] = _cacheManager.getStats();
      
      debugPrint('✅ Cache performance tests completed');
      debugPrint('📈 Results: $testResults');
      
    } catch (e) {
      debugPrint('❌ Cache performance test failed: $e');
      testResults['error'] = e.toString();
    }
    
    return testResults;
  }
}

/// デバッグ用のパフォーマンステスト実行関数
Future<void> runCachePerformanceTests({
  required CacheManager cacheManager,
}) async {
  if (!kDebugMode) return;
  
  final tester = CachePerformanceTest(cacheManager: cacheManager);
  await tester.runComprehensiveTest();
}