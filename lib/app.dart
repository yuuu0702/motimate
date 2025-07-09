import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/theme_controller.dart';
import 'routing/app_router.dart';
import 'themes/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentLocation = GoRouterState.of(context).uri.toString();
    
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        ref,
        isDarkMode,
        currentLocation,
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    WidgetRef ref,
    bool isDarkMode,
    String currentLocation,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(isDarkMode),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'ホーム',
                route: AppRoutes.home,
                isActive: currentLocation == AppRoutes.home,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                context,
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'スケジュール',
                route: AppRoutes.schedule,
                isActive: currentLocation == AppRoutes.schedule,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                context,
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'メンバー',
                route: AppRoutes.memberList,
                isActive: currentLocation == AppRoutes.memberList,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: '設定',
                route: AppRoutes.settings,
                isActive: currentLocation == AppRoutes.settings,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required bool isActive,
    required bool isDarkMode,
  }) {
    final color = isActive
        ? const Color(0xFF667eea)
        : isDarkMode
            ? const Color(0xFF9CA3AF)
            : const Color(0xFF6B7280);

    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF667eea).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}