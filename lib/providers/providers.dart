import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motimate/services/notification_service.dart';
import 'package:motimate/viewmodels/auth_viewmodel.dart';
import 'package:motimate/viewmodels/home_viewmodel.dart';
import 'package:motimate/viewmodels/notification_viewmodel.dart';

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
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ViewModels
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref.watch(googleSignInProvider),
  );
});

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
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