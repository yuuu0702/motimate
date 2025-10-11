import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../themes/app_theme.dart';

class MotivationScreen extends HookConsumerWidget {
  const MotivationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final motivationLevel = useState(3.0);
    final commentController = useTextEditingController();
    final isSubmitted = useState(false);
    final isLoading = useState(false);
    
    final motivationOptions = useMemoized(() => [
      {'level': 1, 'emoji': '😴', 'label': '今日はちょっと...', 'description': 'エネルギー不足', 'color': [0xFFFF6B6B, 0xFFEE5A52]},
      {'level': 2, 'emoji': '😐', 'label': 'あまり気分が...', 'description': '少し低調', 'color': [0xFFFF8E53, 0xFFFF7A00]},
      {'level': 3, 'emoji': '🙂', 'label': '普通かな', 'description': '平常通り', 'color': [0xFFFFD93D, 0xFFFFB800]},
      {'level': 4, 'emoji': '😊', 'label': 'やる気あり！', 'description': '前向きな気分', 'color': [0xFF6BCF7F, 0xFF4ADE80]},
      {'level': 5, 'emoji': '🔥', 'label': '超やる気！！', 'description': '最高のモチベーション', 'color': [0xFF667EEA, 0xFF764BA2]},
    ]);

    Future<void> submitMotivation() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ログインしていません。モチベーションを登録できません。'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      isLoading.value = true;

      try {
        await FirebaseFirestore.instance.collection('motivations').add({
          'userId': user.uid,
          'level': motivationLevel.value.round(),
          'comment': commentController.text,
          'timestamp': Timestamp.now(),
        });

        isSubmitted.value = true;
        
        // Auto-navigate back after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            context.pop();
          }
        });
      } catch (e) {
        isLoading.value = false;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('モチベーションの登録に失敗しました: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    // Success Screen
    if (isSubmitted.value) {
      return _buildSuccessScreen(isDarkMode, context);
    }

    // Main Screen
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
              // Modern Header with gradient background
              _buildModernHeader(isDarkMode, context),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      
                      // Current mood indicator
                      _buildCurrentMoodIndicator(motivationLevel.value, motivationOptions, isDarkMode),
                      
                      const SizedBox(height: 24),
                      
                      // Motivation Selection Section
                      _buildMotivationSelectionCard(motivationLevel, motivationOptions, isDarkMode),
                      
                      const SizedBox(height: 20),
                      
                      // Comment Section
                      _buildCommentSection(commentController, isDarkMode),
                      
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      _buildSubmitButton(isLoading.value, submitMotivation, isDarkMode),
                      
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

  Widget _buildSuccessScreen(bool isDarkMode, BuildContext context) {
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
            margin: const EdgeInsets.all(24),
            elevation: 8,
            color: AppTheme.cardBackground(isDarkMode),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '登録完了！',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '今日のやる気を記録しました',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.secondaryText(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'チームのモチベーション向上に貢献！',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'ホームに戻る',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDarkMode, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.1),
            AppTheme.accentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Semantics(
            label: '戻るボタン',
            hint: 'タップして前の画面に戻る',
            button: true,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.cardBackground(isDarkMode),
                foregroundColor: AppTheme.primaryText(isDarkMode),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日のやる気は？',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText(isDarkMode),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'あなたの気分をチームと共有しましょう',
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

  Widget _buildCurrentMoodIndicator(double currentLevel, List<Map<String, dynamic>> options, bool isDarkMode) {
    final currentOption = options.firstWhere((option) => option['level'] == currentLevel.round());
    final colors = currentOption['color'] as List<int>;
    
    return Semantics(
      label: '現在の気分',
      value: '${currentOption['label']}, レベル${currentLevel.round()}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(colors[0]), Color(colors[1])],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(colors[1]).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentOption['emoji'],
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Text(
                  currentOption['label'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  currentOption['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lv.${currentLevel.round()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationSelectionCard(ValueNotifier<double> motivationLevel, List<Map<String, dynamic>> options, bool isDarkMode) {
    return Card(
      elevation: 6,
      color: AppTheme.cardBackground(isDarkMode),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '気分を選んでください',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText(isDarkMode),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'タップして今の気分に一番近いものを選択',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 20),
            ...options.map((option) => _buildMotivationOption(option, motivationLevel, isDarkMode)),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationOption(Map<String, dynamic> option, ValueNotifier<double> motivationLevel, bool isDarkMode) {
    final isSelected = (motivationLevel.value.round() == option['level']);
    final colors = option['color'] as List<int>;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        label: '${option['label']}, ${option['description']}, レベル${option['level']}',
        hint: isSelected ? '選択中' : 'タップして選択',
        button: true,
        selected: isSelected,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              motivationLevel.value = option['level'].toDouble();
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Color(colors[0]), Color(colors[1])],
                      )
                    : null,
                color: isSelected ? null : AppTheme.containerBackground(isDarkMode),
                border: isSelected 
                    ? null 
                    : Border.all(
                        color: isDarkMode 
                            ? const Color(0xFF374151) 
                            : const Color(0xFFE5E7EB),
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(colors[1]).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0, isSelected ? 1.02 : 1.0, 1.0),
              child: Row(
                children: [
                  Text(
                    option['emoji'],
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['label'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppTheme.primaryText(isDarkMode),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected 
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppTheme.tertiaryText(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Lv.${option['level']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? Colors.white
                            : AppTheme.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentSection(TextEditingController commentController, bool isDarkMode) {
    return Card(
      elevation: 6,
      color: AppTheme.cardBackground(isDarkMode),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '一言コメント',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText(isDarkMode),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiaryText(isDarkMode).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '任意',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.tertiaryText(isDarkMode),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '今日の気分や理由があれば教えてください',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'コメント入力欄',
              hint: '任意でコメントを入力できます',
              textField: true,
              child: TextField(
                controller: commentController,
                style: TextStyle(color: AppTheme.primaryText(isDarkMode)),
                decoration: InputDecoration(
                  hintText: '例：今日は調子が良い、疲れている...',
                  hintStyle: TextStyle(color: AppTheme.tertiaryText(isDarkMode)),
                  filled: true,
                  fillColor: AppTheme.containerBackground(isDarkMode),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.accentColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading, VoidCallback onPressed, bool isDarkMode) {
    return Semantics(
      label: 'やる気を登録するボタン',
      hint: 'タップしてモチベーションを記録',
      button: true,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.tertiaryText(isDarkMode),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: isLoading ? 0 : 6,
            shadowColor: AppTheme.accentColor.withValues(alpha: 0.3),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '登録中...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'やる気を登録する',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
