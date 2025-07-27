import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/notification_model.dart';
import '../themes/app_theme.dart';
import '../providers/providers.dart';

class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final searchQuery = useState('');
    final selectedFilter = useState('all'); // all, unread, read
    
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
              // Modern Header
              _buildModernHeader(isDarkMode, context, ref),
              
              // Search and Filter Bar
              _buildSearchAndFilterBar(searchQuery, selectedFilter, isDarkMode),
              
              // Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Force refresh the stream
                  },
                  backgroundColor: AppTheme.cardBackground(isDarkMode),
                  color: AppTheme.accentColor,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getNotificationsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingState(isDarkMode);
                      }

                      if (snapshot.hasError) {
                        return _buildErrorState(isDarkMode, snapshot.error.toString());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState(isDarkMode);
                      }

                      final allNotifications = snapshot.data!.docs
                          .map((doc) => NotificationModel.fromFirestore(doc))
                          .toList()
                        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      
                      // Apply search and filter
                      final filteredNotifications = _filterNotifications(
                        allNotifications, 
                        searchQuery.value, 
                        selectedFilter.value
                      );

                      if (filteredNotifications.isEmpty && (searchQuery.value.isNotEmpty || selectedFilter.value != 'all')) {
                        return _buildSearchEmptyState(isDarkMode, searchQuery.value, selectedFilter.value);
                      }

                      return _buildNotificationsList(filteredNotifications, isDarkMode);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> notifications, 
    String searchQuery, 
    String filter
  ) {
    var filtered = notifications;
    
    // Apply filter
    switch (filter) {
      case 'unread':
        filtered = filtered.where((n) => !n.isRead).toList();
        break;
      case 'read':
        filtered = filtered.where((n) => n.isRead).toList();
        break;
      default: // 'all'
        break;
    }
    
    // Apply search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(query) ||
               n.body.toLowerCase().contains(query);
      }).toList();
    }
    
    return filtered;
  }

  Widget _buildModernHeader(bool isDarkMode, BuildContext context, WidgetRef ref) {
    final notificationsStream = _getNotificationsStream();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.1),
            AppTheme.accentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Semantics(
            label: '戻るボタン',
            hint: 'タップして前の画面に戻る',
            button: true,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.cardBackground(isDarkMode),
                foregroundColor: AppTheme.primaryText(isDarkMode),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: AppTheme.primaryText(isDarkMode),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '通知',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText(isDarkMode),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                StreamBuilder<QuerySnapshot>(
                  stream: notificationsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final notifications = snapshot.data!.docs
                          .map((doc) => NotificationModel.fromFirestore(doc))
                          .toList();
                      final unreadCount = notifications.where((n) => !n.isRead).length;
                      return Text(
                        unreadCount > 0 
                            ? '$unreadCount件の未読通知があります'
                            : 'すべて既読済み',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryText(isDarkMode),
                        ),
                      );
                    }
                    return Text(
                      '通知を確認',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryText(isDarkMode),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Semantics(
            label: 'すべて既読にする',
            hint: 'タップしてすべての通知を既読にする',
            button: true,
            child: IconButton(
              onPressed: () => _markAllAsRead(context, ref),
              icon: const Icon(Icons.done_all),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.accentColor.withValues(alpha: 0.1),
                foregroundColor: AppTheme.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar(ValueNotifier<String> searchQuery, ValueNotifier<String> selectedFilter, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: Semantics(
              label: '通知検索欄',
              hint: 'タイトルや内容で通知を検索できます',
              textField: true,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground(isDarkMode),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.1 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => searchQuery.value = value,
                  style: TextStyle(color: AppTheme.primaryText(isDarkMode)),
                  decoration: InputDecoration(
                    hintText: 'タイトルや内容で検索...',
                    hintStyle: TextStyle(color: AppTheme.tertiaryText(isDarkMode)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.accentColor,
                    ),
                    suffixIcon: searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppTheme.tertiaryText(isDarkMode),
                            ),
                            onPressed: () => searchQuery.value = '',
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter dropdown
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground(isDarkMode),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.1 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter.value,
                onChanged: (value) => selectedFilter.value = value!,
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications, size: 16, color: AppTheme.accentColor),
                        const SizedBox(width: 8),
                        Text('すべて', style: TextStyle(color: AppTheme.primaryText(isDarkMode))),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'unread',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 16, color: AppTheme.accentColor),
                        const SizedBox(width: 8),
                        Text('未読', style: TextStyle(color: AppTheme.primaryText(isDarkMode))),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'read',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: AppTheme.tertiaryText(isDarkMode)),
                        const SizedBox(width: 8),
                        Text('既読', style: TextStyle(color: AppTheme.primaryText(isDarkMode))),
                      ],
                    ),
                  ),
                ],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderRadius: BorderRadius.circular(12),
                dropdownColor: AppTheme.cardBackground(isDarkMode),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications, bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildModernNotificationCard(notification, isDarkMode);
      },
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground(isDarkMode),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CircularProgressIndicator(
              color: AppTheme.accentColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '通知を読み込み中...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryText(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentColor.withValues(alpha: 0.2),
                    AppTheme.accentColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.notifications_off,
                size: 60,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '通知はありません',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '新しい通知があると\nこちらに表示されます',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryText(isDarkMode),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'エラーが発生しました',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText(isDarkMode),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState(bool isDarkMode, String query, String filter) {
    String filterText = '';
    switch (filter) {
      case 'unread':
        filterText = '未読の';
        break;
      case 'read':
        filterText = '既読の';
        break;
      default:
        filterText = '';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.tertiaryText(isDarkMode).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.search_off,
                size: 50,
                color: AppTheme.tertiaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '検索結果が見つかりません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            if (query.isNotEmpty)
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryText(isDarkMode),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: '$filterText通知で「'),
                    TextSpan(
                      text: query,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const TextSpan(text: '」に一致するものが見つかりませんでした'),
                  ],
                ),
              )
            else
              Text(
                '${filterText}通知が見つかりませんでした',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText(isDarkMode),
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNotificationCard(NotificationModel notification, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        label: '通知カード: ${notification.title}',
        hint: notification.isRead ? '既読' : '未読、タップして既読にする',
        button: true,
        child: Card(
          elevation: notification.isRead ? 2 : 6,
          color: AppTheme.cardBackground(isDarkMode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: notification.isRead
                ? BorderSide.none
                : BorderSide(
                    color: AppTheme.accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
          ),
          child: InkWell(
            onTap: () => _markAsRead(notification),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: notification.isRead 
                  ? null 
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentColor.withValues(alpha: 0.05),
                          AppTheme.accentColor.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type icon with enhanced design
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          notification.typeColor,
                          notification.typeColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: notification.typeColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      notification.typeIcon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                  color: AppTheme.primaryText(isDarkMode),
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.accentColor,
                                      AppTheme.accentColor.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentColor.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryText(isDarkMode),
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.containerBackground(isDarkMode),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: AppTheme.tertiaryText(isDarkMode),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    notification.timeAgo,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.tertiaryText(isDarkMode),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (notification.isRead)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '既読',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: const Color(0xFF10B981),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getNotificationsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .limit(50)
        .snapshots();
  }


  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notification.id)
          .update({'isRead': true});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to mark notification as read: $e');
      }
    }
  }

  Future<void> _markAllAsRead(BuildContext context, WidgetRef ref) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final unreadNotifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('すべての通知を既読にしました'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}