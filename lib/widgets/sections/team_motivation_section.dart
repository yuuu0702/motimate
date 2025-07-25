import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../themes/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/providers.dart';

class TeamMotivationSection extends HookConsumerWidget {
  const TeamMotivationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    
    // キャッシュ対応の非同期プロバイダーを使用
    final teamMotivationAsync = ref.watch(teamMotivationTop3Provider);

    return teamMotivationAsync.when(
      loading: () => const _LoadingWidget(),
      error: (error, stackTrace) => _ErrorWidget(error: error.toString()),
      data: (teamData) {
        if (teamData.isEmpty) {
          return const _EmptyStateWidget();
        }

        // TeamMotivationDataを既存の形式にマッピング
        final processedData = teamData.map((data) => {
          'userId': data.userId,
          'displayName': data.displayName,
          'username': data.username,
          'department': data.department,
          'group': data.group,
          'level': data.motivationData.level,
          'comment': data.motivationData.comment,
          'timestamp': data.motivationData.timestamp,
        }).toList();

        return _TeamMotivationContent(
          motivationData: processedData,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

}

class _TeamMotivationContent extends StatelessWidget {
  const _TeamMotivationContent({
    required this.motivationData,
    required this.isDarkMode,
  });

  final List<Map<String, dynamic>> motivationData;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          ...motivationData.asMap().entries.map((entry) =>
            _buildMotivationItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppConstants.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'チームモチベーション TOP3',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationItem(int index, Map<String, dynamic> data) {
    final level = (data['level'] as double).round();
    final motivationLevel = AppConstants.motivationLevels[level - 1];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _buildRankBadge(index + 1),
          const SizedBox(width: 8),
          Text(
            motivationLevel['emoji'],
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['displayName'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText(isDarkMode),
                  ),
                ),
                if (data['comment'].isNotEmpty)
                  Text(
                    data['comment'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.tertiaryText(isDarkMode),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Color(motivationLevel['color'][0]).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              motivationLevel['label'],
              style: TextStyle(
                fontSize: 10,
                color: Color(motivationLevel['color'][0]),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    final colors = [
      [0xFFFFD700, 0xFFFFA500], // Gold
      [0xFFC0C0C0, 0xFF808080], // Silver
      [0xFFCD7F32, 0xFF8B4513], // Bronze
    ];
    
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(colors[rank - 1][0]), Color(colors[rank - 1][1])],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.error});
  
  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Center(
        child: Text(
          'エラー: $error',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'まだモチベーションが登録されていません。',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}