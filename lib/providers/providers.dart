import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/motivation_service.dart';
import '../services/schedule_service.dart';
import '../services/practice_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../core/theme/theme_controller.dart';
import '../core/error/error_handler.dart';

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
    ref.watch(motivationServiceProvider),
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

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(0);
  
  return NotificationService.getUnreadNotificationCount(user.uid);
});

// Legacy theme provider for backward compatibility
final themeProvider = Provider<bool>((ref) {
  final theme = ref.watch(themeControllerProvider);
  return theme == ThemeMode.dark;
});