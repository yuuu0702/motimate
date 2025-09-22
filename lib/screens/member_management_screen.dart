import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/circle_member_model.dart';
import '../models/user_model.dart';
import '../services/permission_service.dart';
import '../providers/providers.dart';

class MemberManagementScreen extends HookConsumerWidget {
  const MemberManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circleMemberService = ref.watch(circleMemberServiceProvider);
    final permissionService = ref.watch(permissionServiceProvider);

    final isLoading = useState(false);
    final error = useState<String?>(null);
    final activeMembers = useState<List<Map<String, dynamic>>>([]);
    final pendingMembers = useState<List<CircleMemberModel>>([]);
    final hasManagePermission = useState(false);
    final selectedTab = useState(0);

    // 現在のサークルID（実際の実装では動的に取得）
    const circleId = 'current_circle_id';

    // データ読み込み
    Future<void> loadData() async {
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
      loadData();
      return null;
    }, []);

    // メンバー承認
    Future<void> approveMember(String userId) async {
      try {
        isLoading.value = true;
        await circleMemberService.approveMember(circleId, userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('メンバーを承認しました')),
          );
        }

        await loadData(); // データを再読み込み
      } catch (e) {
        error.value = 'メンバーの承認に失敗しました: $e';
      } finally {
        isLoading.value = false;
      }
    }

    // メンバー拒否
    Future<void> rejectMember(String userId) async {
      try {
        isLoading.value = true;
        await circleMemberService.rejectMember(circleId, userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('参加申請を拒否しました')),
          );
        }

        await loadData(); // データを再読み込み
      } catch (e) {
        error.value = '参加申請の拒否に失敗しました: $e';
      } finally {
        isLoading.value = false;
      }
    }

    // メンバー除名
    Future<void> removeMember(String userId, String userName) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('メンバーを除名'),
          content: Text('$userName さんを除名しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('除名'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      try {
        isLoading.value = true;
        await circleMemberService.removeMember(circleId, userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$userName さんを除名しました')),
          );
        }

        await loadData(); // データを再読み込み
      } catch (e) {
        error.value = 'メンバーの除名に失敗しました: $e';
      } finally {
        isLoading.value = false;
      }
    }

    // ロール変更
    Future<void> changeRole(String userId, String userName, MemberRole newRole) async {
      try {
        isLoading.value = true;
        await circleMemberService.updateMemberRole(circleId, userId, newRole);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$userName さんの権限を変更しました')),
          );
        }

        await loadData(); // データを再読み込み
      } catch (e) {
        error.value = '権限の変更に失敗しました: $e';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('メンバー管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
        bottom: TabBar(
          controller: TabController(
            length: hasManagePermission.value ? 2 : 1,
            vsync: Scaffold.of(context),
            initialIndex: selectedTab.value,
          ),
          onTap: (index) => selectedTab.value = index,
          tabs: [
            const Tab(text: 'メンバー'),
            if (hasManagePermission.value) const Tab(text: '参加申請'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
          children: [
            if (error.value != null) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error.value!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => error.value = null,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            Expanded(
              child: TabBarView(
                controller: TabController(
                  length: hasManagePermission.value ? 2 : 1,
                  vsync: Scaffold.of(context),
                  initialIndex: selectedTab.value,
                ),
                children: [
                  // アクティブメンバー一覧
                  _buildActiveMembersList(
                    context,
                    activeMembers.value,
                    hasManagePermission.value,
                    changeRole,
                    removeMember,
                  ),

                  // 参加申請一覧（管理権限がある場合のみ）
                  if (hasManagePermission.value)
                    _buildPendingMembersList(
                      context,
                      pendingMembers.value,
                      approveMember,
                      rejectMember,
                    ),
                ],
              ),
            ),
          ],
        ),
          if (isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveMembersList(
    BuildContext context,
    List<Map<String, dynamic>> members,
    bool hasManagePermission,
    Future<void> Function(String, String, MemberRole) onRoleChange,
    Future<void> Function(String, String) onRemove,
  ) {
    if (members.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('メンバーがいません'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final memberData = members[index];
        final member = memberData['member'] as CircleMemberModel;
        final user = memberData['user'] as UserModel?;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                (user?.displayName ?? '不明').substring(0, 1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(user?.displayName ?? '不明なユーザー'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.role.displayName),
                Text(
                  '参加日: ${_formatDate(member.joinedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (member.stats.participationCount > 0)
                  Text(
                    '参加回数: ${member.stats.participationCount}回',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            trailing: hasManagePermission && !member.role.isCreator
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'promote':
                          _showRoleChangeDialog(
                            context,
                            user?.displayName ?? '不明',
                            member.role,
                            onRoleChange,
                            member.userId,
                          );
                          break;
                        case 'remove':
                          onRemove(member.userId, user?.displayName ?? '不明');
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!member.role.isAdmin)
                        const PopupMenuItem(
                          value: 'promote',
                          child: Text('管理者にする'),
                        ),
                      if (member.role.isAdmin)
                        const PopupMenuItem(
                          value: 'promote',
                          child: Text('メンバーにする'),
                        ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text('除名する'),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildPendingMembersList(
    BuildContext context,
    List<CircleMemberModel> pendingMembers,
    Future<void> Function(String) onApprove,
    Future<void> Function(String) onReject,
  ) {
    if (pendingMembers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_disabled, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('参加申請はありません'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingMembers.length,
      itemBuilder: (context, index) {
        final member = pendingMembers[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('ユーザーID: ${member.userId}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('申請日: ${_formatDate(member.joinedAt)}'),
                if (member.joinMessage != null && member.joinMessage!.isNotEmpty)
                  Text('メッセージ: ${member.joinMessage}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => onApprove(member.userId),
                  tooltip: '承認',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => onReject(member.userId),
                  tooltip: '拒否',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRoleChangeDialog(
    BuildContext context,
    String userName,
    MemberRole currentRole,
    Future<void> Function(String, String, MemberRole) onRoleChange,
    String userId,
  ) {
    final newRole = currentRole.isAdmin ? MemberRole.member : MemberRole.admin;
    final actionText = currentRole.isAdmin ? 'メンバーにする' : '管理者にする';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('権限変更'),
        content: Text('$userName さんを$actionText しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRoleChange(userId, userName, newRole);
            },
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}