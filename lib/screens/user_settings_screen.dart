import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../services/notification_service.dart';
import '../core/theme/theme_controller.dart';
import '../themes/app_theme.dart';
import '../providers/providers.dart';

class UserSettingsScreen extends HookConsumerWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final displayNameController = useTextEditingController();
    final departmentController = useTextEditingController();
    final groupController = useTextEditingController();
    final bioController = useTextEditingController();
    
    final isLoading = useState(true);
    final isSaving = useState(false);
    final notificationsEnabled = useState(false);
    final userData = useState<Map<String, dynamic>?>(null);

    // Load user data on mount
    useEffect(() {
      Future<void> loadUserData() async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            userData.value = data;
            displayNameController.text = data['displayName'] ?? '';
            departmentController.text = data['department'] ?? '';
            groupController.text = data['group'] ?? '';
            bioController.text = data['bio'] ?? '';
            isLoading.value = false;
          }
        } catch (e) {
          isLoading.value = false;
        }
      }

      Future<void> loadNotificationStatus() async {
        try {
          final isEnabled = await NotificationService.isNotificationEnabled();
          notificationsEnabled.value = isEnabled;
        } catch (e) {
          notificationsEnabled.value = false;
        }
      }

      loadUserData();
      loadNotificationStatus();
      return null;
    }, []);

    Future<void> toggleNotifications(bool value) async {
      if (value) {
        // 通知を有効にする
        final granted = await NotificationService.requestNotificationPermission();
        notificationsEnabled.value = granted;
        
        if (granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('通知が有効になりました'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('通知の許可が拒否されました'),
              backgroundColor: AppTheme.warningColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // 通知を無効にする（設定画面に案内）
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              backgroundColor: AppTheme.cardBackground(isDarkMode),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                '通知設定',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText(isDarkMode),
                ),
              ),
              content: Text(
                '通知を無効にするには、端末の設定画面から変更してください。',
                style: TextStyle(
                  color: AppTheme.secondaryText(isDarkMode),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'キャンセル',
                    style: TextStyle(color: AppTheme.tertiaryText(isDarkMode)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await NotificationService.openSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '設定を開く',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      }
    }

    Future<void> saveProfile() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      isSaving.value = true;

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'displayName': displayNameController.text.trim(),
          'department': departmentController.text.trim(),
          'group': groupController.text.trim(),
          'bio': bioController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('プロフィールを更新しました'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新に失敗しました: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        isSaving.value = false;
      }
    }

    Future<void> signOut() async {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: AppTheme.cardBackground(isDarkMode),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'ログアウト',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            content: Text(
              'ログアウトしてもよろしいですか？',
              style: TextStyle(
                color: AppTheme.secondaryText(isDarkMode),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'キャンセル',
                  style: TextStyle(color: AppTheme.tertiaryText(isDarkMode)),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await FirebaseAuth.instance.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ログアウト',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    }

    if (isLoading.value) {
      return Scaffold(
        backgroundColor: AppTheme.background(isDarkMode),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.accentColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background(isDarkMode),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.backgroundGradient(isDarkMode),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accentColor.withValues(alpha: 0.1), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Semantics(
                  header: true,
                  label: '設定画面',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.accentColor, AppTheme.accentColor.withValues(alpha: 0.8)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '設定',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText(isDarkMode),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Profile Section
                      Card(
                        elevation: 8,
                        color: AppTheme.cardBackground(isDarkMode),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: AppTheme.accentColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'プロフィール編集',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryText(isDarkMode),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Username (read-only)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor(isDarkMode),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ユーザー名',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryText(isDarkMode),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.alternate_email,
                                          color: AppTheme.tertiaryText(isDarkMode),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          userData.value?['username'] ?? 'Unknown',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppTheme.secondaryText(isDarkMode),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),

                              // Display Name
                              _buildTextField(
                                controller: displayNameController,
                                label: '表示名',
                                hint: '田中 太郎',
                                icon: Icons.person_outline,
                                isDarkMode: isDarkMode,
                              ),
                              
                              const SizedBox(height: 20),

                              // Department
                              _buildTextField(
                                controller: departmentController,
                                label: '部署',
                                hint: '営業部',
                                icon: Icons.business,
                                isDarkMode: isDarkMode,
                              ),
                              
                              const SizedBox(height: 20),

                              // Group
                              _buildTextField(
                                controller: groupController,
                                label: '所属グループ',
                                hint: '第1営業課',
                                icon: Icons.groups,
                                isDarkMode: isDarkMode,
                              ),
                              
                              const SizedBox(height: 20),

                              // Bio
                              _buildTextField(
                                controller: bioController,
                                label: '自己紹介',
                                hint: 'バスケが大好きです！一緒に頑張りましょう🏀',
                                icon: Icons.chat_bubble_outline,
                                isDarkMode: isDarkMode,
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Theme Settings
                      Card(
                        elevation: 8,
                        color: AppTheme.cardBackground(isDarkMode),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.palette,
                                    color: AppTheme.accentColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'テーマ設定',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryText(isDarkMode),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor(isDarkMode),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                      color: AppTheme.accentColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isDarkMode ? 'ダークテーマ' : 'ライトテーマ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryText(isDarkMode),
                                            ),
                                          ),
                                          Text(
                                            isDarkMode ? 'ダークモードで表示しています' : 'ライトモードで表示しています',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.secondaryText(isDarkMode),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: isDarkMode,
                                      onChanged: (value) async {
                                        await ref.read(themeControllerProvider.notifier).toggleTheme();
                                      },
                                      activeColor: AppTheme.accentColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Notification Settings
                      Card(
                        elevation: 8,
                        color: AppTheme.cardBackground(isDarkMode),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications,
                                    color: AppTheme.accentColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '通知設定',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryText(isDarkMode),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor(isDarkMode),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      notificationsEnabled.value 
                                          ? Icons.notifications_active 
                                          : Icons.notifications_off,
                                      color: AppTheme.accentColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notificationsEnabled.value ? 'プッシュ通知が有効' : 'プッシュ通知が無効',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryText(isDarkMode),
                                            ),
                                          ),
                                          Text(
                                            notificationsEnabled.value 
                                                ? 'バスケ日決定などの重要な通知を受け取ります' 
                                                : '通知を受け取りません',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.secondaryText(isDarkMode),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: notificationsEnabled.value,
                                      onChanged: toggleNotifications,
                                      activeColor: AppTheme.accentColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Account Actions
                      Card(
                        elevation: 8,
                        color: AppTheme.cardBackground(isDarkMode),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_circle,
                                    color: AppTheme.accentColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'アカウント',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryText(isDarkMode),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Email info
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor(isDarkMode),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      color: AppTheme.tertiaryText(isDarkMode),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'メールアドレス',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryText(isDarkMode),
                                            ),
                                          ),
                                          Text(
                                            FirebaseAuth.instance.currentUser?.email ?? 'Unknown',
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
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Logout button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: signOut,
                                  icon: const Icon(Icons.logout, size: 20),
                                  label: const Text(
                                    'ログアウト',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.errorColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Copyright
                      Center(
                        child: Text(
                          '© 2025 WATANABE YUDAI',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.tertiaryText(isDarkMode),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Save Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Semantics(
                  button: true,
                  label: isSaving.value ? '保存中' : 'プロフィールを保存',
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.accentColor, AppTheme.accentColor.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: isSaving.value ? null : saveProfile,
                        icon: isSaving.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save, size: 20),
                        label: Text(
                          isSaving.value ? '保存中...' : 'プロフィールを保存',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(isDarkMode),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor(isDarkMode)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color: AppTheme.primaryText(isDarkMode),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppTheme.tertiaryText(isDarkMode)),
              prefixIcon: Icon(icon, color: AppTheme.tertiaryText(isDarkMode)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}