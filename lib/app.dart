import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motimate/screens/home_screen.dart';
import 'package:motimate/screens/member_list_screen.dart';
import 'package:motimate/screens/schedule_screen.dart';
import 'package:motimate/screens/user_settings_screen.dart';
import 'package:motimate/providers/providers.dart';
import 'package:motimate/themes/app_theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onNavigate: _onItemTapped),
      const ScheduleScreen(),
      const MemberListScreen(),
      const UserSettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor(isDarkMode),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.cardColor(isDarkMode),
          selectedItemColor: const Color(0xFF667eea),
          unselectedItemColor: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'ホーム',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              label: 'スケジュール',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'メンバー',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: '設定',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
