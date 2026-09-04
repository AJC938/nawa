import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/features/auth/data/auth_repository.dart';
import 'package:nawa/features/experiences/data/exploration_repository.dart';
import 'package:nawa/features/interests/domain/interest_category.dart';
import 'package:nawa/features/interests/presentation/state/interest_profile_controller.dart';
import 'package:nawa/features/onboarding/domain/onboarding_state.dart';
import 'package:nawa/features/onboarding/presentation/state/onboarding_controller.dart';
import 'package:nawa/features/profile/data/user_profile_repository.dart';
import 'package:nawa/features/profile/domain/child_profile_record.dart';
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
      ]);
    });

    tearDown(() => container.dispose());

    test('does nothing and reports success when onboarding was never completed', () async {
      final ok = await container.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();

      expect(ok, isTrue);
      expect(container.read(onboardingProvider).syncStatus, OnboardingSyncStatus.idle);
    });

    test('does not write an orphan profile when nobody is authenticated yet', () async {
      container.read(onboardingProvider.notifier)
        ..setName('Zayd')
        ..setAge(8)
        ..complete();

      final ok = await container.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();

      expect(ok, isFalse);
      expect(await profileRepository.getUserProfile('any-uid'), isNull);
    });

    test('writes the parent + child profile under the authenticated UID once signed in', () async {
      final user = await authRepository.signIn(email: 'parent@nawa.app', password: 'secret1');
      container.read(onboardingProvider.notifier)
        ..setName('Zayd')
        ..setAge(8)
        ..toggleInterest(InterestCategoryType.gaming)
        ..complete();

      final ok = await container.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();

      expect(ok, isTrue);
      expect(container.read(onboardingProvider).syncStatus, OnboardingSyncStatus.synced);

      final savedUser = await profileRepository.getUserProfile(user.uid);
      expect(savedUser?.email, 'parent@nawa.app');
      expect(savedUser?.role, 'parent');

      final savedChild = await profileRepository.getChildProfile(user.uid);
      expect(savedChild?.name, 'Zayd');
      expect(savedChild?.age, 8);

      final savedInterests = await profileRepository.getInterests(user.uid);
      expect(savedInterests, {InterestCategoryType.gaming});
    });

    test('does not write orphan interests when nobody is authenticated yet', () async {
      container.read(onboardingProvider.notifier)
        ..setName('Zayd')
        ..setAge(8)
        ..toggleInterest(InterestCategoryType.gaming)
        ..complete();

      await container.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();

      expect(await profileRepository.getInterests('any-uid'), isEmpty);
    });

    test('stores stable lowercase ids, not translated UI labels', () async {
      final user = await authRepository.signIn(email: 'parent@nawa.app', password: 'secret1');
      container.read(onboardingProvider.notifier)
        ..setName('Zayd')
        ..setAge(8)
        ..toggleInterest(InterestCategoryType.technology)
        ..complete();

      await container.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();

      final saved = await profileRepository.getInterests(user.uid);
      expect(saved, {InterestCategoryType.technology});
      expect(InterestCategoryType.technology.id, 'technology');
      expect(interestCategoryFromId('technology'), InterestCategoryType.technology);
      expect(interestCategoryFromId('not-a-real-id'), isNull);
    });

    test('does not write a second time once already synced (no duplicate writes)', () async {
      await authRepository.signIn(email: 'parent@nawa.app', password: 'secret1');
      container.read(onboardingProvider.notifier)
        ..setName('Zayd')
        ..setAge(8)
        ..complete();

      final notifier = container.read(onboardingProvider.notifier);
      await notifier.syncToFirestoreIfNeeded();
      final secondCallOk = await notifier.syncToFirestoreIfNeeded();

      expect(secondCallOk, isTrue);
      expect(container.read(onboardingProvider).syncStatus, OnboardingSyncStatus.synced);
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
    test('applies the saved name/age when a Firestore profile exists', () async {
      final profileRepository = FakeUserProfileRepository()
        ..seedChildProfile('uid-1', const ChildProfileRecord(name: 'Lina', age: 6));
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          explorationRepositoryProvider.overrideWithValue(FakeExplorationRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(childProfileProvider.notifier).restoreFromFirestore('uid-1');

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
      await container.read(childProfileProvider.notifier).restoreFromFirestore('uid-none');

      expect(container.read(childProfileProvider).name, before.name);
      expect(container.read(childProfileProvider).age, before.age);
    });

    test('restores saved interests and replaces the local mock defaults', () async {
      final profileRepository = FakeUserProfileRepository()
        ..seedChildProfile('uid-1', const ChildProfileRecord(name: 'Lina', age: 6))
        ..seedInterests('uid-1', {InterestCategoryType.art, InterestCategoryType.science});
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

      await container.read(childProfileProvider.notifier).restoreFromFirestore('uid-1');

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

      await container.read(childProfileProvider.notifier).restoreFromFirestore('uid-none');

      expect(container.read(childProfileProvider).interests, isEmpty);
    });

    test('re-seeds the interest scoring provider with the restored interests', () async {
      final profileRepository = FakeUserProfileRepository()
        ..seedInterests('uid-1', {InterestCategoryType.sports});
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
          explorationRepositoryProvider.overrideWithValue(FakeExplorationRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(childProfileProvider.notifier).restoreFromFirestore('uid-1');

      final signals = container.read(interestProfileProvider);
      expect(signals[InterestCategoryType.sports]!.score, greaterThan(signals[InterestCategoryType.gaming]!.score));
    });
  });
}
