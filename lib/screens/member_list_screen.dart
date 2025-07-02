import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberListScreen extends StatelessWidget {
  const MemberListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メンバー一覧'),
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

              // Combine data and display
              final allUserIds = <String>{};
              allUserIds.addAll(latestMotivations.keys);
              allUserIds.addAll(userAvailability.keys);

              if (allUserIds.isEmpty) {
                return const Center(child: Text('まだメンバー情報がありません。'));
              }

              return ListView.builder(
                itemCount: allUserIds.length,
                itemBuilder: (context, index) {
                  final userId = allUserIds.elementAt(index);
                  final motivation = latestMotivations[userId];
                  final availability = userAvailability[userId];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), // Added
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ユーザーID: $userId',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'モチベーション: ${motivation != null ? '${motivation['level']} (${motivation['comment'] ?? 'なし'})' : '未登録'}',
                          ),
                          const SizedBox(height: 8),
                          Text('空き状況:'),
                          if (availability != null && availability.isNotEmpty)
                            ...availability.entries.map((entry) {
                              final date = entry.key;
                              final isAvailable = entry.value;
                              return Text(
                                '  ${date.month}/${date.day}: ${isAvailable ? '空き' : '不可'}',
                              );
                            }).toList()
                          else
                            const Text('  未登録'),
                        ],
                      ),
                    ),
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
