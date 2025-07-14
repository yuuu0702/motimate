import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';  // 未使用のため削除

import '../models/user_location_model.dart';
import '../services/user_location_service.dart';
import '../themes/app_theme.dart';
import '../core/theme/theme_controller.dart';
import 'user_location_screen.dart';

/// ユーザー拠点一覧画面
/// 
/// 登録済み拠点の表示、編集、削除機能を提供
class UserLocationsListScreen extends ConsumerStatefulWidget {
  const UserLocationsListScreen({super.key});

  @override
  ConsumerState<UserLocationsListScreen> createState() => _UserLocationsListScreenState();
}

class _UserLocationsListScreenState extends ConsumerState<UserLocationsListScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(isDarkMode),
      appBar: _buildAppBar(isDarkMode),
      body: _buildBody(isDarkMode),
      floatingActionButton: _buildFAB(isDarkMode),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: AppTheme.cardColor(isDarkMode),
      elevation: 0,
      title: Text(
        '拠点管理',
        style: TextStyle(
          color: AppTheme.primaryText(isDarkMode),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back,
          color: AppTheme.primaryText(isDarkMode),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showHelpDialog,
          icon: Icon(
            Icons.help_outline,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(bool isDarkMode) {
    return StreamBuilder<List<UserLocationModel>>(
      stream: UserLocationService.instance.watchUserLocations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(isDarkMode, snapshot.error.toString());
        }

        final locations = snapshot.data ?? [];

        if (locations.isEmpty) {
          return _buildEmptyState(isDarkMode);
        }

        return _buildLocationsList(locations, isDarkMode);
      },
    );
  }

  Widget _buildLocationsList(List<UserLocationModel> locations, bool isDarkMode) {
    // メイン拠点を先頭に、その他を作成日順で並べる
    final sortedLocations = List<UserLocationModel>.from(locations);
    sortedLocations.sort((a, b) {
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      return b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0;
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedLocations.length,
      itemBuilder: (context, index) {
        return _buildLocationCard(sortedLocations[index], isDarkMode);
      },
    );
  }

  Widget _buildLocationCard(UserLocationModel location, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: location.isPrimary
            ? Border.all(color: const Color(0xFFF59E0B), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor(location.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(location.type),
            color: _getTypeColor(location.type),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                location.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText(isDarkMode),
                ),
              ),
            ),
            if (location.isPrimary) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'メイン',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              location.address,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppTheme.tertiaryText(isDarkMode),
                ),
                const SizedBox(width: 4),
                Text(
                  location.type.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.tertiaryText(isDarkMode),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, location),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('編集'),
                ],
              ),
            ),
            if (!location.isPrimary)
              const PopupMenuItem(
                value: 'setPrimary',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16),
                    SizedBox(width: 8),
                    Text('メインに設定'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('削除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          icon: Icon(
            Icons.more_vert,
            color: AppTheme.tertiaryText(isDarkMode),
          ),
        ),
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
            Icon(
              Icons.location_off,
              size: 64,
              color: AppTheme.tertiaryText(isDarkMode),
            ),
            const SizedBox(height: 16),
            Text(
              '拠点が登録されていません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'よく利用するエリアを登録すると、\nチーム全体で最適な体育館を\nおすすめできます',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.tertiaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addLocation,
              icon: const Icon(Icons.add),
              label: const Text('拠点を追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.tertiaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(bool isDarkMode) {
    return FloatingActionButton(
      onPressed: _addLocation,
      backgroundColor: const Color(0xFF667eea),
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  IconData _getTypeIcon(LocationType type) {
    switch (type) {
      case LocationType.home:
        return Icons.home;
      case LocationType.work:
        return Icons.work;
      case LocationType.school:
        return Icons.school;
      case LocationType.other:
        return Icons.place;
    }
  }

  Color _getTypeColor(LocationType type) {
    switch (type) {
      case LocationType.home:
        return const Color(0xFF10B981);
      case LocationType.work:
        return const Color(0xFF667eea);
      case LocationType.school:
        return const Color(0xFFF59E0B);
      case LocationType.other:
        return const Color(0xFF8B5CF6);
    }
  }

  void _handleMenuAction(String action, UserLocationModel location) {
    switch (action) {
      case 'edit':
        _editLocation(location);
        break;
      case 'setPrimary':
        _setPrimaryLocation(location);
        break;
      case 'delete':
        _deleteLocation(location);
        break;
    }
  }

  Future<void> _addLocation() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const UserLocationScreen(),
      ),
    );

    if (result == true) {
      _showSuccessSnackBar('拠点を追加しました');
    }
  }

  Future<void> _editLocation(UserLocationModel location) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => UserLocationScreen(editLocation: location),
      ),
    );

    if (result == true) {
      _showSuccessSnackBar('拠点を更新しました');
    }
  }

  Future<void> _setPrimaryLocation(UserLocationModel location) async {
    final success = await UserLocationService.instance.setPrimaryLocation(location.id);
    if (success) {
      _showSuccessSnackBar('メイン拠点を設定しました');
    } else {
      _showErrorSnackBar('メイン拠点の設定に失敗しました');
    }
  }

  Future<void> _deleteLocation(UserLocationModel location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拠点を削除'),
        content: Text('「${location.name}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await UserLocationService.instance.deleteUserLocation(location.id);
      if (success) {
        _showSuccessSnackBar('拠点を削除しました');
      } else {
        _showErrorSnackBar('拠点の削除に失敗しました');
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拠点管理について'),
        content: const Text(
          '拠点機能により、チーム全体で最適な体育館をおすすめできます。\n\n'
          '• エリア単位での登録でプライバシーを保護\n'
          '• メイン拠点はおすすめ計算で優先されます\n'
          '• 複数の拠点を登録可能（自宅、職場等）\n'
          '• チームメンバーには大まかな位置のみ共有'
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}