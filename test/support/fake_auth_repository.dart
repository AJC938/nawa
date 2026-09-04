import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nawa/features/auth/data/auth_repository.dart';

/// Minimal fake [User] — real [User] instances can only come from Firebase,
/// which isn't initialized in plain widget/unit tests.
class MockUser extends Mock implements User {
  MockUser([this._email = 'parent@nawa.app', String? uid]) : _uid = uid ?? 'uid-${_email.hashCode}';

  final String _email;
  final String _uid;

  @override
  String get email => _email;

  @override
  String get uid => _uid;
}

/// In-memory stand-in for [FirebaseAuthRepository]. Lets any test that
/// pumps the full app (and therefore touches [authControllerProvider])
/// run without a real Firebase app being initialized.
class FakeAuthRepository implements AuthRepository {
  User? _currentUser;
  final _controller = StreamController<User?>.broadcast();

  bool failSignIn = false;
  bool failSignUp = false;
  String failureCode = 'invalid-credential';

  void seedCurrentUser(User user) => _currentUser = user;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<User> signIn({required String email, required String password}) async {
    if (failSignIn) throw FirebaseAuthException(code: failureCode);
    final user = MockUser(email);
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<User> signUp({required String email, required String password, String? displayName}) async {
    if (failSignUp) throw FirebaseAuthException(code: failureCode);
    final user = MockUser(email);
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}
