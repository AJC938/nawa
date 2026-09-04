import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/features/experiences/domain/exploration_interaction.dart';
import 'package:nawa/features/experiences/domain/exploration_record.dart';
import 'package:nawa/features/interests/domain/interest_category.dart';
import 'package:nawa/features/interests/domain/interest_level.dart';
import 'package:nawa/features/interests/presentation/state/interest_profile_controller.dart';

void main() {
  group('InterestProfileController', () {
    test('starts as a valid empty/default profile: no selection, no evidence, lowest level', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final profile = container.read(interestProfileProvider);
      expect(profile.length, InterestCategoryType.values.length);
      for (final signal in profile.values) {
        expect(signal.score, 0);
        expect(signal.level, InterestLevel.emerging);
      }
    });

    test('recalculate gives a selected category a head start over an unselected one', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(interestProfileProvider.notifier).recalculate(
            selectedInterests: {InterestCategoryType.technology},
            explorations: const [],
          );

      final profile = container.read(interestProfileProvider);
      expect(profile[InterestCategoryType.technology]!.score, greaterThan(profile[InterestCategoryType.art]!.score));
    });

    test('recalculate reflects a completed exploration and moves the level up', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(interestProfileProvider.notifier);
      notifier.recalculate(selectedInterests: {InterestCategoryType.gaming}, explorations: const []);
      expect(container.read(interestProfileProvider)[InterestCategoryType.gaming]!.level, InterestLevel.exploring);

      final completedRecords = [
        ExplorationRecord(
          id: 'e1',
          experienceId: 'space-adventure',
          categoryId: 'gaming',
          startedAt: DateTime(2026),
          completedAt: DateTime(2026),
          durationSeconds: 600,
          completed: true,
          interactions: const [
            ExplorationInteraction(questionId: 'q1', selectedOptionId: 'right', order: 0),
            ExplorationInteraction(questionId: 'q2', selectedOptionId: 'catch', order: 1),
            ExplorationInteraction(questionId: 'q3', selectedOptionId: 'map', order: 2),
          ],
        ),
      ];
      notifier.recalculate(selectedInterests: {InterestCategoryType.gaming}, explorations: completedRecords);

      // score = 20 (selected) + 25 (1 completion) + 10 (600s = 2 time blocks) + 6 (3 interactions) = 61.
      final gaming = container.read(interestProfileProvider)[InterestCategoryType.gaming]!;
      expect(gaming.score, 61);
      expect(gaming.level, InterestLevel.strong);
      expect(gaming.completedExperienceIds, contains('space-adventure'));
    });

    test('recalculate always replaces the profile wholesale — same input always gives the same output', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(interestProfileProvider.notifier);

      final explorations = [
        ExplorationRecord(
          id: 'e1',
          experienceId: 'space-adventure',
          categoryId: 'gaming',
          startedAt: DateTime(2026),
          completed: true,
          durationSeconds: 60,
        ),
      ];

      notifier.recalculate(selectedInterests: {InterestCategoryType.gaming}, explorations: explorations);
      final first = container.read(interestProfileProvider)[InterestCategoryType.gaming]!.score;

      // Calling recalculate again with the exact same source data must not
      // change the result (it replaces, not accumulates).
      notifier.recalculate(selectedInterests: {InterestCategoryType.gaming}, explorations: explorations);
      final second = container.read(interestProfileProvider)[InterestCategoryType.gaming]!.score;

      expect(second, first);
    });
  });
}
