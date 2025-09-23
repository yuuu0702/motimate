import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../models/schedule_model.dart';
import '../models/circle_model.dart';
import '../services/circle_switcher_service.dart';
import '../themes/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../routing/app_router.dart';
import '../widgets/cards/practice_decision_card.dart';
import '../widgets/cards/motivation_card.dart';
import '../widgets/cards/popular_dates_card.dart';
import '../widgets/sections/team_motivation_section.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.watch(homeViewModelProvider.notifier);
    final isDarkMode = ref.watch(themeProvider);
    final currentCircle = ref.watch(currentCircleProvider);
    
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
                  _buildCircleInfo(context, currentCircle, isDarkMode),
                  const Spacer(),
                  _buildCircleManagementButton(context, currentCircle, isDarkMode),
                  const SizedBox(width: 8),
                  _buildHistoryButton(context, isDarkMode),
                  const SizedBox(width: 8),
                  _buildNotificationBell(context, ref, isDarkMode),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode 
                        ? [
                            const Color(0xFF1E293B),
                            const Color(0xFF0F172A),
                          ]
                        : [
                            const Color(0xFFF8FAFC),
                            const Color(0xFFE2E8F0),
                          ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                
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
                const TeamMotivationSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton(BuildContext context, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        context.go(AppRoutes.basketballHistory);
      },
      child: Semantics(
        label: 'バスケ履歴',
        hint: 'タップしてバスケ履歴画面に移動',
        button: true,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.history,
            size: 24,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    
    return unreadCountAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.notifications_outlined,
          size: 24,
          color: AppTheme.primaryText(isDarkMode),
        ),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.notifications_outlined,
          size: 24,
          color: AppTheme.primaryText(isDarkMode),
        ),
      ),
      data: (unreadCount) => GestureDetector(
        onTap: () {
          context.go(AppRoutes.notifications);
        },
        child: Semantics(
          label: '通知',
          hint: unreadCount > 0 
              ? '${unreadCount}件の未読通知があります。タップして通知画面に移動'
              : 'タップして通知画面に移動',
          button: true,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: unreadCount > 0 
                        ? AppTheme.accentColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    unreadCount > 0 
                        ? Icons.notifications
                        : Icons.notifications_outlined,
                    size: 22,
                    color: unreadCount > 0 
                        ? AppTheme.accentColor 
                        : AppTheme.primaryText(isDarkMode),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF6B6B),
                            Color(0xFFFF5252),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.cardBackground(isDarkMode), 
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// サークル情報を表示するウィジェット
  Widget _buildCircleInfo(BuildContext context, AsyncValue<CircleModel?> currentCircle, bool isDarkMode) {
    return currentCircle.when(
      loading: () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            '読み込み中...',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText(isDarkMode),
            ),
          ),
        ],
      ),
      error: (error, stack) => GestureDetector(
        onTap: () => context.go(AppRoutes.circleSelection),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'サークルを選択',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      data: (circle) {
        if (circle == null) {
          return GestureDetector(
            onTap: () => context.go(AppRoutes.circleSelection),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.accentColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'サークルを選択',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => _showCircleSwitcher(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: circle.settings.colorThemeEnum.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: circle.settings.colorThemeEnum.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  circle.settings.iconTypeEnum.iconData,
                  color: circle.settings.colorThemeEnum.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  circle.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: circle.settings.colorThemeEnum.primaryColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: circle.settings.colorThemeEnum.primaryColor,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// サークル管理ボタンを表示するウィジェット
  Widget _buildCircleManagementButton(BuildContext context, AsyncValue<CircleModel?> currentCircle, bool isDarkMode) {
    return currentCircle.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (circle) {
        if (circle == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => _showCircleManagementOptions(context, circle),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor(isDarkMode).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.settings_outlined,
              size: 20,
              color: AppTheme.secondaryText(isDarkMode),
            ),
          ),
        );
      },
    );
  }

  /// サークル切り替えのボトムシートを表示
  void _showCircleSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final circleSwitcher = ref.watch(circleSwitcherServiceProvider);

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'サークルを選択',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add, color: Colors.green),
                              ),
                              title: const Text('新しいサークルを作成'),
                              subtitle: const Text('新しいサークルを作成します'),
                              onTap: () {
                                Navigator.pop(context);
                                context.go(AppRoutes.circleCreation);
                              },
                            ),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.search, color: Colors.blue),
                              ),
                              title: const Text('サークルに参加'),
                              subtitle: const Text('既存のサークルに参加します'),
                              onTap: () {
                                Navigator.pop(context);
                                context.go(AppRoutes.circleJoin);
                              },
                            ),
                            const Divider(),
                            // ユーザーのサークル一覧を表示
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: circleSwitcher.getUserCirclesWithInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text('エラー: ${snapshot.error}'),
                                  );
                                }

                                final circles = snapshot.data ?? [];

                                if (circles.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text('参加中のサークルはありません'),
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        '参加中のサークル',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...circles.map((circle) => _buildCircleListTile(
                                      context,
                                      circle,
                                      circleSwitcher,
                                    )),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// サークル一覧のListTileを作成
  Widget _buildCircleListTile(
    BuildContext context,
    Map<String, dynamic> circle,
    CircleSwitcherService circleSwitcher,
  ) {
    final iconType = IconType.fromId(circle['iconType'] ?? 'groups');
    final colorTheme = ColorTheme.fromId(circle['colorTheme'] ?? 'blue');

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(iconType.iconData, color: colorTheme.primaryColor),
      ),
      title: Text(circle['circleName']),
      subtitle: Text('${circle['memberCount']}人のメンバー'),
      trailing: circle['memberRole'] == 'creator'
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '作成者',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () async {
        try {
          await circleSwitcher.switchCircle(circle['circleId']);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${circle['circleName']}に切り替えました'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('切り替えに失敗しました: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  /// サークル管理オプションを表示
  void _showCircleManagementOptions(BuildContext context, CircleModel circle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${circle.name}の管理',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('サークル設定'),
              subtitle: const Text('名前、説明、プライバシー設定など'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.circleSettings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('メンバー管理'),
              subtitle: const Text('メンバーの承認、除名、権限変更'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.memberManagement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('メンバーを招待'),
              subtitle: Text('招待コード: ${circle.inviteCode ?? "未設定"}'),
              onTap: () {
                Navigator.pop(context);
                _showInviteCode(context, circle);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 招待コードを表示
  void _showInviteCode(BuildContext context, CircleModel circle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('招待コード'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${circle.name}の招待コード:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                circle.inviteCode ?? '未設定',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}