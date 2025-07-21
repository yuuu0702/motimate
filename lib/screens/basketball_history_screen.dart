import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/providers.dart';
import '../themes/app_theme.dart';
import '../widgets/cards/practice_history_card.dart';

/// バスケ履歴画面
/// 
/// 過去のバスケ活動の履歴を表示し、
/// メモの追加・編集、参加者の管理機能を提供
class BasketballHistoryScreen extends HookConsumerWidget {
  const BasketballHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.watch(homeViewModelProvider.notifier);
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground(isDarkMode),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.history,
              color: AppTheme.primaryText(isDarkMode),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'バスケ履歴',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.cardColor(isDarkMode),
        foregroundColor: AppTheme.primaryText(isDarkMode),
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 履歴データを再読み込み
          ref.invalidate(homeViewModelProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: homeState.isLoadingPastPractices
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('履歴を読み込み中...'),
                          ],
                        ),
                      ),
                    )
                  : homeState.pastPractices.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sports_basketball,
                                  size: 64,
                                  color: AppTheme.tertiaryText(isDarkMode),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'まだバスケ履歴がありません',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.secondaryText(isDarkMode),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'バスケが開催されると履歴が表示されます',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.tertiaryText(isDarkMode),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final practice = homeState.pastPractices[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: PracticeHistoryCard(
                                  practice: practice,
                                  homeViewModel: homeViewModel,
                                  isDarkMode: isDarkMode,
                                ),
                              );
                            },
                            childCount: homeState.pastPractices.length,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}