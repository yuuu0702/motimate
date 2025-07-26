import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/providers.dart';
import '../themes/app_theme.dart';
import '../widgets/cards/member_card.dart';

enum SortOption {
  name,
  motivation,
  lastUpdate,
}

class MemberListScreen extends HookConsumerWidget {
  const MemberListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final searchQuery = useState('');
    final sortOption = useState(SortOption.name);
    
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
              // Header with search
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'メンバー一覧',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText(isDarkMode),
                            ),
                          ),
                        ),
                        PopupMenuButton<SortOption>(
                          icon: Icon(
                            Icons.sort,
                            color: AppTheme.primaryText(isDarkMode),
                          ),
                          onSelected: (option) => sortOption.value = option,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: SortOption.name,
                              child: Row(
                                children: [
                                  Icon(Icons.sort_by_alpha),
                                  SizedBox(width: 8),
                                  Text('名前順'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: SortOption.motivation,
                              child: Row(
                                children: [
                                  Icon(Icons.favorite),
                                  SizedBox(width: 8),
                                  Text('モチベーション順'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: SortOption.lastUpdate,
                              child: Row(
                                children: [
                                  Icon(Icons.access_time),
                                  SizedBox(width: 8),
                                  Text('更新順'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground(isDarkMode),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) => searchQuery.value = value,
                        style: TextStyle(color: AppTheme.primaryText(isDarkMode)),
                        decoration: InputDecoration(
                          hintText: 'メンバーを検索...',
                          hintStyle: TextStyle(color: AppTheme.tertiaryText(isDarkMode)),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.tertiaryText(isDarkMode),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
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
                    var users = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['profileSetup'] == true;
                    }).toList();

                    // Apply search filter
                    if (searchQuery.value.isNotEmpty) {
                      users = users.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['displayName'] ?? data['username'] ?? '').toString().toLowerCase();
                        final department = (data['department'] ?? '').toString().toLowerCase();
                        final group = (data['group'] ?? '').toString().toLowerCase();
                        final query = searchQuery.value.toLowerCase();
                        
                        return name.contains(query) || 
                               department.contains(query) || 
                               group.contains(query);
                      }).toList();
                    }

                    // Apply sorting
                    switch (sortOption.value) {
                      case SortOption.name:
                        users.sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;
                          final aName = aData['displayName'] ?? aData['username'] ?? '';
                          final bName = bData['displayName'] ?? bData['username'] ?? '';
                          return aName.toString().compareTo(bName.toString());
                        });
                        break;
                      case SortOption.motivation:
                        users.sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;
                          final aLevel = aData['latestMotivationLevel'] ?? 0;
                          final bLevel = bData['latestMotivationLevel'] ?? 0;
                          return bLevel.compareTo(aLevel); // Descending
                        });
                        break;
                      case SortOption.lastUpdate:
                        users.sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;
                          final aTime = aData['latestMotivationTimestamp'] as Timestamp?;
                          final bTime = bData['latestMotivationTimestamp'] as Timestamp?;
                          
                          if (aTime == null && bTime == null) return 0;
                          if (aTime == null) return 1;
                          if (bTime == null) return -1;
                          
                          return bTime.compareTo(aTime); // Descending
                        });
                        break;
                    }

                    if (users.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppTheme.tertiaryText(isDarkMode),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.value.isNotEmpty 
                                  ? '検索結果が見つかりません'
                                  : 'まだメンバー情報がありません。',
                              style: TextStyle(
                                color: AppTheme.tertiaryText(isDarkMode),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final userDoc = users[index];
                        final userData = userDoc.data() as Map<String, dynamic>;
                        
                        return MemberCard(
                          userData: userData,
                          isDarkMode: isDarkMode,
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
