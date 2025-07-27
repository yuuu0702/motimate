import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/auth_screen.dart';
import '../screens/user_registration_screen.dart';
import '../screens/home_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/member_list_screen.dart';
import '../screens/motivation_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/user_settings_screen.dart';
import '../screens/basketball_history_screen.dart';
import '../screens/splash_screen.dart';
import '../app.dart';
import '../core/auth/auth_state_provider.dart';
import '../core/auth/auth_refresh_notifier.dart';

/// App routes
abstract class AppRoutes {
  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String registration = '/registration';
  static const String home = '/';
  static const String schedule = '/schedule';
  static const String memberList = '/member-list';
  static const String motivation = '/motivation';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String basketballHistory = '/basketball-history';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authRefreshNotifier = ref.watch(authRefreshNotifierProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authRefreshNotifier,
    redirect: (context, state) {
      final authStatus = ref.read(authStateProvider);
      final location = state.uri.toString();
      
      // Show splash while auth state is being determined
      if (authStatus == AuthStatus.initial) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }
      
      // Redirect based on authentication status
      switch (authStatus) {
        case AuthStatus.unauthenticated:
          return location == AppRoutes.auth ? null : AppRoutes.auth;
        case AuthStatus.registrationRequired:
          return location == AppRoutes.registration ? null : AppRoutes.registration;
        case AuthStatus.authenticated:
          if (location == AppRoutes.auth || 
              location == AppRoutes.registration || 
              location == AppRoutes.splash) {
            return AppRoutes.home;
          }
          return null;
        case AuthStatus.initial:
          return AppRoutes.splash;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.registration,
        name: 'registration',
        builder: (context, state) => const UserRegistrationScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return App(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.schedule,
            name: 'schedule',
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: AppRoutes.memberList,
            name: 'memberList',
            builder: (context, state) => const MemberListScreen(),
          ),
          GoRoute(
            path: AppRoutes.motivation,
            name: 'motivation',
            builder: (context, state) => const MotivationScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const UserSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.basketballHistory,
            name: 'basketballHistory',
            builder: (context, state) => const BasketballHistoryScreen(),
          ),
        ],
      ),
    ],
  );
});