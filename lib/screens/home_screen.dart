import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motimate/services/notification_service.dart';
import 'package:motimate/screens/notifications_screen.dart';
import 'package:motimate/screens/feedback_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DateTime?> _nextPlayDates = [null, null];
  double _currentMotivation = 3.0;
  bool _isUpdatingMotivation = false;
  List<Map<String, dynamic>> _popularDates = [];
  bool _isLoadingSchedule = true;
  List<Map<String, dynamic>> _pendingPractices = [];
  bool _isLoadingPractices = true;

  final List<Map<String, dynamic>> motivationLevels = [
    {
      'level': 1,
      'emoji': '😴',
      'label': 'お疲れ気味...',
      'color': [0xFF9CA3AF, 0xFF6B7280],
    },
    {
      'level': 2,
      'emoji': '😐',
      'label': 'あまり気分が...',
      'color': [0xFF60A5FA, 0xFF3B82F6],
    },
    {
      'level': 3,
      'emoji': '🙂',
      'label': '普通かな',
      'color': [0xFFFBBF24, 0xFFF59E0B],
    },
    {
      'level': 4,
      'emoji': '😊',
      'label': 'やる気あり！',
      'color': [0xFFFB923C, 0xFFEA580C],
    },
    {
      'level': 5,
      'emoji': '🔥',
      'label': '超やる気！！',
      'color': [0xFFF87171, 0xFFEF4444],
    },
  ];

  final List<String> daysOfWeek = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  void initState() {
    super.initState();
    _loadNextPlayDate();
    _loadCurrentMotivation();
    _loadPopularDates();
    _loadPendingPractices();
  }

  Future<void> _loadNextPlayDate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null && data.containsKey('nextPlayDates')) {
        final List<dynamic> dates = data['nextPlayDates'];
        setState(() {
          _nextPlayDates = dates
              .map((timestamp) => (timestamp as Timestamp).toDate())
              .toList();
          // Ensure there are always two elements
          while (_nextPlayDates.length < 2) {
            _nextPlayDates.add(null);
          }
        });
      }
    }
  }

  Future<void> _loadCurrentMotivation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null && data.containsKey('latestMotivationLevel')) {
        setState(() {
          _currentMotivation = (data['latestMotivationLevel'] as num)
              .toDouble();
        });
      }
    }
  }

  Future<void> _updateMotivation(double newLevel) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isUpdatingMotivation = true;
    });

    try {
      // Update user's motivation info only
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'latestMotivationLevel': newLevel.round(),
        'latestMotivationTimestamp': Timestamp.now(),
      }, SetOptions(merge: true));

      setState(() {
        _currentMotivation = newLevel;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('やる気レベル ${newLevel.round()} に更新しました！'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新に失敗しました: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdatingMotivation = false;
      });
    }
  }

  Future<void> _loadPopularDates() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .get();

      List<Map<String, dynamic>> dates = [];
      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final docData = doc.data();
        final members = docData['members'] as List? ?? [];

        // Only include future dates with at least 1 member
        try {
          final date = DateTime.parse(doc.id);
          if (date.isAfter(now) && members.isNotEmpty) {
            final dayName = daysOfWeek[date.weekday % 7];
            dates.add({
              'date': date,
              'dateKey': doc.id,
              'dayName': dayName,
              'memberCount': members.length,
              'members': members,
            });
          }
        } catch (e) {
          // Skip invalid date formats
          continue;
        }
      }

      // Sort by member count (descending) and then by date (ascending)
      dates.sort((a, b) {
        int memberComparison = b['memberCount'].compareTo(a['memberCount']);
        if (memberComparison != 0) return memberComparison;
        return a['date'].compareTo(b['date']);
      });

      setState(() {
        _popularDates = dates.take(3).toList();
        _isLoadingSchedule = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSchedule = false;
      });
    }
  }

  Future<void> _decidePracticeDate(Map<String, dynamic> dateInfo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final date = dateInfo['date'] as DateTime;

      // Create practice decision document
      await FirebaseFirestore.instance.collection('practice_decisions').add({
        'decidedBy': user.uid,
        'decidedAt': Timestamp.now(),
        'practiceDate': Timestamp.fromDate(date),
        'dateKey': dateInfo['dateKey'],
        'availableMembers': dateInfo['members'],
        'status': 'pending', // pending, confirmed, cancelled
        'responses': {}, // Will store member responses
      });

      // Get current user's display name for notifications
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final deciderName = userData?['displayName'] ?? userData?['username'] ?? '誰か';

      // Create notifications for all available members (except the decider)
      final availableMembers = List<String>.from(dateInfo['members']);
      for (final memberId in availableMembers) {
        if (memberId != user.uid) {
          await NotificationService.createPracticeDecisionNotification(
            userId: memberId,
            practiceDate: date,
            deciderName: deciderName,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${date.month}/${date.day}(${dateInfo['dayName']})に練習日を決定しました！',
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Refresh data
      _loadPopularDates();
      _loadPendingPractices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('決定に失敗しました: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _loadPendingPractices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoadingPractices = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('practice_decisions')
          .where('status', isEqualTo: 'pending')
          .get();

      List<Map<String, dynamic>> practices = [];
      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final practiceDate = (data['practiceDate'] as Timestamp).toDate();

        // Only include future practices where user was available
        if (practiceDate.isAfter(now) &&
            (data['availableMembers'] as List).contains(user.uid)) {
          final dayName = daysOfWeek[practiceDate.weekday % 7];
          final responses = data['responses'] as Map<String, dynamic>? ?? {};
          final userResponse = responses[user.uid];

          practices.add({
            'docId': doc.id,
            'date': practiceDate,
            'dayName': dayName,
            'decidedBy': data['decidedBy'],
            'availableMembers': data['availableMembers'],
            'responses': responses,
            'userResponse': userResponse,
            'decidedAt': data['decidedAt'],
          });
        }
      }

      // Sort by practice date
      practices.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
      );

      setState(() {
        _pendingPractices = practices;
        _isLoadingPractices = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPractices = false;
      });
    }
  }

  Future<void> _respondToPractice(String docId, String response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('practice_decisions')
          .doc(docId)
          .update({'responses.${user.uid}': response});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response == 'join' ? '参加で回答しました！' : '見送りで回答しました'),
            backgroundColor: response == 'join'
                ? const Color(0xFF10B981)
                : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Refresh data
      _loadPendingPractices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('回答に失敗しました: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getNextPracticeText() {
    // 最も近い日程を取得
    DateTime? nextDate;
    for (var date in _nextPlayDates) {
      if (date != null) {
        if (nextDate == null || date.isBefore(nextDate)) {
          nextDate = date;
        }
      }
    }

    if (nextDate == null) {
      return '未定';
    } else {
      return '${nextDate.month}/${nextDate.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 48,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 16,
                bottom: 16,
              ),
              title: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_basketball_outlined,
                        color: Theme.of(context).appBarTheme.foregroundColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'motimate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildNotificationBell(),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,

                    colors: [],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // フィードバック告知バナー
                _buildFeedbackBanner(),
                const SizedBox(height: 16),
                // 人気の日程セクション
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '人気の日程',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_isLoadingSchedule)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      else if (_popularDates.isNotEmpty)
                        Column(
                          children: [
                            ..._popularDates
                                .take(2)
                                .map(
                                  (dateInfo) => _buildPopularDateItem(dateInfo),
                                ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  widget.onNavigate(1);
                                },
                                icon: const Icon(Icons.add_rounded, size: 20),
                                label: const Text(
                                  '新しい日程を追加',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF667eea),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.event,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'まだ日程候補がありません',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    widget.onNavigate(1);
                                  },
                                  icon: const Icon(Icons.add_rounded, size: 20),
                                  label: const Text(
                                    '日程を決める',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF667eea),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Pending Practice Decisions Section
                if (!_isLoadingPractices && _pendingPractices.isNotEmpty)
                  ..._pendingPractices.map(
                    (practice) => _buildPendingPracticeCard(practice),
                  ),

                // Personal Motivation Slider Section
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF667eea,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.mood,
                              color: Color(0xFF667eea),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'バスケのモチベ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Current motivation display
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(
                                motivationLevels[_currentMotivation.round() -
                                    1]['color'][0],
                              ),
                              Color(
                                motivationLevels[_currentMotivation.round() -
                                    1]['color'][1],
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              motivationLevels[_currentMotivation.round() -
                                  1]['emoji'],
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    motivationLevels[_currentMotivation
                                            .round() -
                                        1]['label'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'レベル ${_currentMotivation.round()}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isUpdatingMotivation)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Motivation slider
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: motivationLevels.map((level) {
                              final isSelected =
                                  level['level'] == _currentMotivation.round();
                              return Text(
                                level['emoji'],
                                style: TextStyle(
                                  fontSize: isSelected ? 24 : 18,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Color(
                                motivationLevels[_currentMotivation.round() -
                                    1]['color'][0],
                              ),
                              inactiveTrackColor: const Color(0xFFE2E8F0),
                              thumbColor: Color(
                                motivationLevels[_currentMotivation.round() -
                                    1]['color'][1],
                              ),
                              overlayColor: Color(
                                motivationLevels[_currentMotivation.round() -
                                    1]['color'][0],
                              ).withValues(alpha: 0.2),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12,
                              ),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: _currentMotivation,
                              min: 1,
                              max: 5,
                              divisions: 4,
                              onChanged: _isUpdatingMotivation
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _currentMotivation = value;
                                      });
                                    },
                              onChangeEnd: (value) {
                                if (!_isUpdatingMotivation) {
                                  _updateMotivation(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // チーム全体のモチベーションとTOP3表示セクション
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('エラー: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('まだモチベーションが登録されていません。'));
                    }

                    final List<Map<String, dynamic>> allMotivations = [];
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data.containsKey('latestMotivationLevel') &&
                          data.containsKey('latestMotivationTimestamp')) {
                        allMotivations.add({
                          'userId': doc.id,
                          'displayName':
                              data['displayName'] ??
                              data['username'] ??
                              'Unknown',
                          'username': data['username'] ?? '',
                          'department': data['department'] ?? '',
                          'group': data['group'] ?? '',
                          'level': data['latestMotivationLevel'],
                          'comment': data['latestMotivationComment'] ?? '',
                          'timestamp': data['latestMotivationTimestamp'],
                        });
                      }
                    }

                    if (allMotivations.isEmpty) {
                      return const Center(child: Text('まだモチベーションが登録されていません。'));
                    }

                    // Calculate average motivation
                    double totalMotivation = 0;
                    for (var m in allMotivations) {
                      totalMotivation += m['level'];
                    }
                    final averageMotivation =
                        totalMotivation / allMotivations.length;

                    // Get top 3 motivations (sorted by level, then by timestamp)
                    allMotivations.sort((a, b) {
                      int levelComparison = b['level'].compareTo(a['level']);
                      if (levelComparison != 0) return levelComparison;
                      return (b['timestamp'] as Timestamp).compareTo(
                        a['timestamp'] as Timestamp,
                      );
                    });
                    final top3Motivations = allMotivations.take(3).toList();

                    return Column(
                      children: [
                        // チーム平均モチベーション
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF667eea,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.trending_up_rounded,
                                      color: Color(0xFF667eea),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'チーム平均やる気',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    averageMotivation.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF667eea),
                                    ),
                                  ),
                                  const Text(
                                    ' / 5.0',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // TOP3 セクション
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFB923C,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.emoji_events_rounded,
                                      color: Color(0xFFFB923C),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'やる気ランキング TOP3',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ...top3Motivations.asMap().entries.map((entry) {
                                final index = entry.key;
                                final motivation = entry.value;
                                final rankColors = [
                                  const Color(0xFFFFD700), // Gold
                                  const Color(0xFFC0C0C0), // Silver
                                  const Color(0xFFCD7F32), // Bronze
                                ];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: rankColors[index].withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: rankColors[index],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              motivation['displayName'] ??
                                                  'Unknown User',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            if (motivation['department']
                                                        ?.isNotEmpty ==
                                                    true ||
                                                motivation['group']
                                                        ?.isNotEmpty ==
                                                    true)
                                              Text(
                                                [
                                                      motivation['department'],
                                                      motivation['group'],
                                                    ]
                                                    .where(
                                                      (s) =>
                                                          s?.isNotEmpty == true,
                                                    )
                                                    .join(' / '),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                            if (motivation['comment'] != null &&
                                                motivation['comment']
                                                    .isNotEmpty)
                                              Text(
                                                motivation['comment'],
                                                style: const TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF667eea,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          '${motivation['level']}',
                                          style: const TextStyle(
                                            color: Color(0xFF667eea),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDateItem(Map<String, dynamic> dateInfo) {
    final date = dateInfo['date'] as DateTime;
    final dayName = dateInfo['dayName'] as String;
    final memberCount = dateInfo['memberCount'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '${date.day}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '($dayName)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.month}月${date.day}日',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$memberCount人が参加可能',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showDecisionDialog(dateInfo),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF667eea),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(0, 0),
            ),
            child: const Text(
              '決定',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDecisionDialog(Map<String, dynamic> dateInfo) {
    final date = dateInfo['date'] as DateTime;
    final dayName = dateInfo['dayName'] as String;
    final memberCount = dateInfo['memberCount'] as int;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '日程の決定',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${date.month}月${date.day}日(${dayName})に日程を決定しますか？',
                style: const TextStyle(fontSize: 16, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          color: Color(0xFF667eea),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$memberCount人が参加可能',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '決定すると、参加可能なメンバーに通知が送信され、参加/見送りの回答を求めます。',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'キャンセル',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _decidePracticeDate(dateInfo);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '決定する',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPendingPracticeCard(Map<String, dynamic> practice) {
    final date = practice['date'] as DateTime;
    final dayName = practice['dayName'] as String;
    final userResponse = practice['userResponse'] as String?;
    final responses = practice['responses'] as Map<String, dynamic>;

    // Count responses
    int joinCount = 0;
    int skipCount = 0;
    responses.forEach((key, value) {
      if (value == 'join') joinCount++;
      if (value == 'skip') skipCount++;
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: userResponse == null
              ? const Color(0xFFFB923C)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFB923C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notification_important,
                  color: Color(0xFFFB923C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '日程が決定されました！',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Practice date info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      '${date.day}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '($dayName)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.month}月${date.day}日',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '参加: ${joinCount}人 / 見送り: ${skipCount}人',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Response section
          if (userResponse == null) ...[
            const Text(
              'あなたの参加状況を教えてください',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _respondToPractice(practice['docId'], 'join'),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text(
                      '参加する',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _respondToPractice(practice['docId'], 'skip'),
                    icon: const Icon(Icons.cancel_outlined, size: 20),
                    label: const Text(
                      '見送り',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: userResponse == 'join'
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    userResponse == 'join' ? Icons.check_circle : Icons.cancel,
                    color: userResponse == 'join'
                        ? const Color(0xFF10B981)
                        : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userResponse == 'join' ? '参加で回答済み' : '見送りで回答済み',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: userResponse == 'join'
                                ? const Color(0xFF10B981)
                                : Colors.orange,
                          ),
                        ),
                        const Text(
                          '回答を変更したい場合は、再度ボタンを押してください',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _respondToPractice(
                      practice['docId'],
                      userResponse == 'join' ? 'skip' : 'join',
                    ),
                    child: Text(
                      userResponse == 'join' ? '見送りに変更' : '参加に変更',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: NotificationService.getUnreadNotificationCount(user.uid),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  size: 24,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const FeedbackScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.feedback_outlined,
              color: Color(0xFF667eea),
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'フィードバックをお聞かせください 💭',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
