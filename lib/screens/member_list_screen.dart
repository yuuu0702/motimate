import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberListScreen extends StatelessWidget {
  const MemberListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                        shape: const CircleBorder(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'メンバー一覧',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
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

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User header
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FutureBuilder<DocumentSnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .get(),
                                        builder: (context, userSnapshot) {
                                          if (userSnapshot.hasData) {
                                            final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userData?['displayName'] ?? '${userId.substring(0, 8)}...',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1F2937),
                                                  ),
                                                ),
                                                Text(
                                                  userData?['department']?.isNotEmpty == true || userData?['group']?.isNotEmpty == true
                                                      ? [userData?['department'], userData?['group']]
                                                          .where((s) => s?.isNotEmpty == true)
                                                          .join(' / ')
                                                      : 'メンバー',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${userId.substring(0, 8)}...',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                              const Text(
                                                'メンバー',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                if (motivation != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Lv.${motivation['level']}',
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Motivation section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.sentiment_satisfied,
                                        color: Color(0xFF667eea),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'モチベーション',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    motivation != null
                                        ? '${motivation['level']}/5 ${motivation['comment']?.isNotEmpty == true ? '- ${motivation['comment']}' : ''}'
                                        : '未登録',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Availability section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF667eea),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '空き状況',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (availability != null && availability.isNotEmpty)
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: availability.entries.map((entry) {
                                        final date = entry.key;
                                        final isAvailable = entry.value;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isAvailable
                                                ? Colors.green.withValues(alpha: 0.1)
                                                : Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${date.month}/${date.day}',
                                            style: TextStyle(
                                              color: isAvailable ? Colors.green : Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  else
                                    const Text(
                                      '未登録',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
