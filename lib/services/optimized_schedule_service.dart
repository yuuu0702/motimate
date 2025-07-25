import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/schedule/optimized_date_cell.dart';
import '../core/cache/cache_manager.dart';

/// 最適化されたスケジュールサービス
class OptimizedScheduleService {
  OptimizedScheduleService({
    required this.cacheManager,
    required this.auth,
    required this.firestore,
  });

  final CacheManager cacheManager;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  /// 月ごとのスケジュールデータキャッシュキー
  String _getMonthCacheKey(DateTime date) {
    return 'schedule_data_${date.year}_${date.month}';
  }


  /// スケジュールデータを取得（キャッシュ対応）
  Future<Map<String, Map<String, dynamic>>> getScheduleData(DateTime month) async {
    final cacheKey = _getMonthCacheKey(month);
    
    // キャッシュから取得を試行
    final cachedData = cacheManager.get<Map<String, Map<String, dynamic>>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    // Firestoreから取得
    final snapshot = await firestore
        .collection('schedules')
        .get();

    final Map<String, Map<String, dynamic>> data = {};
    final user = auth.currentUser;

    for (var doc in snapshot.docs) {
      try {
        final docData = doc.data();
        final membersData = docData['members'];
        
        if (membersData == null) continue;
        
        final members = (membersData is List) 
            ? List<String>.from(membersData) 
            : <String>[];

        // 参加者が1人以上いる場合のみデータに追加
        if (members.isNotEmpty) {
          data[doc.id] = {
            'members': members,
            'available': members.length,
            'isMyRegistered': user != null && members.contains(user.uid),
          };
        }
      } catch (e) {
        // エラーログは本番では削除
        continue;
      }
    }

    // キャッシュに保存（5分間有効）
    cacheManager.set(cacheKey, data, cacheType: 'schedule_data');
    
    return data;
  }

  /// 最適化された日付セルデータ配列を生成
  Future<List<DateCellData?>> generateOptimizedDateCells({
    required DateTime currentMonth,
    required Set<DateTime> selectedDates,
    required Set<DateTime> myRegisteredDates,
    required Map<String, Map<String, dynamic>> scheduleData,
  }) async {
    final List<DateCellData?> cells = [];
    final days = _generateCalendarDays(currentMonth);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // 日付情報の事前計算
    final Map<String, Map<String, dynamic>?> dateInfoCache = {};
    for (final day in days) {
      if (day != null) {
        final dateKey = _getDateKey(day);
        dateInfoCache[dateKey] = scheduleData[dateKey];
      }
    }

    // セルデータの生成
    for (final day in days) {
      if (day == null) {
        cells.add(null);
        continue;
      }

      final dateKey = _getDateKey(day);
      final dateInfo = dateInfoCache[dateKey];
      
      // 日付状態の計算
      final dayOnly = DateTime(day.year, day.month, day.day);
      final isPast = dayOnly.isBefore(todayOnly);
      final isSelected = selectedDates.contains(day);
      final isMyRegistered = myRegisteredDates.contains(day);
      final availableCount = dateInfo?['available'] as int? ?? 0;

      // 視覚状態の決定
      DateCellVisualState visualState;
      if (isPast) {
        visualState = DateCellVisualState.past;
      } else if (isMyRegistered) {
        visualState = DateCellVisualState.myRegistered;
      } else if (isSelected) {
        visualState = DateCellVisualState.selected;
      } else {
        visualState = DateCellVisualState.normal;
      }

      cells.add(DateCellData(
        day: day,
        isSelected: isSelected,
        isMyRegistered: isMyRegistered,
        isPast: isPast,
        availableCount: availableCount,
        visualState: visualState,
      ));
    }

    return cells;
  }

  /// カレンダー日付配列の生成（最適化済み）
  List<DateTime?> _generateCalendarDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 日曜日を0とする

    final List<DateTime?> days = [];

    // 前月の空白セル
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }

    // 現在月の日付
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(month.year, month.month, day));
    }

    // 後月の空白セル（グリッドを6週間（42セル）に固定）
    while (days.length < 42) {
      days.add(null);
    }

    return days;
  }

  /// 日付キー生成（最適化済み）
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 人気日程の取得（最適化済み）
  Future<List<MapEntry<String, Map<String, dynamic>>>> getPopularDates({
    required Map<String, Map<String, dynamic>> scheduleData,
    int limit = 3,
  }) async {
    final cacheKey = 'popular_dates_${DateTime.now().millisecondsSinceEpoch ~/ 300000}'; // 5分間キャッシュ
    
    // キャッシュから取得を試行
    final cached = cacheManager.get<List<MapEntry<String, Map<String, dynamic>>>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // フィルタリングとソート
    final popularDates = scheduleData.entries
        .where((entry) {
          if ((entry.value['available'] as int? ?? 0) <= 0) return false;
          try {
            final date = DateTime.parse(entry.key);
            final dateOnly = DateTime(date.year, date.month, date.day);
            return !dateOnly.isBefore(todayOnly);
          } catch (e) {
            return false;
          }
        })
        .toList()
      ..sort((a, b) => 
          (b.value['available'] as int? ?? 0)
              .compareTo(a.value['available'] as int? ?? 0));

    final result = popularDates.take(limit).toList();
    
    // キャッシュに保存
    cacheManager.set(cacheKey, result, cacheType: 'popular_dates');
    
    return result;
  }

  /// 自分の登録済み日程を取得（最適化済み）
  Set<DateTime> extractMyRegisteredDates(Map<String, Map<String, dynamic>> scheduleData) {
    final myDates = <DateTime>{};
    
    for (final entry in scheduleData.entries) {
      if (entry.value['isMyRegistered'] == true) {
        try {
          final date = DateTime.parse(entry.key);
          myDates.add(date);
        } catch (e) {
          // 無効な日付はスキップ
          continue;
        }
      }
    }
    
    return myDates;
  }

  /// キャッシュ無効化
  void invalidateCache({DateTime? month}) {
    if (month != null) {
      final cacheKey = _getMonthCacheKey(month);
      cacheManager.invalidate(cacheKey);
    } else {
      // 全スケジュールキャッシュを無効化
      cacheManager.invalidatePattern('schedule_data_');
      cacheManager.invalidatePattern('popular_dates_');
    }
  }
}