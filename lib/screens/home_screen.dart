import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../models/schedule_model.dart';
import '../themes/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../routing/app_router.dart';
import '../widgets/cards/practice_decision_card.dart';
import '../widgets/cards/motivation_card.dart';
import '../widgets/cards/popular_dates_card.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.watch(homeViewModelProvider.notifier);
    final isDarkMode = ref.watch(themeProvider);
    
    final motivationLevels = useMemoized(() => AppConstants.motivationLevels
        .asMap()
        .entries
        .map((entry) => {
              'level': entry.key + 1,
              ...entry.value,
            })
        .toList());
    
    
    useEffect(() {
      if (homeState.error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(homeState.error!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          homeViewModel.clearError();
        });
      }
      return null;
    }, [homeState.error]);

    Future<void> handleMotivationUpdate(double newLevel) async {
      await homeViewModel.updateMotivation(newLevel);
      if (context.mounted && !homeState.isLoadingMotivation) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('やる気レベル ${newLevel.round()} に更新しました！'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    Future<void> handleDecisionDialog(ScheduleModel schedule) async {
      final shouldDecide = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '日程の決定',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule.date.month}月${schedule.date.day}日(${schedule.dayName})に日程を決定しますか？',
                  style: TextStyle(fontSize: 16, color: AppTheme.secondaryText(isDarkMode)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.containerBackground(isDarkMode),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            color: Color(0xFF667eea),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${schedule.memberCount}人が参加可能',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondaryText(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '決定すると、参加可能なメンバーに通知が送信され、参加/見送りの回答を求めます。',
                        style: TextStyle(fontSize: 14, color: AppTheme.tertiaryText(isDarkMode)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'キャンセル',
                  style: TextStyle(color: AppTheme.tertiaryText(isDarkMode)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '決定する',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );

      if (shouldDecide == true) {
        await homeViewModel.decidePracticeDate(schedule);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${schedule.date.month}/${schedule.date.day}(${schedule.dayName})に日程を決定しました！',
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }


    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground(isDarkMode),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 48,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.cardColor(isDarkMode),
            foregroundColor: AppTheme.primaryText(isDarkMode),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 16,
                bottom: 16,
              ),
              title: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_basketball_outlined,
                        color: Theme.of(context).appBarTheme.foregroundColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'motimate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildHistoryButton(context),
                  const SizedBox(width: 8),
                  _buildNotificationBell(context, ref),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // フィードバック告知バナー
                _buildFeedbackBanner(context),
                const SizedBox(height: 16),
                
                // 日程が決定されました！セクション
                if (homeState.pendingPractices.isNotEmpty) ...[
                  ...homeState.pendingPractices.map(
                    (practice) => PracticeDecisionCard(
                      practice: practice,
                      homeViewModel: homeViewModel,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
                
                // 人気の日程セクション
                PopularDatesCard(
                  state: homeState,
                  onDecisionDialog: handleDecisionDialog,
                ),

                // Personal Motivation Slider Section
                MotivationCard(
                  state: homeState,
                  motivationLevels: motivationLevels,
                  onMotivationUpdate: handleMotivationUpdate,
                  isDarkMode: isDarkMode,
                ),


                // チーム全体のモチベーションとTOP3表示セクション
                _buildTeamMotivationSection(isDarkMode),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go(AppRoutes.basketballHistory);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.history,
          size: 24,
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    
    return unreadCountAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.notifications_outlined,
          size: 24,
        ),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.notifications_outlined,
          size: 24,
        ),
      ),
      data: (unreadCount) => GestureDetector(
        onTap: () {
          context.go(AppRoutes.notifications);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                size: 24,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go(AppRoutes.feedback);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(
              Icons.feedback_outlined,
              color: Color(0xFF667eea),
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'フィードバック求む！',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildTeamMotivationSection(bool isDarkMode) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('エラー: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('まだモチベーションが登録されていません。'));
        }

        final List<Map<String, dynamic>> allMotivations = [];
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('latestMotivationLevel') &&
              data.containsKey('latestMotivationTimestamp')) {
            allMotivations.add({
              'userId': doc.id,
              'displayName':
                  data['displayName'] ??
                  data['username'] ??
                  'Unknown',
              'username': data['username'] ?? '',
              'department': data['department'] ?? '',
              'group': data['group'] ?? '',
              'level': data['latestMotivationLevel'],
              'comment': data['latestMotivationComment'] ?? '',
              'timestamp': data['latestMotivationTimestamp'],
            });
          }
        }

        if (allMotivations.isEmpty) {
          return const Center(child: Text('まだモチベーションが登録されていません。'));
        }

        // Calculate average motivation
        double totalMotivation = 0;
        for (var m in allMotivations) {
          totalMotivation += m['level'];
        }
        final averageMotivation = totalMotivation / allMotivations.length;

        // Get top 3 motivations (sorted by level, then by timestamp)
        allMotivations.sort((a, b) {
          int levelComparison = b['level'].compareTo(a['level']);
          if (levelComparison != 0) return levelComparison;
          return (b['timestamp'] as Timestamp).compareTo(
            a['timestamp'] as Timestamp,
          );
        });
        final top3Motivations = allMotivations.take(3).toList();

        return Column(
          children: [
            // チーム平均モチベーション
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardColor(isDarkMode),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.trending_up_rounded,
                          color: Color(0xFF667eea),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'チーム平均やる気',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryText(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        averageMotivation.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                      Text(
                        ' / 5.0',
                        style: TextStyle(
                          fontSize: 20,
                          color: AppTheme.tertiaryText(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TOP3 セクション
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardColor(isDarkMode),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFB923C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFFB923C),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'やる気ランキング TOP3',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...top3Motivations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final motivation = entry.value;
                    final rankColors = [
                      const Color(0xFFFFD700), // Gold
                      const Color(0xFFC0C0C0), // Silver
                      const Color(0xFFCD7F32), // Bronze
                    ];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.containerBackground(isDarkMode),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: rankColors[index].withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: rankColors[index],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  motivation['displayName'] ?? 'Unknown User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryText(isDarkMode),
                                  ),
                                ),
                                if (motivation['department']?.isNotEmpty == true ||
                                    motivation['group']?.isNotEmpty == true)
                                  Text(
                                    [
                                          motivation['department'],
                                          motivation['group'],
                                        ]
                                        .where((s) => s?.isNotEmpty == true)
                                        .join(' / '),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.tertiaryText(isDarkMode),
                                    ),
                                  ),
                                if (motivation['comment'] != null &&
                                    motivation['comment'].isNotEmpty)
                                  Text(
                                    motivation['comment'],
                                    style: TextStyle(
                                      color: AppTheme.tertiaryText(isDarkMode),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${motivation['level']}',
                              style: const TextStyle(
                                color: Color(0xFF667eea),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

}