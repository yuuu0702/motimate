import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state_provider.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(this.ref) {
    ref.listen<AuthStatus>(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref ref;
}

final authRefreshNotifierProvider = Provider<AuthRefreshNotifier>((ref) {
  return AuthRefreshNotifier(ref);
});