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
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('データの取得エラー: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('まだメンバー情報がありません。'));
                    }

                    // Filter users who have completed profile setup
                    final users = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['profileSetup'] == true;
                    }).toList();

                    if (users.isEmpty) {
                      return const Center(child: Text('まだメンバー情報がありません。'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final userDoc = users[index];
                        final userData = userDoc.data() as Map<String, dynamic>;
                        final userId = userDoc.id;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
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
                                            colors: [
                                              Color(0xFF667eea),
                                              Color(0xFF764ba2),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userData['displayName'] ??
                                                  userData['username'] ??
                                                  'Unknown User',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1F2937),
                                              ),
                                            ),
                                            Text(
                                              userData['department']
                                                              ?.isNotEmpty ==
                                                          true ||
                                                      userData['group']
                                                              ?.isNotEmpty ==
                                                          true
                                                  ? [
                                                          userData['department'],
                                                          userData['group'],
                                                        ]
                                                        .where(
                                                          (s) =>
                                                              s?.isNotEmpty ==
                                                              true,
                                                        )
                                                        .join(' / ')
                                                  : 'メンバー',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          userData['latestMotivationLevel'] !=
                                                  null
                                              ? '${userData['latestMotivationLevel']}/5'
                                              : '未登録',
                                          style: const TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (userData['latestMotivationTimestamp'] !=
                                            null)
                                          Text(
                                            '最終更新: ${_formatTimestamp(userData['latestMotivationTimestamp'] as Timestamp)}',
                                            style: const TextStyle(
                                              color: Color(0xFF9CA3AF),
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Bio section (if available)
                                  if (userData['bio']?.isNotEmpty == true)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.chat_bubble_outline,
                                                color: Color(0xFF667eea),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                '自己紹介',
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
                                            userData['bio'],
                                            style: const TextStyle(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
