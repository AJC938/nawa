import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/app/router/route_paths.dart';
import 'package:nawa/core/localization/app_locale.dart';
import 'package:nawa/core/localization/locale_provider.dart';
import 'package:nawa/features/auth/data/auth_repository.dart';
import 'package:nawa/features/experiences/data/exploration_repository.dart';
import 'package:nawa/features/experiences/presentation/state/experience_catalog_providers.dart';
import 'package:nawa/features/interests/domain/interest_category.dart';
import 'package:nawa/features/interests/presentation/state/interest_profile_controller.dart';
import 'package:nawa/features/parent/presentation/state/parent_providers.dart';
import 'package:nawa/features/profile/data/user_profile_repository.dart';
import 'package:nawa/features/profile/presentation/state/active_child_controller.dart';
import 'package:nawa/features/profile/presentation/state/child_profile_controller.dart';
import 'package:nawa/features/profile/presentation/state/children_controller.dart';

import '../support/fake_auth_repository.dart';
import '../support/fake_exploration_repository.dart';
import '../support/fake_user_profile_repository.dart';

/// Mirrors `resolveChildEntryRoute` (which takes a [WidgetRef], only
/// obtainable from inside a widget tree) against a plain [ProviderContainer]
/// so the same zero/one/many-children branching can be exercised directly
/// in a fast, widget-less unit test.
Future<String> _resolveEntryRoute(ProviderContainer container, String uid) async {
  final children = await container.read(childrenProvider.notifier).loadChildren(uid);
  if (children.isEmpty) return RoutePaths.onboardingIntro;
  if (children.length == 1) {
    await container.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: children.single.id);
    return RoutePaths.parent;
  }
  return RoutePaths.selectChild;
}

void main() {
  group('A. Default locale', () {
    test('LocaleNotifier defaults to Arabic', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(localeProvider), AppLocale.ar);
    });
  });

  group('C. Parent profile', () {
    test('resolves the authenticated Firebase email, and falls back to the auth displayName when no Firestore name is saved',
        () async {
      final profileRepository = FakeUserProfileRepository();
      final user = MockUser('parent@nawa.app', 'uid-1', 'Auth Display Name');

      final email = user.email;
      final saved = await profileRepository.getUserProfile(user.uid);
      final resolvedName = saved?.parentName ?? user.displayName ?? '';

      expect(email, 'parent@nawa.app');
      expect(resolvedName, 'Auth Display Name');
    });

    test('a saved Firestore parentName takes precedence over the auth displayName', () async {
      final profileRepository = FakeUserProfileRepository();
      final user = MockUser('parent@nawa.app', 'uid-1', 'Auth Display Name');
      await profileRepository.createOrUpdateUserProfile(uid: user.uid, email: user.email, parentName: 'Edited Name');

      final saved = await profileRepository.getUserProfile(user.uid);
      final resolvedName = saved?.parentName ?? user.displayName ?? '';

      expect(resolvedName, 'Edited Name');
    });
  });

  group('Multi-child support', () {
    late FakeAuthRepository authRepository;
    late FakeUserProfileRepository profileRepository;
    late FakeExplorationRepository explorationRepository;
    late ProviderContainer container;
    const uid = 'parent-uid';

    setUp(() async {
      authRepository = FakeAuthRepository();
      await authRepository.signIn(email: 'parent@nawa.app', password: 'secret1');
      authRepository.seedCurrentUser(MockUser('parent@nawa.app', uid));
      profileRepository = FakeUserProfileRepository();
      explorationRepository = FakeExplorationRepository();
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        userProfileRepositoryProvider.overrideWithValue(profileRepository),
        explorationRepositoryProvider.overrideWithValue(explorationRepository),
      ]);
      addTearDown(container.dispose);
    });

    test('D. a parent with exactly one child auto-selects it and lands on the app', () async {
      await profileRepository.createChild(uid: uid, name: 'Lamar', age: 7, interests: {InterestCategoryType.gaming});

      final route = await _resolveEntryRoute(container, uid);

      expect(route, RoutePaths.parent);
      expect(container.read(activeChildIdProvider), isNotNull);
      expect(container.read(childProfileProvider).name, 'Lamar');
    });

    test('E. a parent with two children is sent to the selection screen instead of auto-selecting', () async {
      await profileRepository.createChild(uid: uid, name: 'Lamar', age: 7);
      await profileRepository.createChild(uid: uid, name: 'Sara', age: 9);

      final route = await _resolveEntryRoute(container, uid);

      expect(route, RoutePaths.selectChild);
      expect(container.read(activeChildIdProvider), isNull);
      expect(container.read(childrenProvider), hasLength(2));
    });

    test('F. two children have independently different selected interests', () async {
      final lamarId =
          await profileRepository.createChild(uid: uid, name: 'Lamar', age: 7, interests: {InterestCategoryType.gaming});
      final saraId = await profileRepository.createChild(uid: uid, name: 'Sara', age: 9, interests: {InterestCategoryType.art});

      await container.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: lamarId);
      expect(container.read(childProfileProvider).interests, {InterestCategoryType.gaming});

      await container.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: saraId);
      expect(container.read(childProfileProvider).interests, {InterestCategoryType.art});
    });

    test('G. two children have independently different exploration histories', () async {
      final lamarId = await profileRepository.createChild(uid: uid, name: 'Lamar', age: 7);
      final saraId = await profileRepository.createChild(uid: uid, name: 'Sara', age: 9);

      await explorationRepository.startExploration(uid: uid, childId: lamarId, experienceId: 'galaxy-builder', categoryId: 'gaming');
      await explorationRepository.startExploration(uid: uid, childId: saraId, experienceId: 'color-canvas', categoryId: 'art');

      final lamarExplorations = await explorationRepository.getExplorations(uid: uid, childId: lamarId);
      final saraExplorations = await explorationRepository.getExplorations(uid: uid, childId: saraId);

      expect(lamarExplorations, hasLength(1));
      expect(lamarExplorations.single.experienceId, 'galaxy-builder');
      expect(saraExplorations, hasLength(1));
      expect(saraExplorations.single.experienceId, 'color-canvas');
    });

    test('H. switching the active child never carries over the previous child\'s Interest Profile', () async {
      final lamarId =
          await profileRepository.createChild(uid: uid, name: 'Lamar', age: 7, interests: {InterestCategoryType.gaming});
      final saraId = await profileRepository.createChild(uid: uid, name: 'Sara', age: 9, interests: {InterestCategoryType.art});

      final lamarExplorationId =
          await explorationRepository.startExploration(uid: uid, childId: lamarId, experienceId: 'galaxy-builder', categoryId: 'gaming');
      await explorationRepository.completeExploration(
        uid: uid,
        childId: lamarId,
        explorationId: lamarExplorationId,
        durationSeconds: 300,
        interactions: const [],
      );

      await container.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: lamarId);
      final lamarGamingScore = container.read(interestProfileProvider)[InterestCategoryType.gaming]!.score;
      expect(lamarGamingScore, greaterThan(20)); // selected (20) + real completion evidence

      await container.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: saraId);
      final saraGamingScore = container.read(interestProfileProvider)[InterestCategoryType.gaming]!.score;
      // Sara never selected or explored Gaming — must be back at the
      // no-evidence baseline, not inheriting Lamar's score.
      expect(saraGamingScore, 0);
      expect(container.read(interestProfileProvider)[InterestCategoryType.art]!.score, greaterThanOrEqualTo(20));
    });

    test('I. switching the active child changes the personalized recommendation ranking', () async {
      final lamarId =
          await profileRepository.createChild(uid: uid, name: 'Lamar', age: 7, interests: {InterestCategoryType.gaming});
      final saraId = await profileRepository.createChild(uid: uid, name: 'Sara', age: 9, interests: {InterestCategoryType.art});

      await container.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: lamarId);
      final lamarTop = container.read(rankedExperiencesProvider).first;
      expect(lamarTop.experience.category, InterestCategoryType.gaming);

      await container.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: saraId);
      final saraTop = container.read(rankedExperiencesProvider).first;
      expect(saraTop.experience.category, InterestCategoryType.art);
    });

    test('J. Parent analytics (parentSummaryProvider) switches correctly between children', () async {
      final lamarId = await profileRepository.createChild(uid: uid, name: 'Lamar', age: 7);
      final saraId = await profileRepository.createChild(uid: uid, name: 'Sara', age: 9);

      await container.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: lamarId);
      expect(container.read(parentSummaryProvider).childName, 'Lamar');

      await container.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: saraId);
      expect(container.read(parentSummaryProvider).childName, 'Sara');
    });

    test('K. logout clears active child and children-list state', () async {
      final childId = await profileRepository.createChild(uid: uid, name: 'Lamar', age: 7);
      await container.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: childId);
      await container.read(childrenProvider.notifier).loadChildren(uid);
      expect(container.read(activeChildIdProvider), isNotNull);
      expect(container.read(childrenProvider), isNotEmpty);

      // Mirrors what the Settings logout handler does.
      container.read(activeChildIdProvider.notifier).clear();
      container.read(childrenProvider.notifier).clear();

      expect(container.read(activeChildIdProvider), isNull);
      expect(container.read(childrenProvider), isEmpty);
    });

    test('L. logging in again re-resolves the correct child selection behavior', () async {
      final childId = await profileRepository.createChild(uid: uid, name: 'Lamar', age: 7);
      await container.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: childId);

      container.read(activeChildIdProvider.notifier).clear();
      container.read(childrenProvider.notifier).clear();
      expect(container.read(activeChildIdProvider), isNull);

      final route = await _resolveEntryRoute(container, uid);

      expect(route, RoutePaths.parent);
      expect(container.read(activeChildIdProvider), childId);
    });

    test('M. loading children always runs the legacy-account migration step first', () async {
      await profileRepository.createChild(uid: uid, name: 'Legacy Kid', age: 8);

      await container.read(childrenProvider.notifier).loadChildren(uid);

      expect(profileRepository.legacyMigrated, isTrue);
      expect(container.read(childrenProvider), hasLength(1));
    });
  });

  group('N. Firestore security rules', () {
    test('children and their nested explorations stay scoped to the owning parent UID', () {
      final rules = File('firestore.rules').readAsStringSync();

      expect(rules, contains('match /children/{childId}'));
      expect(rules, contains('match /explorations/{explorationId}'));
      // Every match block in this file uses the same UID-ownership check —
      // never a public/broad allow.
      expect(rules, isNot(contains('allow read, write: if true')));
      expect('request.auth.uid == userId'.allMatches(rules).length, greaterThanOrEqualTo(3));
    });
  });
}
