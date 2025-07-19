import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    
    // 当日かどうかの判定
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final practiceDay = DateTime(practice.practiceDate.year, practice.practiceDate.month, practice.practiceDate.day);
    final isToday = today == practiceDay;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isToday ? 20 : 16),
      decoration: BoxDecoration(
        color: isToday 
            ? const Color(0xFF667eea).withValues(alpha: 0.05)
            : AppTheme.cardColor(isDarkMode),
        borderRadius: BorderRadius.circular(isToday ? 16 : 12),
        border: Border.all(
          color: isToday 
              ? const Color(0xFF667eea).withValues(alpha: 0.6)
              : userResponse == null
                  ? const Color(0xFFFB923C).withValues(alpha: 0.3)
                  : userResponse == 'join'
                      ? const Color(0xFF10B981).withValues(alpha: 0.3)
                      : const Color(0xFFFF6B6B).withValues(alpha: 0.3),
          width: isToday ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isToday 
                ? const Color(0xFF667eea).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isToday ? 12 : 8,
            offset: const Offset(0, isToday ? 4 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isToday) _buildTodayBadge(),
          if (isToday) const SizedBox(height: 12),
          _buildSimpleHeader(dayName, userResponse, isToday),
          const SizedBox(height: 12),
          _buildActionButtons(userResponse),
        ],
      ),
    );
  }

  Widget _buildTodayBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.today,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          const Text(
            '今日の練習',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader(String dayName, String? userResponse, bool isToday) {
    return Row(
      children: [
        // 日付表示
        Container(
          width: isToday ? 70 : 60,
          height: isToday ? 70 : 60,
          decoration: BoxDecoration(
            color: isToday 
                ? const Color(0xFF667eea)
                : const Color(0xFF667eea),
            borderRadius: BorderRadius.circular(isToday ? 16 : 12),
            boxShadow: isToday ? [
              BoxShadow(
                color: const Color(0xFF667eea).withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${practice.practiceDate.day}',
                style: TextStyle(
                  fontSize: isToday ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                dayName,
                style: TextStyle(
                  fontSize: isToday ? 14 : 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // タイトルと状態
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isToday ? '今日の練習決定' : '日程決定',
                    style: TextStyle(
                      fontSize: isToday ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: isToday 
                          ? const Color(0xFF667eea)
                          : AppTheme.primaryText(isDarkMode),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(userResponse),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${practice.practiceDate.month}月${practice.practiceDate.day}日 (${dayName})',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.people_rounded,
                    size: 14,
                    color: AppTheme.secondaryText(isDarkMode),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '参加: ${practice.joinCount}人 / 見送り: ${practice.skipCount}人',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText(isDarkMode),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => _showParticipantsDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF667eea).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 12,
                              color: const Color(0xFF667eea),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '詳細',
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFF667eea),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusBadge(String? userResponse) {
    if (userResponse == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFB923C).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFB923C).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Text(
          '未回答',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFB923C),
          ),
        ),
      );
    } else {
      final isJoin = userResponse == 'join';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isJoin 
              ? const Color(0xFF10B981).withValues(alpha: 0.1)
              : const Color(0xFFFF6B6B).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isJoin ? '参加' : '見送り',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isJoin ? const Color(0xFF10B981) : const Color(0xFFFF6B6B),
          ),
        ),
      );
    }
  }

  Widget _buildActionButtons(String? userResponse) {
    if (userResponse == null) {
      return _buildUnrespondedButtons();
    } else {
      return _buildRespondedButtons(userResponse);
    }
  }

  Widget _buildUnrespondedButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => homeViewModel.respondToPractice(practice.id, 'join'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              '参加する',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => homeViewModel.respondToPractice(practice.id, 'skip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              '見送る',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRespondedButtons(String userResponse) {
    return Row(
      children: [
        Icon(
          userResponse == 'join' ? Icons.check_circle : Icons.cancel,
          color: userResponse == 'join' 
              ? const Color(0xFF10B981) 
              : const Color(0xFFFF6B6B),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            userResponse == 'join' ? '参加で回答済み' : '見送りで回答済み',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText(isDarkMode),
            ),
          ),
        ),
        TextButton(
          onPressed: () => homeViewModel.respondToPractice(
            practice.id,
            userResponse == 'join' ? 'skip' : 'join',
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text(
            '変更',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryText(isDarkMode),
            ),
          ),
        ),
      ],
    );
  }

  void _showParticipantsDialog(BuildContext context) {
    final joinedUsers = <String>[];
    final skippedUsers = <String>[];
    final noResponseUsers = <String>[];

    // 回答状況を分類
    for (final member in practice.availableMembers) {
      final response = practice.responses[member];
      if (response == 'join') {
        joinedUsers.add(member);
      } else if (response == 'skip') {
        skippedUsers.add(member);
      } else {
        noResponseUsers.add(member);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, String>>(
          future: _getUserNames([...joinedUsers, ...skippedUsers, ...noResponseUsers]),
          builder: (context, snapshot) {
            final userNames = snapshot.data ?? {};
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('ユーザー情報を読み込み中...'),
                  ],
                ),
              );
            }
            
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.people_rounded,
                    color: const Color(0xFF667eea),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '参加状況詳細',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText(isDarkMode),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 日程情報
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: const Color(0xFF667eea),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${practice.practiceDate.month}月${practice.practiceDate.day}日',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryText(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 参加者リスト
                    if (joinedUsers.isNotEmpty) ...[
                      _buildParticipantSectionWithNames(
                        '参加 (${joinedUsers.length}人)',
                        joinedUsers,
                        userNames,
                        const Color(0xFF10B981),
                        Icons.check_circle,
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // 見送り者リスト
                    if (skippedUsers.isNotEmpty) ...[
                      _buildParticipantSectionWithNames(
                        '見送り (${skippedUsers.length}人)',
                        skippedUsers,
                        userNames,
                        const Color(0xFFFF6B6B),
                        Icons.cancel,
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // 未回答者リスト
                    if (noResponseUsers.isNotEmpty) ...[
                      _buildParticipantSectionWithNames(
                        '未回答 (${noResponseUsers.length}人)',
                        noResponseUsers,
                        userNames,
                        const Color(0xFFFB923C),
                        Icons.help_outline,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '閉じる',
                    style: TextStyle(
                      color: const Color(0xFF667eea),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>> _getUserNames(List<String> userIds) async {
    final Map<String, String> userNames = {};
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds.isEmpty ? ['dummy'] : userIds)
          .get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        userNames[doc.id] = data['displayName'] ?? 
                           data['username'] ?? 
                           data['name'] ?? 
                           'ユーザー${doc.id.substring(0, 4)}';
      }
      
      // 見つからなかったユーザーのフォールバック
      for (final userId in userIds) {
        if (!userNames.containsKey(userId)) {
          if (userId.startsWith('user')) {
            userNames[userId] = 'ユーザー${userId.substring(4)}';
          } else {
            userNames[userId] = 'ユーザー${userId.substring(0, 4)}';
          }
        }
      }
    } catch (e) {
      // エラー時のフォールバック
      for (final userId in userIds) {
        if (userId.startsWith('user')) {
          userNames[userId] = 'ユーザー${userId.substring(4)}';
        } else {
          userNames[userId] = 'ユーザー${userId.substring(0, 4)}';
        }
      }
    }
    
    return userNames;
  }

  Widget _buildParticipantSectionWithNames(
    String title,
    List<String> userIds,
    Map<String, String> userNames,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: userIds.map((userId) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  userNames[userId] ?? 'ユーザー${userId.substring(0, 4)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryText(isDarkMode),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantSection(
    String title,
    List<String> userIds,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: userIds.map((userId) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getUserDisplayName(userId),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryText(isDarkMode),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getUserDisplayName(String userId) {
    // 実際の実装では、Firestoreからユーザー名を取得する
    // 今は簡易的にuserIdを表示
    if (userId.startsWith('user')) {
      return 'ユーザー${userId.substring(4)}';
    }
    return userId.substring(0, 8); // UIDの最初の8文字を表示
  }
}