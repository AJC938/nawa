import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/features/auth/data/auth_repository.dart';
import 'package:nawa/features/auth/domain/auth_error_code.dart';
import 'package:nawa/features/auth/domain/auth_state.dart';
import 'package:nawa/features/auth/presentation/state/auth_controller.dart';

import '../support/fake_auth_repository.dart';

void main() {
  group('AuthController (Firebase-backed via a fake repository)', () {
    late FakeAuthRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeAuthRepository();
      container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(repository)]);
    });

    tearDown(() => container.dispose());

    test('starts logged out when there is no persisted Firebase session', () {
      expect(container.read(authControllerProvider).status, AuthStatus.loggedOut);
    });

    test('starts authenticated when a Firebase session is already persisted at startup', () {
      final preAuthed = FakeAuthRepository()..seedCurrentUser(MockUser());
      final preAuthedContainer = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(preAuthed)]);
      addTearDown(preAuthedContainer.dispose);

      expect(preAuthedContainer.read(authControllerProvider).status, AuthStatus.authenticated);
    });

    test('login succeeds and exposes the authenticated Firebase user', () async {
      final ok = await container.read(authControllerProvider.notifier).login(email: 'parent@nawa.app', password: 'secret1');

      expect(ok, isTrue);
      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.email, 'parent@nawa.app');
    });

    test('login failure maps a FirebaseAuthException code to a friendly AuthErrorCode', () async {
      repository
        ..failSignIn = true
        ..failureCode = 'wrong-password';

      final ok = await container.read(authControllerProvider.notifier).login(email: 'parent@nawa.app', password: 'bad');

      expect(ok, isFalse);
      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorCode, AuthErrorCode.wrongPassword);
    });

    test('createAccount succeeds and becomes authenticated', () async {
      final ok = await container
          .read(authControllerProvider.notifier)
          .createAccount(name: 'Amal', email: 'amal@nawa.app', password: 'secret1');

      expect(ok, isTrue);
      expect(container.read(authControllerProvider).status, AuthStatus.authenticated);
    });

    test('createAccount failure maps email-already-in-use', () async {
      repository
        ..failSignUp = true
        ..failureCode = 'email-already-in-use';

      final ok = await container
          .read(authControllerProvider.notifier)
          .createAccount(name: 'Amal', email: 'amal@nawa.app', password: 'secret1');

      expect(ok, isFalse);
      expect(container.read(authControllerProvider).errorCode, AuthErrorCode.emailAlreadyInUse);
    });

    test('logout resets to logged out', () async {
      final notifier = container.read(authControllerProvider.notifier);
      await notifier.login(email: 'parent@nawa.app', password: 'secret1');
      await notifier.logout();

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.loggedOut);
      expect(state.user, isNull);
    });
  });
}
