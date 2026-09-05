import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notifications/data/notification_bootstrap.dart';
import '../../../notifications/data/notification_event_repository.dart';
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

    // Always safe to (re)arm foreground message display, regardless of
    // auth state — idempotent, so re-running build() never duplicates it.
    ref.read(notificationBootstrapProvider).listenForMessages();

    _subscription?.cancel();
    _subscription = repository.authStateChanges().listen((user) {
      state = user != null ? AuthState(status: AuthStatus.authenticated, user: user) : const AuthState();
    });
    ref.onDispose(() => _subscription?.cancel());

    final current = repository.currentUser;
    if (current != null) {
      // A persisted session resuming at app start isn't a fresh "login" —
      // no notification event here, just keep the device token fresh.
      unawaited(ref.read(notificationBootstrapProvider).registerToken(current.uid));
      return AuthState(status: AuthStatus.authenticated, user: current);
    }
    return const AuthState();
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AuthState(status: AuthStatus.loggingIn);
    try {
      final user = await ref.read(authRepositoryProvider).signIn(email: email.trim(), password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      // A genuine, one-shot login success — the single call site that
      // should ever record a login notification event, so a single login
      // can never produce more than one (the authStateChanges listener
      // above fires on every auth transition, including app-resume, and
      // must never be used for this).
      unawaited(_recordLoginEvent(user.uid));
      unawaited(ref.read(notificationBootstrapProvider).registerToken(user.uid));
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
      // Register for notifications, but a brand-new signup is not a
      // "login" — no welcome-back event here.
      unawaited(ref.read(notificationBootstrapProvider).registerToken(user.uid));
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

  /// Wrapped end to end (including constructing the repository itself) so
  /// notification plumbing — Firestore being briefly unavailable, or in a
  /// test environment where Firebase isn't initialized at all — can never
  /// throw back into a successful login.
  Future<void> _recordLoginEvent(String uid) async {
    try {
      await ref.read(notificationEventRepositoryProvider).recordLoginEvent(uid);
    } catch (_) {
      // Best-effort only — the login itself already succeeded.
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
