import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  registrationRequired,
}

class AuthStateNotifier extends StateNotifier<AuthStatus> {
  AuthStateNotifier() : super(AuthStatus.initial) {
    _initializeAuthState();
  }

  void _initializeAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        state = AuthStatus.unauthenticated;
      } else {
        await _checkUserRegistrationStatus(user);
      }
    });
  }

  Future<void> _checkUserRegistrationStatus(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final hasProfileSetup = doc.exists && 
          doc.data()?.containsKey('profileSetup') == true &&
          doc.data()!['profileSetup'] == true;
      
      if (hasProfileSetup) {
        state = AuthStatus.authenticated;
      } else {
        state = AuthStatus.registrationRequired;
      }
    } catch (e) {
      state = AuthStatus.registrationRequired;
    }
  }

  void markRegistrationComplete() {
    state = AuthStatus.authenticated;
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthStatus>((ref) {
  return AuthStateNotifier();
});