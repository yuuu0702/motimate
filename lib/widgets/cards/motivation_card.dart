import 'package:flutter/material.dart';

import '../../viewmodels/home_viewmodel.dart';
import '../../themes/app_theme.dart';

/// モチベーション管理カードWidget
/// 
/// ユーザーの現在のモチベーションレベルを表示し、
/// スライダーで変更できる機能を提供する
class MotivationCard extends StatelessWidget {
  const MotivationCard({
    super.key,
    required this.state,
    required this.motivationLevels,
    required this.onMotivationUpdate,
    required this.isDarkMode,
  });

  final HomeState state;
  final List<Map<String, dynamic>> motivationLevels;
  final Future<void> Function(double) onMotivationUpdate;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildCurrentMotivationDisplay(),
          const SizedBox(height: 16),
          _buildMotivationSlider(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.mood,
            color: Color(0xFF667eea),
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'バスケのモチベ',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentMotivationDisplay() {
    final index = (state.currentMotivation.round() - 1).clamp(0, motivationLevels.length - 1);
    final currentLevel = motivationLevels[index];
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(currentLevel['color'][0] as int),
            Color(currentLevel['color'][1] as int),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            currentLevel['emoji'],
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentLevel['label'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'レベル ${state.currentMotivation.round()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (state.isLoadingMotivation)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMotivationSlider(BuildContext context) {
    return Column(
      children: [
        _buildEmojiIndicators(),
        const SizedBox(height: 8),
        _buildSlider(context),
      ],
    );
  }

  Widget _buildEmojiIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: motivationLevels.map((level) {
        final isSelected = level['level'] == state.currentMotivation.round();
        return Text(
          level['emoji'],
          style: TextStyle(
            fontSize: isSelected ? 20 : 16,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final index = (state.currentMotivation.round() - 1).clamp(0, motivationLevels.length - 1);
    final currentLevel = motivationLevels[index];
    
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Color(currentLevel['color'][0] as int),
        inactiveTrackColor: isDarkMode 
            ? const Color(0xFF4B5563) 
            : const Color(0xFFE2E8F0),
        thumbColor: Color(currentLevel['color'][1] as int),
        overlayColor: Color(currentLevel['color'][0] as int).withValues(alpha: 0.2),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 10,
        ),
        trackHeight: 4,
      ),
      child: Slider(
        value: state.currentMotivation,
        min: 1,
        max: 5,
        divisions: 4,
        onChanged: state.isLoadingMotivation ? null : (value) {
          // Temporary visual update handled by ViewModel
        },
        onChangeEnd: (value) {
          if (!state.isLoadingMotivation) {
            onMotivationUpdate(value);
          }
        },
      ),
    );
  }
}