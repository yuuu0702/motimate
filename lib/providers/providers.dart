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
import '../core/cache/cache_manager.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../core/theme/theme_controller.dart';
import '../core/error/error_handler.dart';
import '../core/cache/cache_invalidation_controller.dart';

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