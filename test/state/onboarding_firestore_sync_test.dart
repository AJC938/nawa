import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/features/auth/data/auth_repository.dart';
import 'package:nawa/features/experiences/data/exploration_repository.dart';
import 'package:nawa/features/interests/domain/interest_category.dart';
import 'package:nawa/features/interests/presentation/state/interest_profile_controller.dart';
import 'package:nawa/features/onboarding/domain/onboarding_state.dart';
import 'package:nawa/features/onboarding/presentation/state/onboarding_controller.dart';
import 'package:nawa/features/profile/data/user_profile_repository.dart';
import 'package:nawa/features/profile/domain/child_summary.dart';
import 'package:nawa/features/profile/presentation/state/active_child_controller.dart';
import 'package:nawa/features/profile/presentation/state/child_profile_controller.dart';

import '../support/fake_auth_repository.dart';
import '../support/fake_exploration_repository.dart';
import '../support/fake_user_profile_repository.dart';

void main() {
  group('OnboardingController.syncToFirestoreIfNeeded', () {
    late FakeAuthRepository authRepository;
    late FakeUserProfileRepository profileRepository;
    late ProviderContainer container;

    setUp(() {
      authRepository = FakeAuthRepository();
      profileRepository = FakeUserProfileRepository();
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        userProfileRepositoryProvider.overrideWithValue(profileRepository),
        explorationRepositoryProvider.overrideWithValue(FakeExplorationRepository()),
      ]);
    });

    tearDown(() => container.dispose());

    test('does nothing and reports success when onboarding was never completed', () async {
      final ok = await container.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();

      expect(ok, isTrue);
      expect(container.read(onboardingProvider).syncStatus, OnboardingSyncStatus.idle);
    });

    test('does not write an orphan child when nobody is authenticated yet', () async {
      container.read(onboardingProvider.notifier)
        ..setName('Zayd')
        ..setAge(8)
        ..complete();

      final ok = await container.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();

      expect(ok, isFalse);
      expect(await profileRepository.getUserProfile('any-uid'), isNull);
    });

    test('creates the parent profile and a new child under the authenticated UID once signed in', () async {
      final user = await authRepository.signIn(email: 'parent@nawa.app', password: 'secret1');
      container.read(onboardingProvider.notifier)
        ..setName('Zayd')
        ..setAge(8)
        ..toggleInterest(InterestCategoryType.gaming)
        ..complete();

      final ok = await container.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();

      expect(ok, isTrue);
      // Fully resets after a successful sync (not left at "synced") so a
      // later, unrelated login in the same app session never misreads this
      // run's completed/synced flags as its own pending onboarding.
      expect(container.read(onboardingProvider).completed, isFalse);
      expect(container.read(onboardingProvider).syncStatus, OnboardingSyncStatus.idle);

      final savedUser = await profileRepository.getUserProfile(user.uid);
      expect(savedUser?.email, 'parent@nawa.app');
      expect(savedUser?.role, 'parent');

      final children = await profileRepository.getChildren(user.uid);
      expect(children, hasLength(1));
      expect(children.single.name, 'Zayd');
      expect(children.single.age, 8);
      expect(children.single.interests, {InterestCategoryType.gaming});

      // The new child becomes active immediately.
      expect(container.read(activeChildIdProvider), children.single.id);
    });

    test('stores stable lowercase ids, not translated UI labels', () async {
      final user = await authRepository.signIn(email: 'parent@nawa.app', password: 'secret1');
      container.read(onboardingProvider.notifier)
        ..setName('Zayd')
        ..setAge(8)
        ..toggleInterest(InterestCategoryType.technology)
        ..complete();

      await container.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();

      final children = await profileRepository.getChildren(user.uid);
      expect(children.single.interests, {InterestCategoryType.technology});
      expect(InterestCategoryType.technology.id, 'technology');
      expect(interestCategoryFromId('technology'), InterestCategoryType.technology);
      expect(interestCategoryFromId('not-a-real-id'), isNull);
    });

    test('does not write a second time once already synced (no duplicate writes)', () async {
      final user = await authRepository.signIn(email: 'parent@nawa.app', password: 'secret1');
      container.read(onboardingProvider.notifier)
        ..setName('Zayd')
        ..setAge(8)
        ..complete();

      final notifier = container.read(onboardingProvider.notifier);
      await notifier.syncToFirestoreIfNeeded();
      // The state resets to fresh/idle immediately after a successful sync,
      // so a second call sees "nothing pending" and correctly no-ops —
      // exactly what stops a stale completed flag from re-syncing (or,
      // worse, misleading a later unrelated login) rather than truly
      // re-detecting "already synced".
      final secondCallOk = await notifier.syncToFirestoreIfNeeded();

      expect(secondCallOk, isTrue);
      // Still exactly one child — the second call was a genuine no-op, not
      // a second createChild.
      expect(await profileRepository.getChildren(user.uid), hasLength(1));
    });

    test('reports failure and sets an error status when the Firestore write throws', () async {
      profileRepository.failWrites = true;
      await authRepository.signIn(email: 'parent@nawa.app', password: 'secret1');
      container.read(onboardingProvider.notifier)
        ..setName('Zayd')
        ..setAge(8)
        ..complete();

      final ok = await container.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();

      expect(ok, isFalse);
      expect(container.read(onboardingProvider).syncStatus, OnboardingSyncStatus.error);
    });
  });

  group('ChildProfileController.restoreFromFirestore', () {
    test('applies the saved name/age when a Firestore child profile exists', () async {
      final profileRepository = FakeUserProfileRepository()
        ..seedChild('uid-1', const ChildSummary(id: 'child-1', name: 'Lina', age: 6));
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          explorationRepositoryProvider.overrideWithValue(FakeExplorationRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(childProfileProvider.notifier).restoreFromFirestore(uid: 'uid-1', childId: 'child-1');

      final child = container.read(childProfileProvider);
      expect(child.name, 'Lina');
      expect(child.age, 6);
    });

    test('leaves the local default name/age untouched when nothing is saved yet', () async {
      final profileRepository = FakeUserProfileRepository();
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          explorationRepositoryProvider.overrideWithValue(FakeExplorationRepository()),
        ],
      );
      addTearDown(container.dispose);

      final before = container.read(childProfileProvider);
      await container.read(childProfileProvider.notifier).restoreFromFirestore(uid: 'uid-none', childId: 'child-none');

      expect(container.read(childProfileProvider).name, before.name);
      expect(container.read(childProfileProvider).age, before.age);
    });

    test('restores saved interests and replaces the local mock defaults', () async {
      final profileRepository = FakeUserProfileRepository()
        ..seedChild(
          'uid-1',
          const ChildSummary(id: 'child-1', name: 'Lina', age: 6, interests: {InterestCategoryType.art, InterestCategoryType.science}),
        );
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          explorationRepositoryProvider.overrideWithValue(FakeExplorationRepository()),
        ],
      );
      addTearDown(container.dispose);

      // Sanity check: the mock default (seeded by ChildProfileController.build())
      // does NOT already contain art/science, so this proves a real overwrite.
      expect(container.read(childProfileProvider).interests, isNot(contains(InterestCategoryType.art)));

      await container.read(childProfileProvider.notifier).restoreFromFirestore(uid: 'uid-1', childId: 'child-1');

      expect(container.read(childProfileProvider).interests, {InterestCategoryType.art, InterestCategoryType.science});
    });

    test('clears interests to empty when nothing is saved, rather than keeping stale mock defaults', () async {
      final profileRepository = FakeUserProfileRepository();
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          explorationRepositoryProvider.overrideWithValue(FakeExplorationRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(childProfileProvider.notifier).restoreFromFirestore(uid: 'uid-none', childId: 'child-none');

      expect(container.read(childProfileProvider).interests, isEmpty);
    });

    test('re-seeds the interest scoring provider with the restored interests', () async {
      final profileRepository = FakeUserProfileRepository()
        ..seedChild('uid-1', const ChildSummary(id: 'child-1', name: 'Kid', age: 9, interests: {InterestCategoryType.sports}));
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          explorationRepositoryProvider.overrideWithValue(FakeExplorationRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(childProfileProvider.notifier).restoreFromFirestore(uid: 'uid-1', childId: 'child-1');

      final signals = container.read(interestProfileProvider);
      expect(signals[InterestCategoryType.sports]!.score, greaterThan(signals[InterestCategoryType.gaming]!.score));
    });
  });
}
