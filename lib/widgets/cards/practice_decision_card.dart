import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/practice_decision_model.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../themes/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// 日程決定カードWidget
/// 
/// 練習日程が決定された際にユーザーに参加/見送りの回答を求めるカード
class PracticeDecisionCard extends StatelessWidget {
  const PracticeDecisionCard({
    super.key,
    required this.practice,
    required this.homeViewModel,
    required this.isDarkMode,
  });

  final PracticeDecisionModel practice;
  final HomeViewModel homeViewModel;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = ['日', '月', '火', '水', '木', '金', '土'];
    final dayName = daysOfWeek[practice.practiceDate.weekday % 7];
    final user = FirebaseAuth.instance.currentUser;
    final userResponse = user != null ? practice.responses[user.uid] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        boxShadow: [
          BoxShadow(
            color: userResponse == null
                ? const Color(0xFFFB923C).withValues(alpha: 0.15)
                : (userResponse == 'join' 
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : const Color(0xFFFF6B6B).withValues(alpha: 0.1)),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          border: userResponse == null
              ? Border.all(
                  color: const Color(0xFFFB923C).withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          children: [
            _buildHeader(userResponse),
            _buildContent(context, dayName, userResponse),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String? userResponse) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: userResponse == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFB923C), Color(0xFFFF8C42)],
              )
            : userResponse == 'join'
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                  ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              userResponse == null
                  ? Icons.notification_important_rounded
                  : userResponse == 'join'
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userResponse == null
                      ? '🏀 日程が決定されました！'
                      : userResponse == 'join'
                          ? '✅ 参加で回答済み'
                          : '❌ 見送りで回答済み',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userResponse == null
                      ? '参加状況を教えてください'
                      : '回答ありがとうございます！',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, String dayName, String? userResponse) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPracticeDateInfo(dayName),
          const SizedBox(height: 16),
          _buildResponseSection(userResponse),
        ],
      ),
    );
  }

  Widget _buildPracticeDateInfo(String dayName) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${practice.practiceDate.day}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${practice.practiceDate.month}月${practice.practiceDate.day}日',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_rounded,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '参加: ${practice.joinCount}人 / 見送り: ${practice.skipCount}人',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseSection(String? userResponse) {
    if (userResponse == null) {
      return _buildUnrespondedSection();
    } else {
      return _buildRespondedSection(userResponse);
    }
  }

  Widget _buildUnrespondedSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.containerBackground(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFB923C).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: const Color(0xFFFB923C),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '参加状況を選択してください',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText(isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => homeViewModel.respondToPractice(practice.id, 'join'),
                  icon: const Icon(Icons.sports_basketball_rounded, size: 16),
                  label: const Text(
                    '参加',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => homeViewModel.respondToPractice(practice.id, 'skip'),
                  icon: const Icon(Icons.event_busy_rounded, size: 16),
                  label: const Text(
                    '見送り',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRespondedSection(String userResponse) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: userResponse == 'join'
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : const Color(0xFFFF6B6B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: userResponse == 'join'
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : const Color(0xFFFF6B6B).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: userResponse == 'join'
                      ? const Color(0xFF10B981)
                      : const Color(0xFFFF6B6B),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  userResponse == 'join' 
                      ? Icons.check_rounded 
                      : Icons.close_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userResponse == 'join' ? '参加で回答済み' : '見送りで回答済み',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: userResponse == 'join'
                            ? const Color(0xFF10B981)
                            : const Color(0xFFFF6B6B),
                      ),
                    ),
                    Text(
                      'ご回答ありがとうございます！',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.secondaryText(isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => homeViewModel.respondToPractice(
                practice.id,
                userResponse == 'join' ? 'skip' : 'join',
              ),
              icon: Icon(
                Icons.sync_rounded,
                size: 14,
                color: AppTheme.secondaryText(isDarkMode),
              ),
              label: Text(
                userResponse == 'join' ? '見送りに変更' : '参加に変更',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryText(isDarkMode),
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}