import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../themes/app_theme.dart';

class MemberCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool isDarkMode;

  const MemberCard({
    super.key,
    required this.userData,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = userData['displayName'] ?? userData['username'] ?? 'Unknown User';
    final motivationLevel = userData['latestMotivationLevel'] as int?;
    final department = userData['department'] as String?;
    final group = userData['group'] as String?;
    final bio = userData['bio'] as String?;
    final lastUpdate = userData['latestMotivationTimestamp'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppTheme.cardBackground(isDarkMode),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to member detail page
          },
          child: Semantics(
            label: 'メンバーカード: $displayName',
            hint: motivationLevel != null 
                ? 'モチベーション$motivationLevel/5、タップして詳細を見る'
                : 'モチベーション未設定、タップして詳細を見る',
            button: true,
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with user-specific color
                _buildAvatar(displayName),
                const SizedBox(width: 16),
                
                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and department row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText(isDarkMode),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (department?.isNotEmpty == true || group?.isNotEmpty == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                [department, group]
                                    .where((s) => s?.isNotEmpty == true)
                                    .join(' / '),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Motivation section with progress bar
                      if (motivationLevel != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 14,
                              color: _getMotivationColor(motivationLevel),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'モチベーション',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText(isDarkMode),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$motivationLevel/5',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getMotivationColor(motivationLevel),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _buildMotivationProgressBar(motivationLevel),
                        if (lastUpdate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _formatTimestamp(lastUpdate),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.tertiaryText(isDarkMode),
                              ),
                            ),
                          ),
                      ] else ...[
                        Row(
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 14,
                              color: AppTheme.tertiaryText(isDarkMode),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'モチベーション未設定',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.tertiaryText(isDarkMode),
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      // Bio preview (if available)
                      if (bio?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.containerBackground(isDarkMode),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bio!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.tertiaryText(isDarkMode),
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _buildAvatar(String displayName) {
    final avatarColor = _generateUserColor(displayName);
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            avatarColor,
            avatarColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: avatarColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationProgressBar(int level) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppTheme.containerBackground(isDarkMode),
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: level / 5.0,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(_getMotivationColor(level)),
        ),
      ),
    );
  }

  Color _generateUserColor(String name) {
    // Generate a consistent color based on the user's name
    final hash = name.hashCode;
    final hue = (hash % 360).toDouble();
    return HSVColor.fromAHSV(1.0, hue, 0.7, 0.8).toColor();
  }

  Color _getMotivationColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFFF6B6B); // Red
      case 2:
        return const Color(0xFFFF8E53); // Orange
      case 3:
        return const Color(0xFFFFD93D); // Yellow
      case 4:
        return const Color(0xFF6BCF7F); // Light green
      case 5:
        return const Color(0xFF4ECDC4); // Teal
      default:
        return Colors.grey;
    }
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