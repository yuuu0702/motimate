import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../services/motivation_service.dart';
import '../services/schedule_service.dart';
import '../services/practice_service.dart';
import '../services/user_cache_service.dart';
import '../services/cached_motivation_service.dart';
import '../services/cached_notification_service.dart';
import '../services/optimized_schedule_service.dart';
import '../services/image_cache_service.dart';
// マルチサークル対応サービス
import '../services/permission_service.dart';
import '../services/circle_service.dart';
import '../services/circle_member_service.dart';
import '../services/activity_service.dart';
import '../core/cache/cache_manager.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../core/theme/theme_controller.dart';
import '../core/error/error_handler.dart';
import '../core/cache/cache_invalidation_controller.dart';
import '../models/circle_model.dart';
import '../models/user_model.dart';

// Firebase instances
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

// Services
final motivationServiceProvider = Provider<MotivationService>((ref) {
  return MotivationService(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final practiceServiceProvider = Provider<PracticeService>((ref) {
  return PracticeService(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

// マルチサークル対応サービス
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final circleServiceProvider = Provider<CircleService>((ref) {
  return CircleService(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    permissionService: ref.watch(permissionServiceProvider),
  );
});

final circleMemberServiceProvider = Provider<CircleMemberService>((ref) {
  return CircleMemberService(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    permissionService: ref.watch(permissionServiceProvider),
    circleService: ref.watch(circleServiceProvider),
  );
});

final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityService(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    permissionService: ref.watch(permissionServiceProvider),
  );
});

// Cache Manager
final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

// User Cache Service
final userCacheServiceProvider = Provider<UserCacheService>((ref) {
  return UserCacheService(
    firestore: ref.watch(firestoreProvider),
    cacheManager: ref.watch(cacheManagerProvider),
  );
});

// Cached Motivation Service
final cachedMotivationServiceProvider = Provider<CachedMotivationService>((ref) {
  return CachedMotivationService(
    cacheManager: ref.watch(cacheManagerProvider),
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

// Optimized Schedule Service
final optimizedScheduleServiceProvider = Provider<OptimizedScheduleService>((ref) {
  return OptimizedScheduleService(
    cacheManager: ref.watch(cacheManagerProvider),
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

// Image Cache Service
final imageCacheServiceProvider = Provider<ImageCacheService>((ref) {
  return ImageCacheService(
    cacheManager: ref.watch(cacheManagerProvider),
  );
});

// Team Motivation Providers
final teamMotivationTop3Provider = FutureProvider<List<TeamMotivationData>>((ref) async {
  final service = ref.watch(cachedMotivationServiceProvider);
  return service.getTeamMotivationTop3();
});

// NotificationService is a static utility class, no provider needed

// ViewModels
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref.watch(googleSignInProvider),
    ref.watch(errorProvider.notifier),
  );
});

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(
    ref.watch(cachedMotivationServiceProvider),
    ref.watch(scheduleServiceProvider),
    ref.watch(practiceServiceProvider),
  );
});

final notificationViewModelProvider = StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  return NotificationViewModel(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

// Stream providers
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Updated to use cached notification service
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(0);
  
  // Use cached service for better performance
  final cachedService = ref.watch(cachedNotificationServiceProvider);
  return cachedService.watchUnreadNotificationCount(user.uid);
});

// Cache lifecycle management
final cacheLifecycleProvider = Provider<void>((ref) {
  // Initialize cache cleanup timer and lifecycle management
  ref.watch(cacheLifecycleManagerProvider);
  return;
});

// Legacy theme provider for backward compatibility
final themeProvider = Provider<bool>((ref) {
  final theme = ref.watch(themeControllerProvider);
  return theme == ThemeMode.dark;
});

// マルチサークル関連プロバイダー
// 現在のユーザー情報を監視
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  return ref.watch(firestoreProvider)
    .collection('users')
    .doc(user.uid)
    .snapshots()
    .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
});

// 現在のサークル情報を監視
final currentCircleProvider = StreamProvider<CircleModel?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user?.currentCircleId == null) return Stream.value(null);

  return ref.watch(firestoreProvider)
    .collection('circles')
    .doc(user!.currentCircleId!)
    .snapshots()
    .map((doc) => doc.exists ? CircleModel.fromFirestore(doc) : null);
});

// ユーザーが参加しているサークル一覧を監視
final userCirclesProvider = StreamProvider<List<CircleModel>>((ref) async* {
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.circleIds.isEmpty) {
    yield <CircleModel>[];
    return;
  }

  final firestore = ref.watch(firestoreProvider);
  final circles = <CircleModel>[];

  for (final circleId in user.circleIds) {
    try {
      final doc = await firestore.collection('circles').doc(circleId).get();
      if (doc.exists) {
        circles.add(CircleModel.fromFirestore(doc));
      }
    } catch (e) {
      // エラーが発生したサークルはスキップ
      continue;
    }
  }

  yield circles;
});