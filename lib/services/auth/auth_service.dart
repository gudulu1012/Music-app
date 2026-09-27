import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_profile.dart';
import '../../data/firebase/firestore_service.dart';
import '../../core/constants/app_constants.dart';

/// Authentication states for the UI.
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Authentication service wrapping Firebase Auth.
///
/// Provides sign-in, sign-up, sign-out, and current user state.
/// Also creates/updates the user profile document in Firestore
/// on sign-up and sign-in.
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirestoreService _firestoreService;
  StreamSubscription<User?>? _authSubscription;

  AuthState _state = AuthState.initial;
  UserProfile? _currentUser;
  String? _errorMessage;

  AuthService({required FirestoreService firestoreService})
      : _auth = FirebaseAuth.instance,
        _firestoreService = firestoreService {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // ─── Getters ────────────────────────────────────────────────
  AuthState get state => _state;
  UserProfile? get currentUser => _currentUser;
  User? get firebaseUser => _auth.currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  String? get userId => _currentUser?.uid;

  /// Stream of Firebase auth state changes.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // ─── Auth State Listener ────────────────────────────────────

  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      // Load or create the user profile from Firestore
      await _loadUserProfile(user);
      _state = AuthState.authenticated;
    } else {
      _currentUser = null;
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Load the user's Firestore profile. If it doesn't exist yet
  /// (e.g. first sign-in on a new device), create it from the
  /// Firebase Auth user record.
  Future<void> _loadUserProfile(User user) async {
    try {
      final data = await _firestoreService.getDocument(
        AppConstants.usersCollection,
        user.uid,
      );

      final now = DateTime.now();
      if (data != null) {
        // Profile exists — update lastLoginAt and updatedAt
        _currentUser = UserProfile.fromMap(data).copyWith(
          lastLoginAt: now,
          updatedAt: now,
        );
        await _firestoreService.updateDocument(
          AppConstants.usersCollection,
          user.uid,
          {
            'lastLoginAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
        );
      } else {
        // Profile does not exist — create it safely without duplicates
        _currentUser = UserProfile(
          uid: user.uid,
          displayName: user.displayName ?? (user.email != null ? user.email!.split('@').first : 'User'),
          email: user.email,
          photoUrl: user.photoURL,
          createdAt: now,
          lastLoginAt: now,
          updatedAt: now,
        );
        await _firestoreService.setDocument(
          AppConstants.usersCollection,
          user.uid,
          _currentUser!.toMap(),
        );
      }
    } catch (e) {
      // If Firestore fails, still populate from Auth record
      final now = DateTime.now();
      _currentUser = UserProfile(
        uid: user.uid,
        displayName: user.displayName ?? 'User',
        email: user.email,
        photoUrl: user.photoURL,
        createdAt: now,
        lastLoginAt: now,
        updatedAt: now,
      );
      debugPrint('AuthService: Failed to load/create profile: $e');
    }
  }

  // ─── Auth Operations ────────────────────────────────────────

  /// Sign in with email and password (spec alias).
  Future<void> signIn(String email, String password) =>
      signInWithEmail(email, password);

  /// Create a new account with email and password (spec alias).
  Future<void> signUp(
    String email,
    String password, [
    String? displayName,
  ]) =>
      signUpWithEmail(
        email,
        password,
        displayName ?? email.split('@').first,
      );

  /// Sign in with email and password.
  Future<void> signInWithEmail(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // _onAuthStateChanged will handle profile and state updates
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
    }
  }

  /// Create a new account with email and password.
  Future<void> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Set the display name on the Firebase Auth user
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();

      // Create the Firestore profile document
      final user = _auth.currentUser;
      if (user != null) {
        final now = DateTime.now();
        _currentUser = UserProfile(
          uid: user.uid,
          displayName: displayName,
          email: email,
          createdAt: now,
          lastLoginAt: now,
          updatedAt: now,
        );
        await _firestoreService.setDocument(
          AppConstants.usersCollection,
          user.uid,
          _currentUser!.toMap(),
        );
        _state = AuthState.authenticated;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
    // _onAuthStateChanged will set state to unauthenticated
  }

  /// Reset password for the given email.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  // ─── Error Mapping ──────────────────────────────────────────

  /// Map Firebase Auth error codes to user-friendly messages.
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // ─── Cleanup ────────────────────────────────────────────────

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
