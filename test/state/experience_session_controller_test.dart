import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/features/auth/data/auth_repository.dart';
import 'package:nawa/features/experiences/data/exploration_repository.dart';
import 'package:nawa/features/experiences/domain/experience_session_state.dart';
import 'package:nawa/features/experiences/presentation/state/experience_session_controller.dart';
import 'package:nawa/features/interests/domain/interest_category.dart';
import 'package:nawa/features/interests/presentation/state/interest_profile_controller.dart';
import 'package:nawa/features/profile/presentation/state/active_child_controller.dart';
import 'package:nawa/features/profile/presentation/state/child_profile_controller.dart';

import '../support/fake_auth_repository.dart';
import '../support/fake_exploration_repository.dart';

const _childId = 'child-1';

/// Fixes the active child without the real [ActiveChildController.selectChild]
/// side effect (a Firestore restore) — these tests only care about the
/// exploration-session flow, not profile restoration.
class _FixedActiveChild extends ActiveChildController {
  _FixedActiveChild(this._id);
  final String? _id;
  @override
  String? build() => _id;
}

void main() {
  group('ExperienceSessionController', () {
    late FakeAuthRepository authRepository;
    late FakeExplorationRepository explorationRepository;
    late ProviderContainer container;

    ProviderContainer buildContainer({bool signedIn = true}) {
      authRepository = FakeAuthRepository();
      if (signedIn) authRepository.seedCurrentUser(MockUser('parent@nawa.app', 'uid-1'));
      explorationRepository = FakeExplorationRepository();
      final c = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        explorationRepositoryProvider.overrideWithValue(explorationRepository),
        if (signedIn) activeChildIdProvider.overrideWith(() => _FixedActiveChild(_childId)),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    setUp(() {
      container = buildContainer();
    });

    test('selecting the encouraged option gives positive feedback', () {
      final notifier = container.read(experienceSessionProvider.notifier);
      notifier.start('space-adventure');
      notifier.selectOption('right');

      expect(container.read(experienceSessionProvider).feedback, OptionFeedback.positive);
    });

    test('selecting the non-encouraged option gives a gentle try-again nudge, not a failure', () {
      final notifier = container.read(experienceSessionProvider.notifier);
      notifier.start('space-adventure');
      notifier.selectOption('left');

      final state = container.read(experienceSessionProvider);
      expect(state.feedback, OptionFeedback.tryAgain);
      expect(state.status, SessionStatus.inProgress);
    });

    test('continueToNext is a no-op until feedback is positive', () {
      final notifier = container.read(experienceSessionProvider.notifier);
      notifier.start('space-adventure');
      notifier.selectOption('left');
      notifier.continueToNext();

      expect(container.read(experienceSessionProvider).currentQuestionIndex, 0);
    });

    test('completing every question marks the session completed and updates interest + child state', () async {
      final childBefore = container.read(childProfileProvider).experiencesCompleted;
      final gamingBefore = container.read(interestProfileProvider)[InterestCategoryType.gaming]!.score;

      final notifier = container.read(experienceSessionProvider.notifier);
      notifier.start('space-adventure');
      await Future<void>.delayed(Duration.zero);

      const answers = ['right', 'catch', 'map'];
      for (final optionId in answers) {
        notifier.selectOption(optionId);
        notifier.continueToNext();
      }
      await Future<void>.delayed(Duration.zero);

      final session = container.read(experienceSessionProvider);
      expect(session.status, SessionStatus.completed);

      final gamingAfter = container.read(interestProfileProvider)[InterestCategoryType.gaming]!.score;
      expect(gamingAfter, greaterThan(gamingBefore));
      expect(
        container.read(interestProfileProvider)[InterestCategoryType.gaming]!.completedExperienceIds,
        contains('space-adventure'),
      );
      expect(container.read(childProfileProvider).experiencesCompleted, childBefore + 1);
    });

    test('replaying the same experience is real additional evidence and increases the score further', () async {
      // Unlike the old mock (which deduplicated by experienceId), the real
      // scoring engine treats each persisted exploration record as genuine
      // evidence — a second real playthrough is a second completed record,
      // and stacks completion points, matching the deterministic formula.
      Future<void> completeSpaceAdventure() async {
        final notifier = container.read(experienceSessionProvider.notifier);
        notifier.start('space-adventure');
        await Future<void>.delayed(Duration.zero);
        for (final optionId in ['right', 'catch', 'map']) {
          notifier.selectOption(optionId);
          notifier.continueToNext();
        }
        await Future<void>.delayed(Duration.zero);
      }

      await completeSpaceAdventure();
      final scoreAfterFirst = container.read(interestProfileProvider)[InterestCategoryType.gaming]!.score;
      await completeSpaceAdventure();
      final scoreAfterSecond = container.read(interestProfileProvider)[InterestCategoryType.gaming]!.score;

      expect(scoreAfterSecond, greaterThan(scoreAfterFirst));
    });

    group('Firestore exploration persistence', () {
      test('starting an experience creates exactly one exploration record with the right data', () async {
        final notifier = container.read(experienceSessionProvider.notifier);
        notifier.start('space-adventure');
        await Future<void>.delayed(Duration.zero);

        expect(explorationRepository.startCallCount, 1);
        final state = container.read(experienceSessionProvider);
        expect(state.explorationId, isNotNull);
        expect(state.explorationStatus, ExplorationStatus.inProgress);

        final records = await explorationRepository.getExplorations(uid: 'uid-1', childId: _childId);
        expect(records, hasLength(1));
        expect(records.first.experienceId, 'space-adventure');
        expect(records.first.categoryId, 'gaming');
        expect(records.first.completed, isFalse);
      });

      test('the exploration id is retained across question answers', () async {
        final notifier = container.read(experienceSessionProvider.notifier);
        notifier.start('space-adventure');
        await Future<void>.delayed(Duration.zero);
        final id = container.read(experienceSessionProvider).explorationId;

        notifier.selectOption('right');
        notifier.continueToNext();

        expect(container.read(experienceSessionProvider).explorationId, id);
      });

      test('interaction data accumulates in answer order as questions are answered', () async {
        final notifier = container.read(experienceSessionProvider.notifier);
        notifier.start('space-adventure');
        await Future<void>.delayed(Duration.zero);

        notifier.selectOption('right');
        notifier.continueToNext();
        var interactions = container.read(experienceSessionProvider).interactions;
        expect(interactions, hasLength(1));
        expect(interactions.first.questionId, 'q1');
        expect(interactions.first.selectedOptionId, 'right');
        expect(interactions.first.order, 0);

        notifier.selectOption('catch');
        notifier.continueToNext();
        interactions = container.read(experienceSessionProvider).interactions;
        expect(interactions, hasLength(2));
        expect(interactions[1].order, 1);
      });

      test('completion updates the SAME exploration record with duration and interactions, not a new one', () async {
        final notifier = container.read(experienceSessionProvider.notifier);
        notifier.start('space-adventure');
        await Future<void>.delayed(Duration.zero);
        final startedId = container.read(experienceSessionProvider).explorationId;

        for (final optionId in ['right', 'catch', 'map']) {
          notifier.selectOption(optionId);
          notifier.continueToNext();
        }
        await Future<void>.delayed(Duration.zero);

        expect(explorationRepository.startCallCount, 1);
        final records = await explorationRepository.getExplorations(uid: 'uid-1', childId: _childId);
        expect(records, hasLength(1));
        final record = records.single;
        expect(record.id, startedId);
        expect(record.completed, isTrue);
        expect(record.completedAt, isNotNull);
        expect(record.durationSeconds, greaterThanOrEqualTo(0));
        expect(record.interactions, hasLength(3));
        expect(record.interactions.map((i) => i.selectedOptionId).toList(), ['right', 'catch', 'map']);
        expect(container.read(experienceSessionProvider).explorationStatus, ExplorationStatus.completed);
      });

      test('a logged-out session never writes an exploration record', () async {
        final loggedOutContainer = buildContainer(signedIn: false);
        final notifier = loggedOutContainer.read(experienceSessionProvider.notifier);

        notifier.start('space-adventure');
        await Future<void>.delayed(Duration.zero);

        expect(loggedOutContainer.read(experienceSessionProvider).explorationStatus, ExplorationStatus.error);
        expect(loggedOutContainer.read(experienceSessionProvider).explorationId, isNull);
        // Local session flow still works even though nothing was persisted.
        expect(loggedOutContainer.read(experienceSessionProvider).experience?.id, 'space-adventure');
      });

      test('a start failure is surfaced as an error status, not a silently-successful start', () async {
        explorationRepository.failStart = true;
        final notifier = container.read(experienceSessionProvider.notifier);

        notifier.start('space-adventure');
        await Future<void>.delayed(Duration.zero);

        final state = container.read(experienceSessionProvider);
        expect(state.explorationStatus, ExplorationStatus.error);
        expect(state.explorationId, isNull);
      });

      test('retrying a failed completion succeeds without creating a duplicate record', () async {
        final notifier = container.read(experienceSessionProvider.notifier);
        notifier.start('space-adventure');
        await Future<void>.delayed(Duration.zero);

        explorationRepository.failComplete = true;
        for (final optionId in ['right', 'catch', 'map']) {
          notifier.selectOption(optionId);
          notifier.continueToNext();
        }
        await Future<void>.delayed(Duration.zero);
        expect(container.read(experienceSessionProvider).explorationStatus, ExplorationStatus.error);

        explorationRepository.failComplete = false;
        await notifier.retryCompleteExploration();

        expect(container.read(experienceSessionProvider).explorationStatus, ExplorationStatus.completed);
        expect(explorationRepository.startCallCount, 1);
        final records = await explorationRepository.getExplorations(uid: 'uid-1', childId: _childId);
        expect(records, hasLength(1));
        expect(records.single.completed, isTrue);
      });

      test('starting the same experience twice in a row (duplicate lifecycle call) does not create two records', () async {
        final notifier = container.read(experienceSessionProvider.notifier);
        notifier.start('space-adventure');
        notifier.start('space-adventure');
        await Future<void>.delayed(Duration.zero);

        expect(explorationRepository.startCallCount, 1);
      });
    });
  });

  group('ExplorationRepository read/restore', () {
    test('getCompletedExperiences only returns completed records', () async {
      final repository = FakeExplorationRepository();
      final startedId =
          await repository.startExploration(uid: 'uid-1', childId: 'child-1', experienceId: 'exp-a', categoryId: 'gaming');
      await repository.startExploration(uid: 'uid-1', childId: 'child-1', experienceId: 'exp-b', categoryId: 'sports');
      await repository.completeExploration(
        uid: 'uid-1',
        childId: 'child-1',
        explorationId: startedId,
        durationSeconds: 42,
        interactions: const [],
      );

      final all = await repository.getExplorations(uid: 'uid-1', childId: 'child-1');
      final completed = await repository.getCompletedExperiences(uid: 'uid-1', childId: 'child-1');

      expect(all, hasLength(2));
      expect(completed, hasLength(1));
      expect(completed.single.experienceId, 'exp-a');
      expect(completed.single.durationSeconds, 42);
    });

    test('a different uid never sees another user\'s exploration records', () async {
      final repository = FakeExplorationRepository();
      await repository.startExploration(uid: 'uid-a', childId: 'child-1', experienceId: 'exp-a', categoryId: 'gaming');
      await repository.startExploration(uid: 'uid-b', childId: 'child-1', experienceId: 'exp-b', categoryId: 'sports');

      final forA = await repository.getExplorations(uid: 'uid-a', childId: 'child-1');
      final forB = await repository.getExplorations(uid: 'uid-b', childId: 'child-1');

      expect(forA, hasLength(1));
      expect(forA.single.experienceId, 'exp-a');
      expect(forB, hasLength(1));
      expect(forB.single.experienceId, 'exp-b');
    });

    test('siblings under the SAME parent uid never see each other\'s exploration records', () async {
      final repository = FakeExplorationRepository();
      await repository.startExploration(uid: 'uid-1', childId: 'lamar', experienceId: 'exp-gaming', categoryId: 'gaming');
      await repository.startExploration(uid: 'uid-1', childId: 'sara', experienceId: 'exp-art', categoryId: 'art');

      final lamar = await repository.getExplorations(uid: 'uid-1', childId: 'lamar');
      final sara = await repository.getExplorations(uid: 'uid-1', childId: 'sara');

      expect(lamar, hasLength(1));
      expect(lamar.single.experienceId, 'exp-gaming');
      expect(sara, hasLength(1));
      expect(sara.single.experienceId, 'exp-art');
    });
  });
}
