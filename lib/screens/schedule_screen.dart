import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../themes/app_theme.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  Set<DateTime> selectedDates = {};
  Set<DateTime> myRegisteredDates = {};
  DateTime currentDate = DateTime.now();
  Map<String, Map<String, dynamic>> scheduleData = {};
  bool isLoading = true;

  final List<String> daysOfWeek = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final snapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .get();

      Map<String, Map<String, dynamic>> data = {};
      Set<DateTime> myDates = {};

      for (var doc in snapshot.docs) {
        final docData = doc.data();
        final members = docData['members'] as List? ?? [];

        // 参加者が1人以上いる場合のみデータに追加
        if (members.isNotEmpty) {
          data[doc.id] = {'available': members.length, 'members': members};

          // Check if current user is in the members list
          if (user != null && members.contains(user.uid)) {
            final date = DateTime.parse(doc.id);
            myDates.add(date);
          }
        }
      }

      setState(() {
        scheduleData = data;
        myRegisteredDates = myDates;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<DateTime?> getDaysInMonth() {
    final year = currentDate.year;
    final month = currentDate.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingDayOfWeek = firstDay.weekday % 7;

    List<DateTime?> days = [];

    // 月初より前の空白セル
    for (int i = 0; i < startingDayOfWeek; i++) {
      days.add(null);
    }

    // 月の日付
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(year, month, day));
    }

    return days;
  }

  void toggleDate(DateTime date) {
    setState(() {
      // If already registered, remove from registration
      if (myRegisteredDates.contains(date)) {
        _removeFromSchedule(date);
      }
      // If currently selected for addition, unselect
      else if (selectedDates.contains(date)) {
        selectedDates.remove(date);
      }
      // Otherwise, select for addition
      else {
        selectedDates.add(date);
      }
    });
  }

  Future<void> _removeFromSchedule(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final dateKey = getDateKey(date);
      final docRef = FirebaseFirestore.instance
          .collection('schedules')
          .doc(dateKey);

      // 現在のドキュメントを取得
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final members = List<String>.from(data['members'] ?? []);
        
        // ユーザーをリストから削除
        members.remove(user.uid);
        
        if (members.isEmpty) {
          // 参加者が0人になった場合はドキュメントを削除
          await docRef.delete();
        } else {
          // 参加者がまだいる場合は更新
          await docRef.update({
            'members': members,
          });
        }
      }

      setState(() {
        myRegisteredDates.remove(date);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${date.month}/${date.day}の予定を削除しました'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      _loadScheduleData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('削除に失敗しました: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic>? getDateInfo(DateTime date) {
    return scheduleData[getDateKey(date)];
  }

  Future<void> _updateAvailability() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (DateTime date in selectedDates) {
        final dateKey = getDateKey(date);
        final docRef = FirebaseFirestore.instance
            .collection('schedules')
            .doc(dateKey);

        batch.set(docRef, {
          'members': FieldValue.arrayUnion([user.uid]),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('空き状況を更新しました (${selectedDates.length}日選択中)')),
        );
      }

      setState(() {
        selectedDates.clear();
      });

      _loadScheduleData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新に失敗しました: $e')));
      }
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1, 1);
    });
    _loadScheduleData();
  }

  void _goToNextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    });
    _loadScheduleData();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBackground(isDarkMode),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final days = getDaysInMonth();
    final currentMonthText = '${currentDate.year}年${currentDate.month}月';

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // スケジュール タイトル
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Text(
                          'スケジュール',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText(isDarkMode),
                          ),
                        ),
                      ],
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
                      // Calendar Card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        currentMonthText,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryText(isDarkMode),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                                        onPressed: currentDate.month == DateTime.now().month && currentDate.year == DateTime.now().year
                                            ? null
                                            : _goToPreviousMonth,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_forward_ios, size: 20),
                                        onPressed: currentDate.month == DateTime.now().month && currentDate.year == DateTime.now().year
                                            ? _goToNextMonth
                                            : null,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '日付をタップして選択/解除できます',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.tertiaryText(isDarkMode),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Legend
                                  _buildLegendItem(
                                    Colors.green,
                                    '登録済み',
                                    Icons.check_circle,
                                    isDarkMode,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildLegendItem(
                                    const Color(0xFF667eea),
                                    '選択中',
                                    null,
                                    isDarkMode,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildLegendItem(Colors.orange, '他の人', null, isDarkMode),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Days of week header
                              Row(
                                children: daysOfWeek
                                    .map(
                                      (day) => Expanded(
                                        child: Center(
                                          child: Text(
                                            day,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.tertiaryText(isDarkMode),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 8),

                              // Calendar grid
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 4,
                                    ),
                                itemCount: days.length,
                                itemBuilder: (context, index) {
                                  final day = days[index];
                                  if (day == null) {
                                    return const SizedBox();
                                  }

                                  final isSelected = selectedDates.contains(
                                    day,
                                  );
                                  final isMyRegistered = myRegisteredDates
                                      .contains(day);
                                  final dateInfo = getDateInfo(day);

                                  // Determine the visual state
                                  Color? backgroundColor;
                                  Gradient? gradient;
                                  Color textColor = AppTheme.primaryText(isDarkMode);
                                  Widget? statusIcon;

                                  if (isMyRegistered) {
                                    // Already registered by me - green with checkmark
                                    backgroundColor = const Color(0xFF10B981);
                                    textColor = Colors.white;
                                    statusIcon = const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 16,
                                    );
                                  } else if (isSelected) {
                                    // Currently selected for new registration - blue gradient
                                    gradient = const LinearGradient(
                                      colors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2),
                                      ],
                                    );
                                    textColor = Colors.white;
                                  } else {
                                    // Default state
                                    backgroundColor = Colors.transparent;
                                  }

                                  return GestureDetector(
                                    onTap: () => toggleDate(day),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: gradient,
                                        color: backgroundColor,
                                        border: isMyRegistered
                                            ? null
                                            : Border.all(
                                                color: isSelected
                                                    ? Colors.transparent
                                                    : const Color(0xFFE2E8F0),
                                                width: 1,
                                              ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Text(
                                              '${day.day}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                          ),

                                          // My registration checkmark
                                          if (isMyRegistered)
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: statusIcon!,
                                            ),

                                          // Others' availability count
                                          if (dateInfo != null &&
                                              !isMyRegistered &&
                                              dateInfo['available'] > 0)
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: Container(
                                                width: 16,
                                                height: 16,
                                                decoration: const BoxDecoration(
                                                  color: Colors.orange,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${dateInfo['available']}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Popular Dates Card
                      if (scheduleData.isNotEmpty && 
                          scheduleData.values.any((data) => data['available'] > 0))
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.people, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                      '人気の日程',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryText(isDarkMode),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...(scheduleData.entries
                                    .where((entry) => entry.value['available'] > 0)
                                    .toList()..sort(
                                      (a, b) => b.value['available'].compareTo(
                                        a.value['available'],
                                      ),
                                    ))
                                    .take(3)
                                    .map((entry) {
                                      final date = DateTime.parse(entry.key);
                                      final info = entry.value;
                                      final dayName =
                                          daysOfWeek[date.weekday % 7];

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.containerBackground(isDarkMode),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  '${date.day}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryText(isDarkMode),
                                                  ),
                                                ),
                                                Text(
                                                  '($dayName)',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme.tertiaryText(isDarkMode),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withValues(
                                                        alpha: 0.1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      '${info['available']}人参加可能',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () => _showParticipantsDialog(
                                                      context, 
                                                      date, 
                                                      info['members'] as List<dynamic>,
                                                      isDarkMode
                                                    ),
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
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Submit Button
                      if (selectedDates.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _updateAvailability,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              '空き状況を更新する (${selectedDates.length}日選択中)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _buildLegendItem(Color color, String label, IconData? icon, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: icon != null ? Icon(icon, color: Colors.white, size: 8) : null,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.tertiaryText(isDarkMode)),
        ),
      ],
    );
  }

  void _showParticipantsDialog(BuildContext context, DateTime date, List<dynamic> members, bool isDarkMode) {
    final memberIds = members.cast<String>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, String>>(
          future: _getUserNames(memberIds),
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
                    '参加可能ユーザー',
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
                            '${date.month}月${date.day}日',
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
                    
                    // 参加可能ユーザーリスト
                    _buildParticipantSectionWithNames(
                      '参加可能 (${memberIds.length}人)',
                      memberIds,
                      userNames,
                      const Color(0xFF10B981),
                      Icons.check_circle,
                      isDarkMode,
                    ),
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
    bool isDarkMode,
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
