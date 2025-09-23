import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/circle_member_model.dart';
import '../models/user_model.dart';
import '../services/permission_service.dart';
import '../providers/providers.dart';
import '../themes/app_theme.dart';

class MemberManagementScreen extends HookConsumerWidget {
  const MemberManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circleMemberService = ref.watch(circleMemberServiceProvider);
    final permissionService = ref.watch(permissionServiceProvider);
    final isDarkMode = ref.watch(themeProvider);
    final currentCircle = ref.watch(currentCircleProvider);

    final isLoading = useState(false);
    final error = useState<String?>(null);
    final activeMembers = useState<List<Map<String, dynamic>>>([]);
    final pendingMembers = useState<List<CircleMemberModel>>([]);
    final hasManagePermission = useState(false);
    final selectedTab = useState(0);

    // データ読み込み
    Future<void> loadData(String? circleId) async {
      if (circleId == null) {
        error.value = 'サークルが選択されていません';
        return;
      }

      try {
        isLoading.value = true;
        error.value = null;

        // 権限チェック
        final canManage = await permissionService.hasPermission(circleId, Permission.manageMembers);
        hasManagePermission.value = canManage;

        // アクティブメンバー一覧を取得
        final activeMembersData = await circleMemberService.getMembersWithUserInfo(circleId);
        activeMembers.value = activeMembersData;

        // 管理権限がある場合は参加申請も取得
        if (canManage) {
          final pendingMembersData = await circleMemberService.getPendingMembers(circleId);
          pendingMembers.value = pendingMembersData;
        }

      } catch (e) {
        error.value = 'データの読み込みに失敗しました: $e';
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      final circle = currentCircle.value;
      if (circle != null) {
        loadData(circle.id);
      }
      return null;
    }, [currentCircle.value]);

    // メンバー承認
    Future<void> approveMember(String userId) async {
      final circle = currentCircle.value;
      if (circle == null) return;

      try {
        isLoading.value = true;
        await circleMemberService.approveMember(circle.id, userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('メンバーを承認しました'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        await loadData(circle.id); // データを再読み込み
      } catch (e) {
        error.value = 'メンバーの承認に失敗しました: $e';
      } finally {
        isLoading.value = false;
      }
    }

    // メンバー拒否
    Future<void> rejectMember(String userId) async {
      final circle = currentCircle.value;
      if (circle == null) return;

      try {
        isLoading.value = true;
        await circleMemberService.rejectMember(circle.id, userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('参加申請を拒否しました'),
              backgroundColor: AppTheme.warningColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        await loadData(circle.id); // データを再読み込み
      } catch (e) {
        error.value = '参加申請の拒否に失敗しました: $e';
      } finally {
        isLoading.value = false;
      }
    }

    // メンバー除名
    Future<void> removeMember(String userId, String userName) async {
      final circle = currentCircle.value;
      if (circle == null) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('メンバーを除名'),
          content: Text('$userName さんを除名しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('除名'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      try {
        isLoading.value = true;
        await circleMemberService.removeMember(circle.id, userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userName さんを除名しました'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        await loadData(circle.id); // データを再読み込み
      } catch (e) {
        error.value = 'メンバーの除名に失敗しました: $e';
      } finally {
        isLoading.value = false;
      }
    }

    // ロール変更
    Future<void> changeRole(String userId, String userName, MemberRole newRole) async {
      final circle = currentCircle.value;
      if (circle == null) return;

      try {
        isLoading.value = true;
        await circleMemberService.updateMemberRole(circle.id, userId, newRole);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userName さんの権限を変更しました'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        await loadData(circle.id); // データを再読み込み
      } catch (e) {
        error.value = '権限の変更に失敗しました: $e';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground(isDarkMode),
      appBar: AppBar(
        title: currentCircle.when(
          loading: () => const Text('メンバー管理'),
          error: (error, stack) => const Text('メンバー管理'),
          data: (circle) => Text(
            circle != null ? '${circle.name} - メンバー管理' : 'メンバー管理',
          ),
        ),
        backgroundColor: AppTheme.cardColor(isDarkMode),
        foregroundColor: AppTheme.primaryText(isDarkMode),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final circle = currentCircle.value;
              if (circle != null) {
                loadData(circle.id);
              }
            },
          ),
        ],
        bottom: hasManagePermission.value
            ? TabBar(
                controller: TabController(
                  length: 2,
                  vsync: Scaffold.of(context),
                  initialIndex: selectedTab.value,
                ),
                onTap: (index) => selectedTab.value = index,
                labelColor: AppTheme.accentColor,
                unselectedLabelColor: AppTheme.secondaryText(isDarkMode),
                indicatorColor: AppTheme.accentColor,
                tabs: const [
                  Tab(text: 'メンバー'),
                  Tab(text: '参加申請'),
                ],
              )
            : null,
      ),
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
        child: Stack(
          children: [
            currentCircle.when(
              loading: () => _buildLoadingState(isDarkMode),
              error: (error, stack) => _buildErrorState(isDarkMode, 'サークル情報の取得エラー: $error'),
              data: (circle) {
                if (circle == null) {
                  return _buildNoCircleState(isDarkMode);
                }

                return Column(
                  children: [
                    if (error.value != null) ...[
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.errorColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                error.value!,
                                style: TextStyle(color: AppTheme.errorColor),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: AppTheme.errorColor),
                              onPressed: () => error.value = null,
                            ),
                          ],
                        ),
                      ),
                    ],

                    // コンテンツ
                    Expanded(
                      child: hasManagePermission.value
                          ? _buildTabContent(
                              selectedTab.value,
                              activeMembers.value,
                              pendingMembers.value,
                              approveMember,
                              rejectMember,
                              removeMember,
                              changeRole,
                              isDarkMode,
                            )
                          : _buildMembersList(
                              activeMembers.value,
                              removeMember,
                              changeRole,
                              isDarkMode,
                            ),
                    ),
                  ],
                );
              },
            ),

            // ローディングオーバーレイ
            if (isLoading.value)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
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
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'メンバー情報を読み込み中...',
            style: TextStyle(
              color: AppTheme.secondaryText(isDarkMode),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode, String message) {
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
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: AppTheme.errorColor,
              ),
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
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText(isDarkMode),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCircleState(bool isDarkMode) {
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
                Icons.group_off,
                size: 40,
                color: AppTheme.tertiaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'サークルが選択されていません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'まずサークルを選択してください',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
    int selectedTab,
    List<Map<String, dynamic>> activeMembers,
    List<CircleMemberModel> pendingMembers,
    Function(String) approveMember,
    Function(String) rejectMember,
    Function(String, String) removeMember,
    Function(String, String, MemberRole) changeRole,
    bool isDarkMode,
  ) {
    if (selectedTab == 0) {
      return _buildMembersList(activeMembers, removeMember, changeRole, isDarkMode);
    } else {
      return _buildPendingList(pendingMembers, approveMember, rejectMember, isDarkMode);
    }
  }

  Widget _buildMembersList(
    List<Map<String, dynamic>> members,
    Function(String, String) removeMember,
    Function(String, String, MemberRole) changeRole,
    bool isDarkMode,
  ) {
    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.tertiaryText(isDarkMode),
            ),
            const SizedBox(height: 16),
            Text(
              'メンバーがいません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildMemberCard(member, removeMember, changeRole, isDarkMode);
      },
    );
  }

  Widget _buildPendingList(
    List<CircleMemberModel> pendingMembers,
    Function(String) approveMember,
    Function(String) rejectMember,
    bool isDarkMode,
  ) {
    if (pendingMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.tertiaryText(isDarkMode),
            ),
            const SizedBox(height: 16),
            Text(
              '参加申請はありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingMembers.length,
      itemBuilder: (context, index) {
        final member = pendingMembers[index];
        return _buildPendingCard(member, approveMember, rejectMember, isDarkMode);
      },
    );
  }

  Widget _buildMemberCard(
    Map<String, dynamic> member,
    Function(String, String) removeMember,
    Function(String, String, MemberRole) changeRole,
    bool isDarkMode,
  ) {
    final user = member['user'] as UserModel?;
    final memberInfo = member['member'] as CircleMemberModel;

    if (user == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // アバター
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentColor,
                    AppTheme.accentColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  user.displayName?.isNotEmpty == true
                      ? user.displayName!.substring(0, 1).toUpperCase()
                      : user.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // ユーザー情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName?.isNotEmpty == true ? user.displayName! : user.username,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryText(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(memberInfo.role).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getRoleDisplayName(memberInfo.role),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getRoleColor(memberInfo.role),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (user.department?.isNotEmpty == true) ...[
                        const SizedBox(width: 8),
                        Text(
                          user.department!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.tertiaryText(isDarkMode),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // アクションボタン
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppTheme.secondaryText(isDarkMode),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'remove':
                    removeMember(
                      user.uid,
                      user.displayName?.isNotEmpty == true ? user.displayName! : user.username,
                    );
                    break;
                  case 'promote':
                    changeRole(
                      user.uid,
                      user.displayName?.isNotEmpty == true ? user.displayName! : user.username,
                      MemberRole.admin,
                    );
                    break;
                  case 'demote':
                    changeRole(
                      user.uid,
                      user.displayName?.isNotEmpty == true ? user.displayName! : user.username,
                      MemberRole.member,
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                if (memberInfo.role != MemberRole.creator)
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove, color: Colors.red),
                        SizedBox(width: 8),
                        Text('除名'),
                      ],
                    ),
                  ),
                if (memberInfo.role == MemberRole.member)
                  const PopupMenuItem(
                    value: 'promote',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.green),
                        SizedBox(width: 8),
                        Text('管理者に昇格'),
                      ],
                    ),
                  ),
                if (memberInfo.role == MemberRole.admin)
                  const PopupMenuItem(
                    value: 'demote',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('一般メンバーに降格'),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(
    CircleMemberModel member,
    Function(String) approveMember,
    Function(String) rejectMember,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.1 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ユーザーID: ${member.userId}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            if (member.joinMessage?.isNotEmpty == true) ...[
              Text(
                'メッセージ: ${member.joinMessage}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => approveMember(member.userId),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('承認'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => rejectMember(member.userId),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text('拒否'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.creator:
        return const Color(0xFF8B5CF6); // Purple
      case MemberRole.admin:
        return const Color(0xFF10B981); // Green
      case MemberRole.member:
        return const Color(0xFF6B7280); // Gray
      case MemberRole.guest:
        return const Color(0xFFF59E0B); // Yellow
    }
  }

  String _getRoleDisplayName(MemberRole role) {
    switch (role) {
      case MemberRole.creator:
        return '作成者';
      case MemberRole.admin:
        return '管理者';
      case MemberRole.member:
        return 'メンバー';
      case MemberRole.guest:
        return 'ゲスト';
    }
  }
}