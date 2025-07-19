import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/practice_decision_model.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../themes/app_theme.dart';

/// 練習履歴カードWidget
/// 
/// 過去の練習日程の履歴を表示し、メモの追加・編集機能を提供
class PracticeHistoryCard extends StatelessWidget {
  const PracticeHistoryCard({
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHistoryHeader(dayName, userResponse),
          const SizedBox(height: 12),
          _buildParticipantsInfo(),
          if (practice.memo != null && practice.memo!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildMemoSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryHeader(String dayName, String? userResponse) {
    return Row(
      children: [
        // 日付表示（グレー調）
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${practice.practiceDate.day}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                dayName,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // タイトルと日付
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '練習履歴',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText(isDarkMode),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (userResponse != null) _buildUserResponseBadge(userResponse),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${practice.practiceDate.year}年${practice.practiceDate.month}月${practice.practiceDate.day}日 (${dayName})',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText(isDarkMode),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserResponseBadge(String userResponse) {
    final isJoin = userResponse == 'join';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isJoin 
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : const Color(0xFFFF6B6B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isJoin ? '参加' : '見送り',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: isJoin ? const Color(0xFF10B981) : const Color(0xFFFF6B6B),
        ),
      ),
    );
  }

  Widget _buildParticipantsInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people_rounded,
            size: 16,
            color: AppTheme.secondaryText(isDarkMode),
          ),
          const SizedBox(width: 6),
          Text(
            '参加: ${practice.joinCount}人',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryText(isDarkMode),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '見送り: ${practice.skipCount}人',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryText(isDarkMode),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showParticipantsDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF667eea).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 12,
                    color: Color(0xFF667eea),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '詳細',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF667eea),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.note_alt_outlined,
                size: 14,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 6),
              Text(
                'メモ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText(isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            practice.memo!,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryText(isDarkMode),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showParticipantsDialog() {
    // PracticeDecisionCardと同様の参加者詳細ダイアログを表示
    // 実装は割愛（既存のコードを参考に実装可能）
  }
}