import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../models/circle_model.dart';
import '../providers/providers.dart';
import '../themes/app_theme.dart';

/// サークル作成画面
///
/// 新しいサークルの作成フォームを提供
/// カテゴリ選択、プライバシー設定、テーマカスタマイズ機能
class CircleCreationScreen extends HookConsumerWidget {
  const CircleCreationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circleService = ref.watch(circleServiceProvider);
    final isDarkMode = ref.watch(themeProvider);
    final isLoading = useState(false);

    // Form controllers
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();

    // Form state
    final selectedCategory = useState<CircleCategory>(CircleCategory.sports);
    final selectedIconType = useState<IconType>(IconType.groups);
    final selectedColorTheme = useState<ColorTheme>(ColorTheme.blue);
    final activityName = useState('活動');
    final isPublic = useState(true);
    final requiresApproval = useState(false);

    // Form validation
    final formKey = useMemoized(() => GlobalKey<FormState>());

    Future<void> onCreateCircle() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;
      try {
        final settings = CircleSettings(
          iconType: selectedIconType.value.id,
          colorTheme: selectedColorTheme.value.id,
          activityName: activityName.value,
        );

        final privacy = PrivacySettings(
          isPublic: isPublic.value,
          searchable: isPublic.value,
          requiresApproval: requiresApproval.value,
          showMemberCount: true,
          showActivity: true,
        );

        await circleService.createCircle(
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          category: selectedCategory.value.value,
          settings: settings,
          privacy: privacy,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('サークルを作成しました！'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          // サークル選択画面に戻る
          context.go('/circle-selection');
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

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preview card
                        _buildPreviewCard(
                          selectedIconType.value,
                          selectedColorTheme.value,
                          nameController.text.isNotEmpty
                              ? nameController.text
                              : 'サークル名',
                          descriptionController.text.isNotEmpty
                              ? descriptionController.text
                              : '説明文を入力してください',
                          isDarkMode,
                        ),
                        const SizedBox(height: 32),

                        // Basic information
                        _buildSectionTitle('基本情報', isDarkMode),
                        const SizedBox(height: 16),
                        _buildNameField(nameController, isDarkMode),
                        const SizedBox(height: 16),
                        _buildDescriptionField(descriptionController, isDarkMode),
                        const SizedBox(height: 16),
                        _buildCategorySelector(selectedCategory, isDarkMode),
                        const SizedBox(height: 32),

                        // Appearance
                        _buildSectionTitle('外観設定', isDarkMode),
                        const SizedBox(height: 16),
                        _buildIconSelector(selectedIconType, isDarkMode),
                        const SizedBox(height: 16),
                        _buildColorSelector(selectedColorTheme, isDarkMode),
                        const SizedBox(height: 16),
                        _buildActivityNameField(activityName, isDarkMode),
                        const SizedBox(height: 32),

                        // Privacy settings
                        _buildSectionTitle('プライバシー設定', isDarkMode),
                        const SizedBox(height: 16),
                        _buildPrivacySettings(isPublic, requiresApproval, isDarkMode),
                        const SizedBox(height: 40),

                        // Create button
                        _buildCreateButton(onCreateCircle, isLoading.value, isDarkMode),
                        const SizedBox(height: 20),
                      ],
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
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
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
                  'サークル作成',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText(isDarkMode),
                  ),
                ),
                Text(
                  '新しいサークルを作成します',
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

  Widget _buildPreviewCard(
    IconType iconType,
    ColorTheme colorTheme,
    String name,
    String description,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(colorTheme.colorValue).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText(isDarkMode),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryText(isDarkMode),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryText(isDarkMode),
      ),
    );
  }

  Widget _buildNameField(TextEditingController controller, bool isDarkMode) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'サークル名 *',
        hintText: '例: バスケットボール同好会',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppTheme.cardBackground(isDarkMode),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'サークル名を入力してください';
        }
        if (value.trim().length < 2) {
          return 'サークル名は2文字以上で入力してください';
        }
        return null;
      },
      maxLength: 30,
    );
  }

  Widget _buildDescriptionField(TextEditingController controller, bool isDarkMode) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '説明文',
        hintText: '例: 毎週楽しくバスケをしています',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppTheme.cardBackground(isDarkMode),
      ),
      maxLines: 3,
      maxLength: 200,
    );
  }

  Widget _buildCategorySelector(ValueNotifier<CircleCategory> selectedCategory, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'カテゴリ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CircleCategory.values.map((category) {
            final isSelected = selectedCategory.value == category;
            return GestureDetector(
              onTap: () => selectedCategory.value = category,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentColor.withValues(alpha: 0.15)
                      : AppTheme.cardBackground(isDarkMode),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentColor
                        : AppTheme.tertiaryText(isDarkMode).withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.accentColor
                            : AppTheme.primaryText(isDarkMode),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconSelector(ValueNotifier<IconType> selectedIcon, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'アイコン',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: IconType.values.map((iconType) {
            final isSelected = selectedIcon.value == iconType;
            return GestureDetector(
              onTap: () => selectedIcon.value = iconType,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentColor.withValues(alpha: 0.15)
                      : AppTheme.cardBackground(isDarkMode),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentColor
                        : AppTheme.tertiaryText(isDarkMode).withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    iconType.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector(ValueNotifier<ColorTheme> selectedColor, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'カラーテーマ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ColorTheme.values.map((colorTheme) {
            final isSelected = selectedColor.value == colorTheme;
            return GestureDetector(
              onTap: () => selectedColor.value = colorTheme,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(colorTheme.colorValue),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Color(colorTheme.colorValue).withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActivityNameField(ValueNotifier<String> activityName, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '活動名',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: activityName.value,
          decoration: InputDecoration(
            hintText: '例: 練習、集まり、勉強会',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppTheme.cardBackground(isDarkMode),
          ),
          onChanged: (value) => activityName.value = value.isNotEmpty ? value : '活動',
          maxLength: 10,
        ),
      ],
    );
  }

  Widget _buildPrivacySettings(
    ValueNotifier<bool> isPublic,
    ValueNotifier<bool> requiresApproval,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground(isDarkMode),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.tertiaryText(isDarkMode).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isPublic.value ? Icons.public : Icons.lock,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '公開設定',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryText(isDarkMode),
                          ),
                        ),
                        Text(
                          isPublic.value
                              ? '誰でも検索・参加できます'
                              : '招待コードでのみ参加可能',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryText(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isPublic.value,
                    onChanged: (value) => isPublic.value = value,
                    activeThumbColor: AppTheme.accentColor,
                  ),
                ],
              ),
              if (isPublic.value) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      requiresApproval.value ? Icons.how_to_reg : Icons.person_add,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '参加承認',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryText(isDarkMode),
                            ),
                          ),
                          Text(
                            requiresApproval.value
                                ? '管理者の承認が必要'
                                : '自動で参加可能',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.secondaryText(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: requiresApproval.value,
                      onChanged: (value) => requiresApproval.value = value,
                      activeThumbColor: AppTheme.accentColor,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(VoidCallback onPressed, bool isLoading, bool isDarkMode) {
    return SizedBox(
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
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'サークルを作成',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}