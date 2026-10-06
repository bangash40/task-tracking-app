import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserModel?>? _profileSub;

  User? _firebaseUser;
  UserModel? _profile;
  bool _initializing = true;
  bool _busy = false;
  String? _error;

  AuthProvider({AuthService? authService, UserService? userService})
      : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService() {
    _authSub = _authService.authStateChanges.listen(_onAuthChanged);
  }

  /// True until the first auth state (and profile, if signed in) is known.
  bool get initializing => _initializing;

  /// True while a login or registration request is running.
  bool get busy => _busy;

  String? get error => _error;

  bool get isSignedIn => _firebaseUser != null;

  User? get firebaseUser => _firebaseUser;

  /// The signed-in user's Firestore profile, or null if not loaded yet.
  UserModel? get profile => _profile;

  void _onAuthChanged(User? user) {
    _profileSub?.cancel();
    _profileSub = null;
    _firebaseUser = user;
    _profile = null;

    if (user == null) {
      _initializing = false;
      notifyListeners();
      return;
    }

    _profileSub = _userService.watchUser(user.uid).listen(
      (profile) {
        _profile = profile;
        _initializing = false;
        notifyListeners();
      },
      onError: (_) {
        _initializing = false;
        _error = 'Could not load your profile.';
        notifyListeners();
      },
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    User? created;
    try {
      created = await _authService.register(email, password);
      await _userService.createUser(
        UserModel(
          uid: created.uid,
          name: name.trim(),
          email: email.trim(),
          role: UserRoles.intern,
        ),
      );
      _setBusy(false);
      return true;
    } catch (e) {
      // Do not leave an auth account behind without a profile document.
      if (created != null) {
        try {
          await created.delete();
        } catch (_) {}
      }
      _setBusy(false, error: AuthService.messageFor(e));
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setBusy(true);
    try {
      await _authService.login(email, password);
      _setBusy(false);
      return true;
    } catch (e) {
      _setBusy(false, error: AuthService.messageFor(e));
      return false;
    }
  }

  Future<void> logout() => _authService.logout();

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void _setBusy(bool value, {String? error}) {
    _busy = value;
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
