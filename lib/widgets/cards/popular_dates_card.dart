import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/schedule_model.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../routing/app_router.dart';
import '../../themes/app_theme.dart';

/// 人気の日程表示カードWidget
/// 
/// 参加可能人数の多い日程を表示し、
/// 日程決定のアクションを提供する
class PopularDatesCard extends StatelessWidget {
  const PopularDatesCard({
    super.key,
    required this.state,
    required this.onDecisionDialog,
  });

  final HomeState state;
  final Future<void> Function(ScheduleModel) onDecisionDialog;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildContent(context),
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
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.trending_up,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '人気の日程',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (state.isLoadingSchedule) {
      return _buildLoadingState();
    } else if (state.popularDates.isNotEmpty) {
      return _buildPopularDatesState(context);
    } else {
      return _buildEmptyState(context);
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPopularDatesState(BuildContext context) {
    return Column(
      children: [
        ...state.popularDates
            .take(2)
            .map((schedule) => PopularDateItem(
                  schedule: schedule,
                  onDecisionDialog: onDecisionDialog,
                )),
        const SizedBox(height: 12),
        _buildAddScheduleButton(
          context: context,
          label: '新しい日程を追加',
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          const Text(
            'まだ日程候補がありません',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildAddScheduleButton(
            context: context,
            label: '日程を決める',
          ),
        ],
      ),
    );
  }

  Widget _buildAddScheduleButton({
    required BuildContext context,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.go(AppRoutes.schedule),
        icon: const Icon(Icons.add_rounded, size: 16),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF667eea),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/// 人気の日程の個別アイテムWidget
class PopularDateItem extends StatelessWidget {
  const PopularDateItem({
    super.key,
    required this.schedule,
    required this.onDecisionDialog,
  });

  final ScheduleModel schedule;
  final Future<void> Function(ScheduleModel) onDecisionDialog;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildDateInfo(),
          const SizedBox(width: 10),
          _buildScheduleDetails(),
          _buildDecisionButton(),
        ],
      ),
    );
  }

  Widget _buildDateInfo() {
    return Column(
      children: [
        Text(
          '${schedule.date.day}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          '(${schedule.dayName})',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${schedule.date.month}月${schedule.date.day}日',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              Text(
                '参加可能: ${schedule.memberCount}人',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => _showParticipantsDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 10,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '詳細',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white.withValues(alpha: 0.9),
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
    );
  }

  Widget _buildDecisionButton() {
    return ElevatedButton(
      onPressed: () => onDecisionDialog(schedule),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF667eea),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        minimumSize: const Size(0, 0),
      ),
      child: const Text(
        '決定',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showParticipantsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, String>>(
          future: _getUserNames(schedule.members),
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
                  const Text(
                    '参加可能ユーザー',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                            '${schedule.date.month}月${schedule.date.day}日',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 参加可能ユーザーリスト
                    _buildParticipantSectionWithNames(
                      '参加可能 (${schedule.members.length}人)',
                      schedule.members,
                      userNames,
                      const Color(0xFF10B981),
                      Icons.check_circle,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    '閉じる',
                    style: TextStyle(
                      color: Color(0xFF667eea),
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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