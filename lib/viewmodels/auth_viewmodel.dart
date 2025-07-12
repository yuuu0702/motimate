import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:motimate/models/user_model.dart';
import '../core/error/error_handler.dart';

part 'auth_viewmodel.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isSigningIn,
    User? user,
    UserModel? userModel,
    String? error,
  }) = _AuthState;
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel(this._auth, this._firestore, this._googleSignIn, this._errorNotifier)
      : super(const AuthState()) {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final ErrorNotifier _errorNotifier;

  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      state = state.copyWith(user: user, isLoading: true);
      await _loadUserModel(user.uid);
      state = state.copyWith(isLoading: false);
    } else {
      state = state.copyWith(user: null, userModel: null);
    }
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userModel = UserModel.fromFirestore(userDoc);
        state = state.copyWith(userModel: userModel);
      }
    } catch (e) {
      _errorNotifier.showErrorFromException(e);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isSigningIn: true, error: null);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isSigningIn: false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      state = state.copyWith(isSigningIn: false);
    } catch (e) {
      state = state.copyWith(isSigningIn: false);
      _errorNotifier.showErrorFromException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      _errorNotifier.showErrorFromException(e);
    }
  }

  Future<void> updateUserProfile(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toFirestore(), SetOptions(merge: true));
      
      state = state.copyWith(userModel: userModel);
    } catch (e) {
      _errorNotifier.showErrorFromException(e);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}