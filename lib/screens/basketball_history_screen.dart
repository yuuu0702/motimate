import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
    final searchQuery = useState('');
    
    // Filter practices based on search query
    final filteredPractices = useMemoized(() {
      if (searchQuery.value.isEmpty) {
        return homeState.pastPractices;
      }
      return homeState.pastPractices.where((practice) {
        final dateString = '${practice.practiceDate.year}年${practice.practiceDate.month}月${practice.practiceDate.day}日';
        final memo = practice.memo ?? '';
        final query = searchQuery.value.toLowerCase();
        return dateString.contains(query) || memo.toLowerCase().contains(query);
      }).toList();
    }, [homeState.pastPractices, searchQuery.value]);

    final totalPractices = homeState.pastPractices.length;
    final totalParticipants = homeState.pastPractices.fold<int>(
      0, (sum, practice) => sum + practice.actualParticipants.length);
    final averageParticipants = totalPractices > 0 
        ? (totalParticipants / totalPractices).round() 
        : 0;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground(isDarkMode),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header with statistics
              _buildModernHeader(isDarkMode, context, totalPractices, averageParticipants, ref),
              
              // Search bar
              _buildSearchBar(searchQuery, isDarkMode),
              
              // Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(homeViewModelProvider);
                  },
                  backgroundColor: AppTheme.cardBackground(isDarkMode),
                  color: AppTheme.accentColor,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: homeState.isLoadingPastPractices
                            ? _buildLoadingState(isDarkMode)
                            : filteredPractices.isEmpty && searchQuery.value.isNotEmpty
                                ? _buildSearchEmptyState(isDarkMode, searchQuery.value)
                                : homeState.pastPractices.isEmpty
                                    ? _buildEmptyState(isDarkMode)
                                    : SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            final practice = filteredPractices[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 12),
                                              child: PracticeHistoryCard(
                                                practice: practice,
                                                homeViewModel: homeViewModel,
                                                isDarkMode: isDarkMode,
                                              ),
                                            );
                                          },
                                          childCount: filteredPractices.length,
                                        ),
                                      ),
                      ),
                      // Bottom padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDarkMode, BuildContext context, int totalPractices, int averageParticipants, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.1),
            AppTheme.accentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header with back button and title
          Row(
            children: [
              Semantics(
                label: '戻るボタン',
                hint: 'タップして前の画面に戻る',
                button: true,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.cardBackground(isDarkMode),
                    foregroundColor: AppTheme.primaryText(isDarkMode),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: AppTheme.primaryText(isDarkMode),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'バスケ履歴',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '過去のバスケ活動記録',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryText(isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Statistics cards
          if (totalPractices > 0) _buildStatisticsSection(isDarkMode, totalPractices, averageParticipants, ref),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(bool isDarkMode, int totalPractices, int averageParticipants, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '総開催数',
            '$totalPractices回',
            Icons.sports_basketball,
            const Color(0xFF667EEA),
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '平均参加者',
            '${averageParticipants}人',
            Icons.people,
            const Color(0xFF10B981),
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '今月',
            '${_getCurrentMonthPractices(ref)}回',
            Icons.calendar_today,
            const Color(0xFFFF8E53),
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.tertiaryText(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ValueNotifier<String> searchQuery, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Semantics(
        label: '履歴検索欄',
        hint: '日付やメモで履歴を検索できます',
        textField: true,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground(isDarkMode),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.1 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            onChanged: (value) => searchQuery.value = value,
            style: TextStyle(color: AppTheme.primaryText(isDarkMode)),
            decoration: InputDecoration(
              hintText: '日付やメモで検索...',
              hintStyle: TextStyle(color: AppTheme.tertiaryText(isDarkMode)),
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.accentColor,
              ),
              suffixIcon: searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppTheme.tertiaryText(isDarkMode),
                      ),
                      onPressed: () => searchQuery.value = '',
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground(isDarkMode),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '履歴を読み込み中...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryText(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentColor.withValues(alpha: 0.2),
                      AppTheme.accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.sports_basketball,
                  size: 60,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'まだバスケ履歴がありません',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText(isDarkMode),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'バスケが開催されると\nこちらに履歴が表示されます',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.secondaryText(isDarkMode),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'スケジュール画面から日程を決定できます',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState(bool isDarkMode, String query) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.tertiaryText(isDarkMode).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.search_off,
                  size: 50,
                  color: AppTheme.tertiaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '検索結果が見つかりません',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryText(isDarkMode),
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: '「'),
                    TextSpan(
                      text: query,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const TextSpan(text: '」に一致する履歴が見つかりませんでした'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCurrentMonthPractices(WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final now = DateTime.now();
    
    return homeState.pastPractices.where((practice) {
      return practice.practiceDate.month == now.month && 
             practice.practiceDate.year == now.year;
    }).length;
  }
}