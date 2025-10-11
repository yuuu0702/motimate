import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../models/circle_model.dart';
import '../providers/providers.dart';
import '../themes/app_theme.dart';

/// サークル参加画面
///
/// 公開サークルの検索・ブラウジング機能
/// 招待コードによる参加機能
class CircleJoinScreen extends HookConsumerWidget {
  final String? inviteCode;

  const CircleJoinScreen({super.key, this.inviteCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    final isLoading = useState(false);
    final searchController = useTextEditingController();
    final inviteCodeController = useTextEditingController(text: inviteCode ?? '');
    final tabController = useTabController(initialLength: 2);

    final searchResults = useState<List<CircleModel>>([]);
    final selectedCategory = useState<String?>(null);
    final isSearching = useState(false);

    // 初期検索実行
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(ref, searchResults, isSearching, null, null);
      });
      return null;
    }, []);

    // 招待コードがある場合は招待コードタブに切り替え
    useEffect(() {
      if (inviteCode != null && inviteCode!.isNotEmpty) {
        tabController.animateTo(1);
      }
      return null;
    }, [inviteCode]);

    Future<void> onJoinCircle(CircleModel circle) async {
      final shouldJoin = await _showJoinConfirmDialog(context, circle, isDarkMode);
      if (!shouldJoin) return;

      isLoading.value = true;
      try {
        final circleMemberService = ref.read(circleMemberServiceProvider);
        final circleSwitcher = ref.read(circleSwitcherServiceProvider);

        await circleMemberService.joinCircle(
          circleId: circle.id,
          joinMessage: 'よろしくお願いします！',
        );

        // 参加成功時は自動的にそのサークルに切り替え
        if (circle.privacy.isPublic && !circle.privacy.requiresApproval) {
          await circleSwitcher.switchCircle(circle.id);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                circle.privacy.requiresApproval
                    ? '参加申請を送信しました'
                    : 'サークルに参加しました！',
              ),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // 参加成功時はホーム画面に移動
          if (!circle.privacy.requiresApproval) {
            context.go('/');
          } else {
            context.pop();
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラーが発生しました: $e'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> onJoinByInviteCode() async {
      final code = inviteCodeController.text.trim().toUpperCase();
      if (code.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('招待コードを入力してください'),
            backgroundColor: AppTheme.warningColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      isLoading.value = true;
      try {
        final circleService = ref.read(circleServiceProvider);
        final circleMemberService = ref.read(circleMemberServiceProvider);
        final circleSwitcher = ref.read(circleSwitcherServiceProvider);

        final circle = await circleService.findByInviteCode(code);
        if (circle == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('招待コードが無効です'),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }

        await circleMemberService.joinCircle(
          circleId: circle.id,
          inviteCode: code,
          joinMessage: '招待コードで参加しました',
        );

        // 招待コードでの参加は即座に有効なので、サークルを切り替え
        await circleSwitcher.switchCircle(circle.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${circle.name}に参加しました！'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // ホーム画面に移動
          context.go('/');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラーが発生しました: $e'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
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

              // Tab bar
              _buildTabBar(tabController, isDarkMode),

              // Content
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    // Search tab
                    _buildSearchTab(
                      searchController,
                      searchResults,
                      selectedCategory,
                      isSearching,
                      ref,
                      onJoinCircle,
                      isLoading.value,
                      isDarkMode,
                    ),
                    // Invite code tab
                    _buildInviteCodeTab(
                      inviteCodeController,
                      onJoinByInviteCode,
                      isLoading.value,
                      isDarkMode,
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

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.cardBackground(isDarkMode),
              foregroundColor: AppTheme.primaryText(isDarkMode),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'サークルに参加',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText(isDarkMode),
                  ),
                ),
                Text(
                  '興味のあるサークルを見つけよう',
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
    );
  }

  Widget _buildTabBar(TabController tabController, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: AppTheme.accentColor,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.secondaryText(isDarkMode),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'サークルを探す'),
          Tab(text: '招待コード'),
        ],
      ),
    );
  }

  Widget _buildSearchTab(
    TextEditingController searchController,
    ValueNotifier<List<CircleModel>> searchResults,
    ValueNotifier<String?> selectedCategory,
    ValueNotifier<bool> isSearching,
    WidgetRef ref,
    Function(CircleModel) onJoinCircle,
    bool isLoading,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          _buildSearchBar(
            searchController,
            () => _performSearch(
              ref,
              searchResults,
              isSearching,
              searchController.text,
              selectedCategory.value,
            ),
            isDarkMode,
          ),
          const SizedBox(height: 16),

          // Category filter
          _buildCategoryFilter(selectedCategory, ref, searchResults, isSearching, searchController.text, isDarkMode),
          const SizedBox(height: 20),

          // Search results
          Expanded(
            child: isSearching.value
                ? _buildLoadingState(isDarkMode)
                : _buildSearchResults(searchResults.value, onJoinCircle, isLoading, isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    TextEditingController controller,
    VoidCallback onSearch,
    bool isDarkMode,
  ) {
    return Container(
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
        controller: controller,
        decoration: InputDecoration(
          hintText: 'サークル名で検索...',
          hintStyle: TextStyle(color: AppTheme.tertiaryText(isDarkMode)),
          prefixIcon: Icon(Icons.search, color: AppTheme.accentColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: AppTheme.tertiaryText(isDarkMode)),
            onPressed: () {
              controller.clear();
              onSearch();
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onSubmitted: (_) => onSearch(),
      ),
    );
  }

  Widget _buildCategoryFilter(
    ValueNotifier<String?> selectedCategory,
    WidgetRef ref,
    ValueNotifier<List<CircleModel>> searchResults,
    ValueNotifier<bool> isSearching,
    String searchQuery,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip(
            '全て',
            selectedCategory.value == null,
            () {
              selectedCategory.value = null;
              _performSearch(ref, searchResults, isSearching, searchQuery, null);
            },
            isDarkMode,
          ),
          ...CircleCategory.values.map((category) =>
            _buildCategoryChip(
              category.displayName,
              selectedCategory.value == category.value,
              () {
                selectedCategory.value = category.value;
                _performSearch(ref, searchResults, isSearching, searchQuery, category.value);
              },
              isDarkMode,
            ),
          ),
        ].map((widget) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: widget,
        )).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentColor
              : AppTheme.cardBackground(isDarkMode),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentColor
                : AppTheme.tertiaryText(isDarkMode).withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppTheme.primaryText(isDarkMode),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    List<CircleModel> results,
    Function(CircleModel) onJoinCircle,
    bool isLoading,
    bool isDarkMode,
  ) {
    if (results.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final circle = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCircleCard(circle, onJoinCircle, isLoading, isDarkMode),
        );
      },
    );
  }

  Widget _buildCircleCard(
    CircleModel circle,
    Function(CircleModel) onJoinCircle,
    bool isLoading,
    bool isDarkMode,
  ) {
    final iconType = IconType.fromId(circle.settings.iconType);
    final colorTheme = ColorTheme.fromId(circle.settings.colorTheme);
    final category = CircleCategory.fromId(circle.category);

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(colorTheme.colorValue).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(iconType.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              circle.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText(isDarkMode),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(colorTheme.colorValue).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(colorTheme.colorValue),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppTheme.tertiaryText(isDarkMode)),
                const SizedBox(width: 4),
                Text(
                  '${circle.stats.memberCount}人',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.tertiaryText(isDarkMode),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.event, size: 16, color: AppTheme.tertiaryText(isDarkMode)),
                const SizedBox(width: 4),
                Text(
                  '${circle.stats.activityCount}回活動',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.tertiaryText(isDarkMode),
                  ),
                ),
                const Spacer(),
                if (circle.privacy.requiresApproval)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '承認制',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => onJoinCircle(circle),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(colorTheme.colorValue),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  circle.privacy.requiresApproval ? '参加申請' : '参加する',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCodeTab(
    TextEditingController inviteCodeController,
    VoidCallback onJoinByInviteCode,
    bool isLoading,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.qr_code,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '招待コードで参加',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryText(isDarkMode),
                            ),
                          ),
                          Text(
                            '招待コードを入力してサークルに参加',
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
                TextField(
                  controller: inviteCodeController,
                  decoration: InputDecoration(
                    labelText: '招待コード',
                    hintText: '例: ABC123',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.scaffoldBackground(isDarkMode),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onJoinByInviteCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '参加する',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '招待コードはサークルの管理者から受け取ってください',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            'サークルを検索中...',
            style: TextStyle(color: AppTheme.secondaryText(isDarkMode)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.tertiaryText(isDarkMode).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.search_off,
                size: 40,
                color: AppTheme.tertiaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'サークルが見つかりません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '検索条件を変更してみてください',
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

  Future<bool> _showJoinConfirmDialog(BuildContext context, CircleModel circle, bool isDarkMode) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('サークルに参加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${circle.name}に参加しますか？'),
            if (circle.privacy.requiresApproval) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'このサークルは承認制です。管理者の承認をお待ちください。',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: Text(circle.privacy.requiresApproval ? '申請する' : '参加する'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _performSearch(
    WidgetRef ref,
    ValueNotifier<List<CircleModel>> searchResults,
    ValueNotifier<bool> isSearching,
    String? keyword,
    String? category,
  ) async {
    isSearching.value = true;
    try {
      final circleService = ref.read(circleServiceProvider);
      final results = await circleService.searchCircles(
        keyword: keyword,
        category: category,
        publicOnly: true,
      );
      searchResults.value = results;
    } catch (e) {
      searchResults.value = [];
    } finally {
      isSearching.value = false;
    }
  }
}