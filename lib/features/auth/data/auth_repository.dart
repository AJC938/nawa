import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin abstraction over Firebase Authentication so the rest of the app
/// (and tests) never touch [FirebaseAuth] directly.
abstract class AuthRepository {
  User? get currentUser;

  /// Emits the current user whenever Firebase's auth state changes,
  /// including the persisted session at app startup.
  Stream<User?> authStateChanges();

  Future<User> signIn({required String email, required String password});

  Future<User> signUp({required String email, required String password, String? displayName});

  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  Future<User> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return credential.user ?? (throw FirebaseAuthException(code: 'unknown'));
  }

  @override
  Future<User> signUp({required String email, required String password, String? displayName}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user ?? (throw FirebaseAuthException(code: 'unknown'));

    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }

    return _auth.currentUser ?? user;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => FirebaseAuthRepository());
