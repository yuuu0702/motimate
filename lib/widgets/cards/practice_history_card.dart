import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/practice_decision_model.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../themes/app_theme.dart';

/// バスケ履歴カードWidget
/// 
/// 過去のバスケ日程の履歴を表示し、メモの追加・編集機能を提供
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
          const SizedBox(height: 8),
          _buildMemoSection(),
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
                    'バスケ履歴',
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
                '${practice.practiceDate.year}年${practice.practiceDate.month}月${practice.practiceDate.day}日 ($dayName)',
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
          Builder(
            builder: (context) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showParticipantsDialog(context),
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
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showParticipantsEditDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          size: 12,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '編集',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoSection() {
    final hasMemo = practice.memo != null && practice.memo!.isNotEmpty;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasMemo 
            ? const Color(0xFFFEF3C7).withValues(alpha: 0.5)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasMemo 
              ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasMemo ? Icons.note_alt_outlined : Icons.note_add_outlined,
                size: 14,
                color: hasMemo 
                    ? const Color(0xFFF59E0B)
                    : AppTheme.secondaryText(isDarkMode),
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
              const Spacer(),
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => _showMemoEditDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hasMemo ? '編集' : '追加',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF667eea),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (hasMemo) ...[
            const SizedBox(height: 6),
            Text(
              practice.memo!,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryText(isDarkMode),
                height: 1.4,
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            Text(
              'このバスケについてメモを追加できます',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.tertiaryText(isDarkMode),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showMemoEditDialog(BuildContext context) {
    final TextEditingController memoController = TextEditingController(
      text: practice.memo ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.edit_note,
                color: Color(0xFF667eea),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'メモの編集',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText(isDarkMode),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Color(0xFF667eea),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${practice.practiceDate.year}年${practice.practiceDate.month}月${practice.practiceDate.day}日のバスケ',
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
              TextField(
                controller: memoController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'このバスケについてのメモを入力してください...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF667eea),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'キャンセル',
                style: TextStyle(
                  color: AppTheme.tertiaryText(isDarkMode),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final memo = memoController.text.trim();
                await homeViewModel.updatePracticeMemo(practice.id, memo);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  // スナックバーで完了通知
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(memo.isEmpty ? 'メモを削除しました' : 'メモを保存しました'),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '保存',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showParticipantsEditDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<List<String>> selectedParticipants = ValueNotifier(
      List<String>.from(practice.actualParticipants),
    );
    final ValueNotifier<String> searchQuery = ValueNotifier('');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.people,
                color: Color(0xFF10B981),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '参加者編集',
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
            height: 400,
            child: Column(
              children: [
                // 日程情報
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${practice.practiceDate.year}年${practice.practiceDate.month}月${practice.practiceDate.day}日のバスケ',
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
                
                // 参加者検索
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'ユーザーIDを入力（例：user1）',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final userId = searchController.text.trim();
                        if (userId.isNotEmpty && !selectedParticipants.value.contains(userId)) {
                          selectedParticipants.value = [...selectedParticipants.value, userId];
                          searchController.clear();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 選択された参加者リスト
                Expanded(
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: selectedParticipants,
                    builder: (context, participants, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '参加者 (${participants.length}人)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText(isDarkMode),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: participants.isEmpty
                                ? Center(
                                    child: Text(
                                      '参加者がいません',
                                      style: TextStyle(
                                        color: AppTheme.tertiaryText(isDarkMode),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: participants.length,
                                    itemBuilder: (context, index) {
                                      final userId = participants[index];
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.person,
                                              size: 16,
                                              color: Color(0xFF10B981),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                userId.startsWith('user') 
                                                    ? 'ユーザー${userId.substring(4)}'
                                                    : userId,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.primaryText(isDarkMode),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                selectedParticipants.value = participants
                                                    .where((p) => p != userId)
                                                    .toList();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'キャンセル',
                style: TextStyle(
                  color: AppTheme.tertiaryText(isDarkMode),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await homeViewModel.updateActualParticipants(
                  practice.id,
                  selectedParticipants.value,
                );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('参加者を更新しました'),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '保存',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
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
      builder: (BuildContext dialogContext) {
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
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '参加状況詳細（履歴）',
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
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${practice.practiceDate.year}年${practice.practiceDate.month}月${practice.practiceDate.day}日',
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
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    '閉じる',
                    style: TextStyle(
                      color: Colors.grey[600],
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
}