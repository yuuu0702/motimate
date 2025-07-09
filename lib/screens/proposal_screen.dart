import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProposalScreen extends StatefulWidget {
  const ProposalScreen({super.key});

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  void _voteForDate(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインしていません。投票できません。')),
      );
      return;
    }

    try {
      // Check if the user has already voted for this date
      final existingVote = await FirebaseFirestore.instance
          .collection('votes')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: Timestamp.fromDate(date))
          .get();

      if (existingVote.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('この日程にはすでに投票済みです。')),
          );
        }
        return;
      }

      await FirebaseFirestore.instance.collection('votes').add({
        'userId': user.uid,
        'date': Timestamp.fromDate(date),
        'timestamp': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${date.month}/${date.day} に投票しました！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('投票に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日程提案・投票'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('motivations').snapshots(),
        builder: (context, motivationSnapshot) {
          if (motivationSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (motivationSnapshot.hasError) {
            return Center(child: Text('モチベーションデータの取得エラー: ${motivationSnapshot.error}'));
          }

          final Map<String, dynamic> latestMotivations = {};
          for (var doc in motivationSnapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final userId = data['userId'];
            final timestamp = (data['timestamp'] as Timestamp).toDate();

            if (!latestMotivations.containsKey(userId) ||
                timestamp.isAfter((latestMotivations[userId]['timestamp'] as Timestamp).toDate())) {
              latestMotivations[userId] = data;
            }
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('availability').snapshots(),
            builder: (context, availabilitySnapshot) {
              if (availabilitySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (availabilitySnapshot.hasError) {
                return Center(child: Text('空き状況データの取得エラー: ${availabilitySnapshot.error}'));
              }

              final Map<String, Map<DateTime, bool>> userAvailability = {};
              for (var doc in availabilitySnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final userId = data['userId'];
                final date = (data['date'] as Timestamp).toDate();
                final isAvailable = data['isAvailable'];

                if (!userAvailability.containsKey(userId)) {
                  userAvailability[userId] = {};
                }
                userAvailability[userId]![date] = isAvailable;
              }

              // --- 日程提案ロジック --- //
              final Map<DateTime, double> proposedDates = {}; // Date -> Score
              final now = DateTime.now();
              // 今から30日間の日程を考慮
              for (int i = 0; i < 30; i++) {
                final date = DateTime(now.year, now.month, now.day + i);
                int availableUsersCount = 0;
                double totalMotivationForDate = 0;

                for (var userId in latestMotivations.keys) {
                  final userMotivations = latestMotivations[userId];
                  final userAvail = userAvailability[userId]?[date] ?? false;

                  if (userAvail && userMotivations != null) {
                    availableUsersCount++;
                    totalMotivationForDate += userMotivations['level'];
                  }
                }

                if (availableUsersCount > 0) {
                  final averageMotivationForDate = totalMotivationForDate / availableUsersCount;
                  // スコア計算: (空いている人数) * (空いている人の平均モチベーション)
                  proposedDates[date] = availableUsersCount * averageMotivationForDate;
                }
              }

              // スコアの高い順にソート
              final sortedProposals = proposedDates.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              if (sortedProposals.isEmpty) {
                return const Center(child: Text('提案できる日程がありません。'));
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('votes').snapshots(),
                builder: (context, voteSnapshot) {
                  if (voteSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (voteSnapshot.hasError) {
                    return Center(child: Text('投票データの取得エラー: ${voteSnapshot.error}'));
                  }

                  final Map<DateTime, int> votesCount = {};
                  for (var doc in voteSnapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final date = (data['date'] as Timestamp).toDate();
                    // Normalize date to remove time component for accurate counting
                    final normalizedDate = DateTime(date.year, date.month, date.day);
                    votesCount[normalizedDate] = (votesCount[normalizedDate] ?? 0) + 1;
                  }

                  return ListView.builder(
                    itemCount: sortedProposals.length,
                    itemBuilder: (context, index) {
                      final entry = sortedProposals[index];
                      final date = entry.key;
                      final score = entry.value;
                      final currentVotes = votesCount[date] ?? 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), // Added
                        child: ListTile(
                          title: Text(
                            '${date.month}/${date.day} (スコア: ${score.toStringAsFixed(2)})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '空き人数: ${userAvailability.keys.where((userId) => userAvailability[userId]?[date] == true).length}人, 投票数: $currentVotes人'
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _voteForDate(date),
                            child: const Text('投票'),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
