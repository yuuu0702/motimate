import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../themes/app_theme.dart';
import '../routing/app_router.dart';

class MotivationScreen extends ConsumerStatefulWidget {
  const MotivationScreen({super.key});

  @override
  ConsumerState<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends ConsumerState<MotivationScreen> {
  double _motivationLevel = 3.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitted = false;
  
  final List<Map<String, dynamic>> motivationOptions = [
    {'level': 1, 'emoji': '😴', 'label': '今日はちょっと...', 'color': [0xFF9CA3AF, 0xFF6B7280]},
    {'level': 2, 'emoji': '😐', 'label': 'あまり気分が...', 'color': [0xFF60A5FA, 0xFF3B82F6]},
    {'level': 3, 'emoji': '🙂', 'label': '普通かな', 'color': [0xFFFBBF24, 0xFFF59E0B]},
    {'level': 4, 'emoji': '😊', 'label': 'やる気あり！', 'color': [0xFFFB923C, 0xFFEA580C]},
    {'level': 5, 'emoji': '🔥', 'label': '超やる気！！', 'color': [0xFFF87171, 0xFFEF4444]},
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitMotivation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインしていません。モチベーションを登録できません。')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('motivations').add({
        'userId': user.uid,
        'level': _motivationLevel.round(),
        'comment': _commentController.text,
        'timestamp': Timestamp.now(),
      });

      setState(() {
        _isSubmitted = true;
      });
      
      // Auto-navigate back after 2 seconds
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('モチベーションの登録に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    
    if (_isSubmitted) {
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
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '✅',
                      style: TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '登録完了！',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '今日のやる気を記録しました',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.tertiaryText(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('ホームに戻る'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.cardColor(isDarkMode).withValues(alpha: 0.8),
                        shape: const CircleBorder(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '今日のやる気は？',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText(isDarkMode),
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
                      // Motivation Selection Card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                '気分を選んでね！',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryText(isDarkMode),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ...motivationOptions.map((option) => _buildMotivationOption(option, isDarkMode)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Comment Section
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
                              Text(
                                '一言コメント（任意）',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryText(isDarkMode),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: '今日の気分や理由があれば...',
                                  filled: true,
                                  fillColor: AppTheme.containerBackground(isDarkMode),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submitMotivation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'やる気を登録する',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
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

  Widget _buildMotivationOption(Map<String, dynamic> option, bool isDarkMode) {
    final isSelected = (_motivationLevel.round() == option['level']);
    final colors = option['color'] as List<int>;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _motivationLevel = option['level'].toDouble();
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [Color(colors[0]), Color(colors[1])],
                    )
                  : null,
              color: isSelected ? null : AppTheme.containerBackground(isDarkMode),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(colors[1]).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
            child: Row(
              children: [
                Text(
                  option['emoji'],
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option['label'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.primaryText(isDarkMode),
                    ),
                  ),
                ),
                Text(
                  'Lv.${option['level']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected 
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppTheme.tertiaryText(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
