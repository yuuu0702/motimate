import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../models/circle_model.dart';
import '../providers/providers.dart';
import '../themes/app_theme.dart';
import '../routing/app_router.dart';

/// サークル選択・切り替え画面
///
/// ユーザーが参加しているサークルの一覧表示と
/// 新しいサークルの作成・参加機能を提供
class CircleSelectionScreen extends HookConsumerWidget {
  const CircleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCirclesAsync = ref.watch(userCirclesProvider);
    final isDarkMode = ref.watch(themeProvider);
    final isLoading = useState(false);

    Future<void> onCircleSelected(CircleModel circle) async {
      isLoading.value = true;
      try {
        // ユーザーの現在のサークルを更新
        await _updateCurrentCircle(ref, circle.id);

        if (context.mounted) {
          // ホーム画面に遷移
          context.go(AppRoutes.home);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラーが発生しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

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
              // Header
              _buildHeader(context, isDarkMode),

              // Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(userCirclesProvider);
                  },
                  child: userCirclesAsync.when(
                    loading: () => _buildLoadingState(isDarkMode),
                    error: (error, stack) => _buildErrorState(isDarkMode, error),
                    data: (circles) => _buildCircleList(
                      context,
                      circles,
                      onCircleSelected,
                      isDarkMode,
                      isLoading.value,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups,
                size: 32,
                color: AppTheme.accentColor,
              ),
              const SizedBox(width: 12),
              Text(
                'サークル選択',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText(isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '参加したいサークルを選択してください',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryText(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleList(
    BuildContext context,
    List<CircleModel> circles,
    Function(CircleModel) onCircleSelected,
    bool isDarkMode,
    bool isLoading,
  ) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (circles.isNotEmpty) ...[
                Text(
                  '参加中のサークル',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText(isDarkMode),
                  ),
                ),
                const SizedBox(height: 16),
                ...circles.map((circle) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCircleCard(
                    circle,
                    () => onCircleSelected(circle),
                    isDarkMode,
                    isLoading,
                  ),
                )),
                const SizedBox(height: 32),
              ],

              // Action buttons
              _buildActionButton(
                context,
                icon: Icons.add,
                title: '新しいサークルを作成',
                subtitle: 'あなたが管理するサークルを作成',
                color: AppTheme.accentColor,
                onTap: () => context.push('/circle/create'),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),

              _buildActionButton(
                context,
                icon: Icons.search,
                title: 'サークルを探す',
                subtitle: '公開されているサークルから選択',
                color: const Color(0xFF10B981),
                onTap: () => context.push('/circle/join'),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),

              _buildActionButton(
                context,
                icon: Icons.qr_code,
                title: '招待コードで参加',
                subtitle: '招待コードを入力して参加',
                color: const Color(0xFFF59E0B),
                onTap: () => _showInviteCodeDialog(context, isDarkMode),
                isDarkMode: isDarkMode,
              ),

              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleCard(
    CircleModel circle,
    VoidCallback onTap,
    bool isDarkMode,
    bool isLoading,
  ) {
    final iconType = IconType.fromId(circle.settings.iconType);
    final colorTheme = ColorTheme.fromId(circle.settings.colorTheme);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Circle icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(colorTheme.colorValue).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      iconType.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Circle info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        circle.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryText(isDarkMode),
                        ),
                      ),
                      if (circle.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          circle.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryText(isDarkMode),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: AppTheme.tertiaryText(isDarkMode),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${circle.stats.memberCount}人',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.tertiaryText(isDarkMode),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.event,
                            size: 16,
                            color: AppTheme.tertiaryText(isDarkMode),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${circle.stats.activityCount}回活動',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.tertiaryText(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.tertiaryText(isDarkMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryText(isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryText(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.tertiaryText(isDarkMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.accentColor),
          const SizedBox(height: 16),
          Text(
            'サークル一覧を読み込み中...',
            style: TextStyle(
              color: AppTheme.secondaryText(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode, dynamic error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.tertiaryText(isDarkMode),
            ),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                color: AppTheme.secondaryText(isDarkMode),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInviteCodeDialog(BuildContext context, bool isDarkMode) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('招待コードで参加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('招待コードを入力してください'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '例: ABC123',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/circle/join?inviteCode=${controller.text}');
            },
            child: const Text('参加'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCurrentCircle(WidgetRef ref, String circleId) async {
    // TODO: ユーザーの現在のサークルを更新する処理を実装
  }
}

// ユーザーのサークル一覧プロバイダー
final userCirclesProvider = FutureProvider<List<CircleModel>>((ref) async {
  final circleService = ref.watch(circleServiceProvider);
  return await circleService.getUserCircles();
});