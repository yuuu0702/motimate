import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DateTime?> _nextPlayDates = [null, null];
  double _currentMotivation = 3.0;
  bool _isUpdatingMotivation = false;

  final List<Map<String, dynamic>> motivationLevels = [
    {'level': 1, 'emoji': '😴', 'label': 'お疲れ気味...', 'color': [0xFF9CA3AF, 0xFF6B7280]},
    {'level': 2, 'emoji': '😐', 'label': 'あまり気分が...', 'color': [0xFF60A5FA, 0xFF3B82F6]},
    {'level': 3, 'emoji': '🙂', 'label': '普通かな', 'color': [0xFFFBBF24, 0xFFF59E0B]},
    {'level': 4, 'emoji': '😊', 'label': 'やる気あり！', 'color': [0xFFFB923C, 0xFFEA580C]},
    {'level': 5, 'emoji': '🔥', 'label': '超やる気！！', 'color': [0xFFF87171, 0xFFEF4444]},
  ];

  @override
  void initState() {
    super.initState();
    _loadNextPlayDate();
    _loadCurrentMotivation();
  }


  Future<void> _loadNextPlayDate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null && data.containsKey('nextPlayDates')) {
        final List<dynamic> dates = data['nextPlayDates'];
        setState(() {
          _nextPlayDates = dates.map((timestamp) => (timestamp as Timestamp).toDate()).toList();
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

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null && data.containsKey('latestMotivationLevel')) {
        setState(() {
          _currentMotivation = (data['latestMotivationLevel'] as num).toDouble();
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
      // Save motivation record
      await FirebaseFirestore.instance.collection('motivations').add({
        'userId': user.uid,
        'level': newLevel.round(),
        'timestamp': Timestamp.now(),
      });

      // Update user's latest motivation
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
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'motimate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.sports_basketball,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    foregroundColor: const Color(0xFF667eea),
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 次回の練習セクション
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
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '次回の練習',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                            Text(
                              _getNextPracticeText(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/schedule');
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
                              color: const Color(0xFF667eea).withValues(alpha: 0.1),
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
                            '今日のやる気レベル',
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
                              Color(motivationLevels[_currentMotivation.round() - 1]['color'][0]),
                              Color(motivationLevels[_currentMotivation.round() - 1]['color'][1]),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              motivationLevels[_currentMotivation.round() - 1]['emoji'],
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    motivationLevels[_currentMotivation.round() - 1]['label'],
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
                                      color: Colors.white.withValues(alpha: 0.8),
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
                              final isSelected = level['level'] == _currentMotivation.round();
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
                              activeTrackColor: Color(motivationLevels[_currentMotivation.round() - 1]['color'][0]),
                              inactiveTrackColor: const Color(0xFFE2E8F0),
                              thumbColor: Color(motivationLevels[_currentMotivation.round() - 1]['color'][1]),
                              overlayColor: Color(motivationLevels[_currentMotivation.round() - 1]['color'][0]).withValues(alpha: 0.2),
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: _currentMotivation,
                              min: 1,
                              max: 5,
                              divisions: 4,
                              onChanged: _isUpdatingMotivation ? null : (value) {
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
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
                  if (data.containsKey('latestMotivationLevel') && data.containsKey('latestMotivationTimestamp')) {
                    allMotivations.add({
                      'userId': doc.id,
                      'displayName': data['displayName'] ?? data['username'] ?? 'Unknown',
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
                final averageMotivation = totalMotivation / allMotivations.length;

                // Get top 3 motivations (sorted by level, then by timestamp)
                allMotivations.sort((a, b) {
                  int levelComparison = b['level'].compareTo(a['level']);
                  if (levelComparison != 0) return levelComparison;
                  return (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp);
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
                                  color: const Color(0xFF667eea).withValues(alpha: 0.1),
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
                                  color: const Color(0xFFFB923C).withValues(alpha: 0.1),
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
                                  color: rankColors[index].withValues(alpha: 0.3),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          motivation['displayName'] ?? 'Unknown User',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        if (motivation['department']?.isNotEmpty == true || motivation['group']?.isNotEmpty == true)
                                          Text(
                                            [motivation['department'], motivation['group']]
                                                .where((s) => s?.isNotEmpty == true)
                                                .join(' / '),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        if (motivation['comment'] != null && motivation['comment'].isNotEmpty)
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF667eea).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
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
}
