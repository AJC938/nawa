import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../domain/auth_error_code.dart';
import '../../domain/auth_state.dart';

/// Drives Nawa's parent authentication using Firebase Email/Password auth,
/// via [AuthRepository]. UI code never touches [FirebaseAuth] directly.
class AuthController extends Notifier<AuthState> {
  StreamSubscription<User?>? _subscription;

  @override
  AuthState build() {
    final repository = ref.watch(authRepositoryProvider);

    _subscription?.cancel();
    _subscription = repository.authStateChanges().listen((user) {
      state = user != null ? AuthState(status: AuthStatus.authenticated, user: user) : const AuthState();
    });
    ref.onDispose(() => _subscription?.cancel());

    final current = repository.currentUser;
    return current != null ? AuthState(status: AuthStatus.authenticated, user: current) : const AuthState();
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AuthState(status: AuthStatus.loggingIn);
    try {
      final user = await ref.read(authRepositoryProvider).signIn(email: email.trim(), password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorCode: authErrorCodeFromFirebase(e.code));
      return false;
    } catch (_) {
      state = const AuthState(status: AuthStatus.error, errorCode: AuthErrorCode.unknown);
      return false;
    }
  }

  Future<bool> createAccount({required String name, required String email, required String password}) async {
    state = const AuthState(status: AuthStatus.loggingIn);
    try {
      final user = await ref.read(authRepositoryProvider).signUp(
            email: email.trim(),
            password: password,
            displayName: name.trim(),
          );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorCode: authErrorCodeFromFirebase(e.code));
      return false;
    } catch (_) {
      state = const AuthState(status: AuthStatus.error, errorCode: AuthErrorCode.unknown);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
