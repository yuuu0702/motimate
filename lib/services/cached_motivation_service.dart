import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/cache/cache_manager.dart';
import '../services/motivation_service.dart';
/// モチベーションデータ
class MotivationData {
  const MotivationData({
    required this.level,
    required this.comment,
    required this.timestamp,
  });

  final double level;
  final String comment;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'level': level,
    'comment': comment,
    'timestamp': timestamp.toIso8601String(),
  };

  factory MotivationData.fromJson(Map<String, dynamic> json) => MotivationData(
    level: (json['level'] as num).toDouble(),
    comment: json['comment'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// チームモチベーションデータ
class TeamMotivationData {
  const TeamMotivationData({
    required this.userId,
    required this.displayName,
    required this.username,
    required this.department,
    required this.group,
    required this.motivationData,
  });

  final String userId;
  final String displayName;
  final String username;
  final String department;
  final String group;
  final MotivationData motivationData;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'displayName': displayName,
    'username': username,
    'department': department,
    'group': group,
    'motivationData': motivationData.toJson(),
  };

  factory TeamMotivationData.fromJson(Map<String, dynamic> json) => TeamMotivationData(
    userId: json['userId'] as String,
    displayName: json['displayName'] as String,
    username: json['username'] as String,
    department: json['department'] as String,
    group: json['group'] as String,
    motivationData: MotivationData.fromJson(json['motivationData'] as Map<String, dynamic>),
  );
}

/// キャッシュ対応モチベーションサービス
/// 
/// 元のMotivationServiceを拡張してキャッシュ機能を追加
class CachedMotivationService extends MotivationService {
  CachedMotivationService({
    required CacheManager cacheManager,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _cacheManager = cacheManager,
        _auth = auth,
        _firestore = firestore,
        super(auth: auth, firestore: firestore);

  final CacheManager _cacheManager;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<double> getCurrentMotivation() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    final cacheKey = 'motivation_level_${user.uid}';
    
    // キャッシュから取得を試行
    final cachedLevel = _cacheManager.get<double>(cacheKey);
    if (cachedLevel != null) {
      return cachedLevel;
    }

    // 元のサービスから取得
    final level = await super.getCurrentMotivation();
    
    // キャッシュに保存
    _cacheManager.set(cacheKey, level, cacheType: 'motivation_data');
    
    return level;
  }

  @override
  Future<void> updateMotivation(double newLevel) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    // 元のサービスで更新
    await super.updateMotivation(newLevel);
    
    // キャッシュを無効化
    _cacheManager.invalidatePattern('motivation_${user.uid}');
    _cacheManager.invalidatePattern('team_motivation');
    
    // 新しい値をキャッシュに保存
    final cacheKey = 'motivation_level_${user.uid}';
    _cacheManager.set(cacheKey, newLevel, cacheType: 'motivation_data');
  }

  /// ユーザーのモチベーションデータを取得（コメント付き）
  Future<MotivationData?> getUserMotivationData(String userId) async {
    final cacheKey = 'motivation_data_$userId';
    
    // キャッシュから取得を試行
    final cachedData = _cacheManager.get<MotivationData>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      
      final level = (data['latestMotivationLevel'] as num?)?.toDouble() ?? 3.0;
      final comment = data['latestMotivationComment'] as String? ?? '';
      final timestamp = (data['latestMotivationTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

      final motivationData = MotivationData(
        level: level,
        comment: comment,
        timestamp: timestamp,
      );

      // キャッシュに保存
      _cacheManager.set(cacheKey, motivationData, cacheType: 'motivation_data');

      return motivationData;
    } catch (e) {
      throw Exception('モチベーションデータの取得に失敗しました: $e');
    }
  }

  /// チーム全体のモチベーションデータを取得
  Future<List<TeamMotivationData>> getTeamMotivationData() async {
    const cacheKey = 'team_motivation_all';
    
    // キャッシュから取得を試行
    final cachedData = _cacheManager.get<List<TeamMotivationData>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('profileSetup', isEqualTo: true)
          .get();

      final teamData = <TeamMotivationData>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        // モチベーションデータが存在するユーザーのみ
        if (data.containsKey('latestMotivationLevel') &&
            data.containsKey('latestMotivationTimestamp')) {
          
          final motivationData = MotivationData(
            level: (data['latestMotivationLevel'] as num).toDouble(),
            comment: data['latestMotivationComment'] as String? ?? '',
            timestamp: (data['latestMotivationTimestamp'] as Timestamp).toDate(),
          );

          final teamMotivationData = TeamMotivationData(
            userId: doc.id,
            displayName: data['displayName'] ?? data['username'] ?? 'Unknown',
            username: data['username'] ?? '',
            department: data['department'] ?? '',
            group: data['group'] ?? '',
            motivationData: motivationData,
          );

          teamData.add(teamMotivationData);
        }
      }

      // レベル順にソート（降順）
      teamData.sort((a, b) {
        final levelComparison = b.motivationData.level.compareTo(a.motivationData.level);
        if (levelComparison != 0) return levelComparison;
        
        return b.motivationData.timestamp.compareTo(a.motivationData.timestamp);
      });

      // キャッシュに保存
      _cacheManager.set(cacheKey, teamData, cacheType: 'team_motivation');

      return teamData;
    } catch (e) {
      throw Exception('チームモチベーションの取得に失敗しました: $e');
    }
  }

  /// チームモチベーションTOP3を取得
  Future<List<TeamMotivationData>> getTeamMotivationTop3() async {
    const cacheKey = 'team_motivation_top3';
    
    // キャッシュから取得を試行
    final cachedData = _cacheManager.get<List<TeamMotivationData>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    // 全体データから上位3件を取得
    final allData = await getTeamMotivationData();
    final top3 = allData.take(3).toList();

    // キャッシュに保存
    _cacheManager.set(cacheKey, top3, cacheType: 'team_motivation');

    return top3;
  }

  /// モチベーションをコメント付きで更新
  Future<void> updateMotivationWithComment(double newLevel, String comment) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがログインしていません');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'currentMotivation': newLevel,
        'latestMotivationLevel': newLevel,
        'latestMotivationComment': comment,
        'latestMotivationTimestamp': FieldValue.serverTimestamp(),
        'lastMotivationUpdate': FieldValue.serverTimestamp(),
      });

      // キャッシュを無効化
      _cacheManager.invalidatePattern('motivation_${user.uid}');
      _cacheManager.invalidatePattern('team_motivation');
      
      // 新しい値をキャッシュに保存
      final levelCacheKey = 'motivation_level_${user.uid}';
      _cacheManager.set(levelCacheKey, newLevel, cacheType: 'motivation_data');
      
      final dataCacheKey = 'motivation_data_${user.uid}';
      final motivationData = MotivationData(
        level: newLevel,
        comment: comment,
        timestamp: DateTime.now(),
      );
      _cacheManager.set(dataCacheKey, motivationData, cacheType: 'motivation_data');
      
    } catch (e) {
      throw Exception('モチベーションの更新に失敗しました: $e');
    }
  }

  /// 特定ユーザーのモチベーションキャッシュを無効化
  void invalidateUserMotivationCache(String userId) {
    _cacheManager.invalidatePattern('motivation_$userId');
    _cacheManager.invalidatePattern('team_motivation');
  }

  /// 全モチベーションキャッシュを無効化
  void invalidateAllMotivationCache() {
    _cacheManager.invalidatePattern('motivation_');
    _cacheManager.invalidatePattern('team_motivation');
  }
}

