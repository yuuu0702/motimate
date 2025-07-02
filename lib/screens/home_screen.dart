import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _currentMotivationLevel = 3.0;
  final TextEditingController _commentController = TextEditingController();
  List<DateTime?> _nextPlayDates = [null, null]; // New state variable for two dates

  @override
  void initState() {
    super.initState();
    _loadUserMotivationAndComment();
    _loadNextPlayDate(); // Call new method
  }

  Future<void> _loadUserMotivationAndComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null) {
        setState(() {
          _currentMotivationLevel = (data['latestMotivationLevel'] as int?)?.toDouble() ?? 3.0;
          _commentController.text = data['latestMotivationComment'] as String? ?? '';
        });
      }
    }
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

  Future<void> _updateMotivationLevel(double newLevel) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _currentMotivationLevel = newLevel;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'latestMotivationLevel': newLevel.round(),
        'latestMotivationTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('モチベーションの更新に失敗しました: $e')),
      );
    }
  }

  Future<void> _updateComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'latestMotivationComment': _commentController.text,
        'latestMotivationTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('コメントを更新しました！')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('コメントの更新に失敗しました: $e')),
      );
    }
  }

  Future<void> _updateNextPlayDate(DateTime date, int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Update the local list first
    setState(() {
      _nextPlayDates[index] = date;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nextPlayDates': _nextPlayDates.map((d) => d != null ? Timestamp.fromDate(d) : null).toList(),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('次にバスケをやりたい日程 ${index + 1} を ${date.month}/${date.day} に設定しました！')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('日程の更新に失敗しました: $e')),
      );
    }
  }

  String _getEmojiForMotivation(int level) {
    switch (level) {
      case 1:
        return '😩';
      case 2:
        return '🙁';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '';
    }
  }

  Widget _buildDateSelectionTile(int index) {
    return ListTile(
      title: Text(
        _nextPlayDates[index] == null
            ? '日程 ${index + 1}: 未設定'
            : '日程 ${index + 1}: ${_nextPlayDates[index]!.month}/${_nextPlayDates[index]!.day}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _nextPlayDates[index] ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(DateTime.now().year + 1),
          );
          if (picked != null && picked != _nextPlayDates[index]) {
            _updateNextPlayDate(picked, index);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // モチベーション入力セクション
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日のバスケに行きたい度',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          _getEmojiForMotivation(_currentMotivationLevel.round()),
                          key: ValueKey<int>(_currentMotivationLevel.round()),
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
                    Slider(
                      value: _currentMotivationLevel,
                      min: 1.0,
                      max: 5.0,
                      divisions: 4,
                      onChanged: (double value) {
                        _updateMotivationLevel(value);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Text('1'),
                        Text('2'),
                        Text('3'),
                        Text('4'),
                        Text('5'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'コメント (任意)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: '今日の気分や意気込みをどうぞ',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onSubmitted: (_) => _updateComment(), // Enterキーで更新
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _updateComment,
                        child: const Text('コメントを更新'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 次のバスケ日程選択セクション
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '次にバスケをやりたい日程',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildDateSelectionTile(0),
                    _buildDateSelectionTile(1),
                  ],
                ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '現在のサークルのモチベーション (平均)',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              averageMotivation.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      '今日のモチベーションTOP3',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: top3Motivations.length,
                      itemBuilder: (context, index) {
                        final motivation = top3Motivations[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(motivation['level'].toString()),
                            ),
                            title: Text('ユーザーID: ${motivation['userId'] ?? '不明'}'),
                            subtitle: Text(
                              'コメント: ${motivation['comment'] ?? 'なし'}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              '${(motivation['timestamp'] as Timestamp).toDate().month}/${(motivation['timestamp'] as Timestamp).toDate().day}'
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
