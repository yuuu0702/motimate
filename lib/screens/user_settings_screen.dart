import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motimate/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:motimate/main.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final _displayNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _groupController = TextEditingController();
  final _bioController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDarkMode = false;
  bool _notificationsEnabled = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNotificationStatus();
    _loadThemePreference();
  }

  void _loadThemePreference() {
    // ダークテーマは準備中のため、常にライトテーマ
    setState(() {
      _isDarkMode = false;
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _departmentController.dispose();
    _groupController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _userData = data;
          _displayNameController.text = data['displayName'] ?? '';
          _departmentController.text = data['department'] ?? '';
          _groupController.text = data['group'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _isDarkMode = data['isDarkMode'] ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotificationStatus() async {
    try {
      final isEnabled = await NotificationService.isNotificationEnabled();
      setState(() {
        _notificationsEnabled = isEnabled;
      });
    } catch (e) {
      setState(() {
        _notificationsEnabled = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // 通知を有効にする
      final granted = await NotificationService.requestNotificationPermission();
      setState(() {
        _notificationsEnabled = granted;
      });
      
      if (granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('通知が有効になりました'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('通知の許可が拒否されました'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      // 通知を無効にする（設定画面に案内）
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '通知設定',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            content: const Text(
              '通知を無効にするには、端末の設定画面から変更してください。',
              style: TextStyle(
                color: Color(0xFF374151),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'キャンセル',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await NotificationService.openSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
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

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'displayName': _displayNameController.text.trim(),
        'department': _departmentController.text.trim(),
        'group': _groupController.text.trim(),
        'bio': _bioController.text.trim(),
        'isDarkMode': _isDarkMode,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールを更新しました'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新に失敗しました: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'ログアウト',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          content: const Text(
            'ログアウトしてもよろしいですか？',
            style: TextStyle(
              color: Color(0xFF374151),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'キャンセル',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header (追加)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Text(
                      '設定',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
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
                                  const Icon(
                                    Icons.edit,
                                    color: Color(0xFF667eea),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'プロフィール編集',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Username (read-only)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ユーザー名',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.alternate_email,
                                          color: Color(0xFF94A3B8),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _userData?['username'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF6B7280),
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
                                controller: _displayNameController,
                                label: '表示名',
                                hint: '田中 太郎',
                                icon: Icons.person_outline,
                              ),
                              
                              const SizedBox(height: 20),

                              // Department
                              _buildTextField(
                                controller: _departmentController,
                                label: '部署',
                                hint: '営業部',
                                icon: Icons.business,
                              ),
                              
                              const SizedBox(height: 20),

                              // Group
                              _buildTextField(
                                controller: _groupController,
                                label: '所属グループ',
                                hint: '第1営業課',
                                icon: Icons.groups,
                              ),
                              
                              const SizedBox(height: 20),

                              // Bio
                              _buildTextField(
                                controller: _bioController,
                                label: '自己紹介',
                                hint: 'バスケが大好きです！一緒に頑張りましょう🏀',
                                icon: Icons.chat_bubble_outline,
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
                                  const Icon(
                                    Icons.palette,
                                    color: Color(0xFF667eea),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'テーマ設定',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.construction,
                                      color: Colors.orange.withOpacity(0.7),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ダークテーマ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            '🚧 準備中です',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.orange[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.orange.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Coming Soon',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[700],
                                        ),
                                      ),
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
                                  const Icon(
                                    Icons.notifications,
                                    color: Color(0xFF667eea),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '通知設定',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _notificationsEnabled 
                                          ? Icons.notifications_active 
                                          : Icons.notifications_off,
                                      color: const Color(0xFF667eea),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _notificationsEnabled ? 'プッシュ通知が有効' : 'プッシュ通知が無効',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                          Text(
                                            _notificationsEnabled 
                                                ? '練習日決定などの重要な通知を受け取ります' 
                                                : '通知を受け取りません',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _notificationsEnabled,
                                      onChanged: _toggleNotifications,
                                      activeColor: const Color(0xFF667eea),
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
                                  const Icon(
                                    Icons.account_circle,
                                    color: Color(0xFF667eea),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'アカウント',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Email info
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      color: Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'メールアドレス',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                          Text(
                                            FirebaseAuth.instance.currentUser?.email ?? 'Unknown',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
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
                                  onPressed: _signOut,
                                  icon: const Icon(Icons.logout, size: 20),
                                  label: const Text(
                                    'ログアウト',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
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
                    ],
                  ),
                ),
              ),

              // Save Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        // 白に設定
                        colors: [Color(0xFF667eea), Color(0xFF667eea)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      icon: _isSaving
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
                        _isSaving ? '保存中...' : 'プロフィールを保存',
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
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}