import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/auth_screen.dart';
import '../screens/user_registration_screen.dart';
import '../screens/home_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/member_list_screen.dart';
import '../screens/motivation_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/user_settings_screen.dart';
import '../app.dart';

/// App routes
abstract class AppRoutes {
  static const String auth = '/auth';
  static const String registration = '/registration';
  static const String home = '/';
  static const String schedule = '/schedule';
  static const String memberList = '/member-list';
  static const String motivation = '/motivation';
  static const String notifications = '/notifications';
  static const String feedback = '/feedback';
  static const String settings = '/settings';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.uri.toString();
      
      // If user is not authenticated, redirect to auth
      if (user == null) {
        return location == AppRoutes.auth ? null : AppRoutes.auth;
      }
      
      // Check if user needs to complete registration
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        final hasProfileSetup = doc.exists && 
            (doc.data() as Map<String, dynamic>?)?.containsKey('profileSetup') == true &&
            (doc.data() as Map<String, dynamic>?)!['profileSetup'] == true;
        
        if (!hasProfileSetup && location != AppRoutes.registration) {
          return AppRoutes.registration;
        }
      } catch (e) {
        // If there's an error, assume user needs registration
        if (location != AppRoutes.registration) {
          return AppRoutes.registration;
        }
      }
      
      // If on auth page but authenticated, redirect to home
      if (location == AppRoutes.auth) {
        return AppRoutes.home;
      }
      
      return null;
    },
    routes: [
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
            path: AppRoutes.feedback,
            name: 'feedback',
            builder: (context, state) => const FeedbackScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const UserSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});