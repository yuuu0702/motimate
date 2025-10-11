import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/circle_model.dart';
import '../services/circle_service.dart';
import '../services/permission_service.dart';
import '../providers/providers.dart';

class CircleSettingsScreen extends HookConsumerWidget {
  const CircleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circleService = ref.watch(circleServiceProvider);
    final permissionService = ref.watch(permissionServiceProvider);

    final isLoading = useState(false);
    final error = useState<String?>(null);
    final circle = useState<CircleModel?>(null);
    final hasPermission = useState(false);

    // Form controllers
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final selectedCategory = useState<String>('');
    final isPublic = useState(true);
    final requiresApproval = useState(false);
    final selectedIcon = useState<IconType>(IconType.groups);
    final selectedColor = useState<ColorTheme>(ColorTheme.blue);
    final allowInvites = useState(true);
    final enableNotifications = useState(true);

    // 現在のサークル情報を取得
    useEffect(() {
      void loadCircleData() async {
        try {
          isLoading.value = true;
          error.value = null;

          // TODO: 現在選択中のサークルIDを取得
          const circleId = 'current_circle_id'; // 実際の実装では現在のサークルIDを取得

          final circleData = await circleService.getCircle(circleId);
          if (circleData == null) {
            error.value = 'サークル情報が見つかりません';
            return;
          }

          final canEdit = await permissionService.hasPermission(circleId, Permission.editCircle);
          hasPermission.value = canEdit;

          if (!canEdit) {
            error.value = 'このサークルの設定を変更する権限がありません';
            return;
          }

          circle.value = circleData;
          nameController.text = circleData.name;
          descriptionController.text = circleData.description;
          selectedCategory.value = circleData.category;
          isPublic.value = circleData.privacy.isPublic;
          requiresApproval.value = circleData.privacy.requiresApproval;
          selectedIcon.value = circleData.settings.iconTypeEnum;
          selectedColor.value = circleData.settings.colorThemeEnum;
          allowInvites.value = circleData.settings.allowInvites;
          enableNotifications.value = circleData.settings.enableNotifications;

        } catch (e) {
          error.value = '設定の読み込みに失敗しました: $e';
        } finally {
          isLoading.value = false;
        }
      }

      loadCircleData();
      return null;
    }, []);

    Future<void> updateCircleSettings() async {
      if (circle.value == null) return;

      try {
        isLoading.value = true;
        error.value = null;

        final updatedSettings = CircleSettings(
          iconType: selectedIcon.value.id,
          colorTheme: selectedColor.value.id,
          allowInvites: allowInvites.value,
          enableNotifications: enableNotifications.value,
        );

        final updatedPrivacy = PrivacySettings(
          isPublic: isPublic.value,
          requiresApproval: requiresApproval.value,
        );

        await circleService.updateCircle(
          circle.value!.id,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          category: selectedCategory.value,
          settings: updatedSettings,
          privacy: updatedPrivacy,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('サークル設定を更新しました')),
          );
          context.pop();
        }
      } catch (e) {
        error.value = '設定の更新に失敗しました: $e';
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> regenerateInviteCode() async {
      if (circle.value == null) return;

      try {
        isLoading.value = true;
        final newCode = await circleService.regenerateInviteCode(circle.value!.id);

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('招待コードを再生成しました'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('新しい招待コード:'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      newCode,
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
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        error.value = '招待コードの再生成に失敗しました: $e';
      } finally {
        isLoading.value = false;
      }
    }

    if (error.value != null && !hasPermission.value) {
      return Scaffold(
        appBar: AppBar(title: const Text('サークル設定')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                error.value!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('戻る'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('サークル設定'),
        actions: [
          if (hasPermission.value)
            TextButton(
              onPressed: isLoading.value ? null : updateCircleSettings,
              child: const Text('保存'),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error.value != null && hasPermission.value) ...[
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
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
                const SizedBox(height: 16),
              ],

              // 基本情報
              _buildSection(
                context,
                title: '基本情報',
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'サークル名',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    maxLength: 50,
                    enabled: hasPermission.value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: '説明',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    maxLines: 3,
                    maxLength: 500,
                    enabled: hasPermission.value,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory.value.isEmpty ? null : selectedCategory.value,
                    decoration: const InputDecoration(
                      labelText: 'カテゴリー',
                      border: OutlineInputBorder(),
                    ),
                    items: CircleCategory.values.map((category) => DropdownMenuItem(
                      value: category.value,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 20),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    )).toList(),
                    onChanged: hasPermission.value
                        ? (value) => selectedCategory.value = value ?? ''
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 見た目設定
              _buildSection(
                context,
                title: '見た目設定',
                children: [
                  DropdownButtonFormField<IconType>(
                    initialValue: selectedIcon.value,
                    decoration: const InputDecoration(
                      labelText: 'アイコン',
                      border: OutlineInputBorder(),
                    ),
                    items: IconType.values.map((icon) => DropdownMenuItem(
                      value: icon,
                      child: Row(
                        children: [
                          Icon(icon.iconData, size: 20),
                          const SizedBox(width: 8),
                          Text(icon.displayName),
                        ],
                      ),
                    )).toList(),
                    onChanged: hasPermission.value
                        ? (value) => selectedIcon.value = value ?? IconType.groups
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ColorTheme>(
                    initialValue: selectedColor.value,
                    decoration: const InputDecoration(
                      labelText: 'カラーテーマ',
                      border: OutlineInputBorder(),
                    ),
                    items: ColorTheme.values.map((color) => DropdownMenuItem(
                      value: color,
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: color.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(color.displayName),
                        ],
                      ),
                    )).toList(),
                    onChanged: hasPermission.value
                        ? (value) => selectedColor.value = value ?? ColorTheme.blue
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // プライバシー設定
              _buildSection(
                context,
                title: 'プライバシー設定',
                children: [
                  SwitchListTile(
                    title: const Text('公開サークル'),
                    subtitle: const Text('検索結果に表示され、誰でも参加申請できます'),
                    value: isPublic.value,
                    onChanged: hasPermission.value
                        ? (value) => isPublic.value = value
                        : null,
                  ),
                  SwitchListTile(
                    title: const Text('参加に承認が必要'),
                    subtitle: const Text('新規メンバーの参加時に管理者の承認が必要になります'),
                    value: requiresApproval.value,
                    onChanged: hasPermission.value
                        ? (value) => requiresApproval.value = value
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 機能設定
              _buildSection(
                context,
                title: '機能設定',
                children: [
                  SwitchListTile(
                    title: const Text('招待機能'),
                    subtitle: const Text('メンバーが他のユーザーを招待できます'),
                    value: allowInvites.value,
                    onChanged: hasPermission.value
                        ? (value) => allowInvites.value = value
                        : null,
                  ),
                  SwitchListTile(
                    title: const Text('通知機能'),
                    subtitle: const Text('活動決定や重要な更新の通知を送信します'),
                    value: enableNotifications.value,
                    onChanged: hasPermission.value
                        ? (value) => enableNotifications.value = value
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 招待コード
              if (hasPermission.value) ...[
                _buildSection(
                  context,
                  title: '招待コード',
                  children: [
                    ListTile(
                      title: const Text('招待コードを再生成'),
                      subtitle: const Text('新しい招待コードを生成します（古いコードは無効になります）'),
                      trailing: const Icon(Icons.refresh),
                      onTap: regenerateInviteCode,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // 危険な操作
              if (hasPermission.value) ...[
                _buildSection(
                  context,
                  title: '危険な操作',
                  children: [
                    ListTile(
                      title: const Text('サークルを削除'),
                      subtitle: const Text('サークルを完全に削除します（この操作は取り消せません）'),
                      trailing: const Icon(Icons.delete_forever, color: Colors.red),
                      onTap: () => _showDeleteConfirmation(context, circleService, circle.value?.id),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
          if (isLoading.value)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CircleService circleService, String? circleId) {
    if (circleId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('サークル削除'),
        content: const Text('本当にこのサークルを削除しますか？この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await circleService.deleteCircle(circleId);
                if (context.mounted) {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                  context.go('/'); // ホーム画面に戻る
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('削除に失敗しました: $e')),
                  );
                }
              }
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}