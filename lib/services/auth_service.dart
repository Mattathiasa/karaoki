import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Auth service backed by Firebase Authentication.
///
/// Supports:
/// - Guest sessions via anonymous auth (scores are session-only)
/// - Email / password sign-in and sign-up
///
/// When Firebase is not configured (stub mode), falls back to a
/// local-only session so the app remains usable in development.
class AuthService extends ChangeNotifier {
  // Lazily resolved so construction never touches Firebase — in stub mode
  // (placeholder config) and in unit tests there is no initialized app.
  FirebaseAuth? _firebase;
  FirebaseAuth get _auth => _firebase ??= FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  AuthUser? _currentUser;
  AuthMode _mode = AuthMode.none;
  String? _lastError;

  AuthUser? get currentUser => _currentUser;
  AuthMode get mode => _mode;
  String? get lastError => _lastError;
  bool get isGuest => _mode == AuthMode.guest;

  /// Stream of auth state changes for listeners.
  Stream<AuthUser?> get authStateStream =>
      _auth.authStateChanges().map((user) => user == null
          ? null
          : AuthUser(
              uid: user.uid,
              email: user.email,
              displayName: user.displayName,
              isAnonymous: user.isAnonymous,
            ));

  /// Start listening to Firebase auth state and restore any session.
  void init() {
    _authSubscription?.cancel();
    try {
      _authSubscription = _auth.authStateChanges().listen((user) {
        if (user == null) {
          _currentUser = null;
          _mode = AuthMode.none;
        } else {
          _currentUser = AuthUser(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            isAnonymous: user.isAnonymous,
          );
          _mode = user.isAnonymous ? AuthMode.guest : AuthMode.email;
        }
        notifyListeners();
      });
    } catch (e) {
      // Firebase not initialized (stub mode): stay signed out locally.
      debugPrint('AuthService.init: Firebase unavailable ($e)');
    }
  }

  /// Sign in as a guest (anonymous auth).
  ///
  /// In stub mode (no Firebase), creates a local session instead.
  Future<bool> signInAsGuest() async {
    _lastError = null;
    try {
      final cred = await _auth.signInAnonymously();
      _currentUser = AuthUser(
        uid: cred.user!.uid,
        displayName: null,
        isAnonymous: true,
      );
      _mode = AuthMode.guest;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = _mapError(e);
      return false;
    } catch (e) {
      // Stub mode: no Firebase configured, use a local session
      _currentUser = AuthUser(
        uid: 'guest-${DateTime.now().millisecondsSinceEpoch}',
        displayName: null,
        isAnonymous: true,
      );
      _mode = AuthMode.guest;
      notifyListeners();
      return true;
    }
  }

  /// Sign in with email and password.
  Future<bool> signInWithEmail(String email, String password) async {
    _lastError = null;
    if (!_isValidEmail(email)) {
      _lastError = 'Enter a valid email address.';
      return false;
    }
    if (password.length < 8) {
      _lastError = 'Password must be at least 8 characters.';
      return false;
    }
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = AuthUser(
        uid: cred.user!.uid,
        email: cred.user!.email,
        displayName: cred.user!.displayName,
        isAnonymous: false,
      );
      _mode = AuthMode.email;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = _mapError(e);
      return false;
    } catch (e) {
      _lastError = 'Sign-in is unavailable without Firebase configured.';
      return false;
    }
  }

  /// Create an account with email and password.
  Future<bool> signUpWithEmail(String email, String password,
      {String? displayName}) async {
    _lastError = null;
    if (!_isValidEmail(email)) {
      _lastError = 'Enter a valid email address.';
      return false;
    }
    if (password.length < 8) {
      _lastError = 'Password must be at least 8 characters.';
      return false;
    }
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && displayName.trim().isNotEmpty) {
        await cred.user!.updateDisplayName(displayName.trim());
      }
      _currentUser = AuthUser(
        uid: cred.user!.uid,
        email: cred.user!.email,
        displayName: displayName?.trim(),
        isAnonymous: false,
      );
      _mode = AuthMode.email;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = _mapError(e);
      return false;
    } catch (e) {
      _lastError = 'Sign-up is unavailable without Firebase configured.';
      return false;
    }
  }

  /// Upgrade the current guest session to a permanent account
  /// without losing their session data.
  Future<bool> linkGuestToEmail(String email, String password) async {
    _lastError = null;
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) return false;
    try {
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      await user.linkWithCredential(credential);
      _mode = AuthMode.email;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = _mapError(e);
      return false;
    } catch (e) {
      _lastError = 'Account linking is unavailable without Firebase.';
      return false;
    }
  }

  /// Sign out of the current session.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    _currentUser = null;
    _mode = AuthMode.none;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address doesn\u2019t look right.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'email-already-in-use':
        return 'That email already has an account — sign in instead.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment and try again.';
      case 'network-request-failed':
        return 'No connection. Check your network and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is disabled in the Firebase console.';
      default:
        return 'Authentication failed (${e.code}).';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Minimal auth user model used across the app.
class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool isAnonymous;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.isAnonymous = false,
  });

  String get effectiveName =>
      displayName ?? (isAnonymous ? 'Guest' : email?.split('@').first ?? 'Player');
}

enum AuthMode { none, guest, email }
