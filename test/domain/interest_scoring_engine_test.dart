import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/features/experiences/domain/exploration_interaction.dart';
import 'package:nawa/features/experiences/domain/exploration_record.dart';
import 'package:nawa/features/interests/domain/interest_category.dart';
import 'package:nawa/features/interests/domain/interest_level.dart';
import 'package:nawa/features/interests/domain/interest_scoring_engine.dart';

ExplorationRecord _record({
  required String id,
  required String experienceId,
  required String categoryId,
  bool completed = true,
  int durationSeconds = 0,
  List<ExplorationInteraction> interactions = const [],
}) {
  return ExplorationRecord(
    id: id,
    experienceId: experienceId,
    categoryId: categoryId,
    startedAt: DateTime(2026, 1, 1),
    completedAt: completed ? DateTime(2026, 1, 1) : null,
    durationSeconds: durationSeconds,
    completed: completed,
    interactions: interactions,
  );
}

void main() {
  group('InterestScoringEngine', () {
    test('1. no interests + no explorations -> every category is 0, lowest level, no crash', () {
      final profile = InterestScoringEngine.calculate(selectedInterests: const {}, explorations: const []);

      expect(profile.length, InterestCategoryType.values.length);
      for (final signal in profile.values) {
        expect(signal.score, 0);
        expect(signal.level, InterestLevel.emerging);
        expect(signal.completedExperienceIds, isEmpty);
      }
    });

    test('2. a selected interest with no explorations scores the baseline and lands in Exploring', () {
      final profile = InterestScoringEngine.calculate(
        selectedInterests: {InterestCategoryType.gaming},
        explorations: const [],
      );

      expect(profile[InterestCategoryType.gaming]!.score, 20);
      expect(profile[InterestCategoryType.gaming]!.level, InterestLevel.exploring);
      expect(profile[InterestCategoryType.sports]!.score, 0);
    });

    test('3. one completed experience adds the completion points', () {
      final profile = InterestScoringEngine.calculate(
        selectedInterests: {InterestCategoryType.gaming},
        explorations: [_record(id: 'e1', experienceId: 'exp-a', categoryId: 'gaming')],
      );

      // 20 (selected) + 25 (1 completion) = 45.
      expect(profile[InterestCategoryType.gaming]!.score, 45);
      expect(profile[InterestCategoryType.gaming]!.completedExperienceIds, ['exp-a']);
    });

    test('4. multiple completed experiences stack completion points', () {
      final profile = InterestScoringEngine.calculate(
        selectedInterests: {InterestCategoryType.gaming},
        explorations: [
          _record(id: 'e1', experienceId: 'exp-a', categoryId: 'gaming'),
          _record(id: 'e2', experienceId: 'exp-b', categoryId: 'gaming'),
        ],
      );

      // 20 (selected) + 25*2 (2 completions) = 70.
      expect(profile[InterestCategoryType.gaming]!.score, 70);
      expect(profile[InterestCategoryType.gaming]!.completedExperienceIds, ['exp-a', 'exp-b']);
    });

    test('5. an incomplete (started-but-not-finished) experience adds fewer points than a completion', () {
      final profile = InterestScoringEngine.calculate(
        selectedInterests: const {},
        explorations: [_record(id: 'e1', experienceId: 'exp-a', categoryId: 'gaming', completed: false)],
      );

      expect(profile[InterestCategoryType.gaming]!.score, 5);
      expect(profile[InterestCategoryType.gaming]!.completedExperienceIds, isEmpty);
    });

    test('6. exploration duration contributes time points at 5 points per 5 minutes', () {
      final profile = InterestScoringEngine.calculate(
        selectedInterests: const {},
        explorations: [_record(id: 'e1', experienceId: 'exp-a', categoryId: 'gaming', completed: false, durationSeconds: 600)],
      );

      // 5 (incomplete) + 10 (600s = 2 blocks of 5 minutes * 5 points) = 15.
      expect(profile[InterestCategoryType.gaming]!.score, 15);
    });

    test('7. recorded interactions contribute 2 points each', () {
      final profile = InterestScoringEngine.calculate(
        selectedInterests: const {},
        explorations: [
          _record(
            id: 'e1',
            experienceId: 'exp-a',
            categoryId: 'gaming',
            completed: false,
            interactions: const [
              ExplorationInteraction(questionId: 'q1', selectedOptionId: 'a', order: 0),
              ExplorationInteraction(questionId: 'q2', selectedOptionId: 'a', order: 1),
              ExplorationInteraction(questionId: 'q3', selectedOptionId: 'a', order: 2),
            ],
          ),
        ],
      );

      // 5 (incomplete) + 6 (3 interactions * 2 points) = 11.
      expect(profile[InterestCategoryType.gaming]!.score, 11);
    });

    test('8. category isolation: exploration data in one category never affects another', () {
      final profile = InterestScoringEngine.calculate(
        selectedInterests: {InterestCategoryType.gaming},
        explorations: [
          _record(id: 'e1', experienceId: 'exp-a', categoryId: 'gaming'),
          _record(id: 'e2', experienceId: 'exp-b', categoryId: 'sports', durationSeconds: 900),
        ],
      );

      expect(profile[InterestCategoryType.gaming]!.score, 45);
      expect(profile[InterestCategoryType.sports]!.score, 40); // 25 completion + 15 time (900s = 3 blocks), not selected so no baseline.
      expect(profile[InterestCategoryType.art]!.score, 0);
    });

    test('9. the score is capped at 100 even with overwhelming evidence', () {
      final profile = InterestScoringEngine.calculate(
        selectedInterests: {InterestCategoryType.gaming},
        explorations: List.generate(
          10,
          (i) => _record(id: 'e$i', experienceId: 'exp-$i', categoryId: 'gaming', durationSeconds: 3600),
        ),
      );

      expect(profile[InterestCategoryType.gaming]!.score, 100);
    });

    test('10. threshold boundaries map to the correct level', () {
      expect(interestLevelForScore(0), InterestLevel.emerging);
      expect(interestLevelForScore(19), InterestLevel.emerging);
      expect(interestLevelForScore(20), InterestLevel.exploring);
      expect(interestLevelForScore(49), InterestLevel.exploring);
      expect(interestLevelForScore(50), InterestLevel.strong);
      expect(interestLevelForScore(74), InterestLevel.strong);
      expect(interestLevelForScore(75), InterestLevel.veryStrong);
      expect(interestLevelForScore(100), InterestLevel.veryStrong);
    });

    test('11. same input always produces the same output (deterministic)', () {
      final explorations = [
        _record(id: 'e1', experienceId: 'exp-a', categoryId: 'gaming', durationSeconds: 400, interactions: const [
          ExplorationInteraction(questionId: 'q1', selectedOptionId: 'a', order: 0),
        ]),
      ];

      final first = InterestScoringEngine.calculate(selectedInterests: {InterestCategoryType.gaming}, explorations: explorations);
      final second = InterestScoringEngine.calculate(selectedInterests: {InterestCategoryType.gaming}, explorations: explorations);

      expect(first[InterestCategoryType.gaming]!.score, second[InterestCategoryType.gaming]!.score);
    });

    test('12. a selected interest with exploration activity in an unrelated category stays at baseline', () {
      final profile = InterestScoringEngine.calculate(
        selectedInterests: {InterestCategoryType.gaming},
        explorations: [_record(id: 'e1', experienceId: 'exp-a', categoryId: 'sports', durationSeconds: 1200)],
      );

      expect(profile[InterestCategoryType.gaming]!.score, 20); // untouched by sports activity.
      expect(profile[InterestCategoryType.sports]!.score, 45); // 25 completion + 20 time (capped from 1200s=4 blocks=20pts).
    });

    test('13. multiple categories are scored independently in one calculation', () {
      final profile = InterestScoringEngine.calculate(
        selectedInterests: {InterestCategoryType.gaming, InterestCategoryType.art},
        explorations: [
          _record(id: 'e1', experienceId: 'exp-a', categoryId: 'gaming'),
          _record(id: 'e2', experienceId: 'exp-b', categoryId: 'technology', completed: false),
        ],
      );

      expect(profile[InterestCategoryType.gaming]!.score, 45);
      expect(profile[InterestCategoryType.art]!.score, 20);
      expect(profile[InterestCategoryType.technology]!.score, 5);
      expect(profile[InterestCategoryType.science]!.score, 0);
    });

    test('14. a very long exploration duration does not exceed the time-points cap', () {
      final profile = InterestScoringEngine.calculate(
        selectedInterests: const {},
        explorations: [_record(id: 'e1', experienceId: 'exp-a', categoryId: 'gaming', completed: false, durationSeconds: 999999)],
      );

      // 5 (incomplete) + 20 (time cap, not e.g. 1666 points) = 25.
      expect(profile[InterestCategoryType.gaming]!.score, 25);
    });

    test('15. excessive interactions do not exceed the interaction-points cap', () {
      final manyInteractions = List.generate(
        50,
        (i) => ExplorationInteraction(questionId: 'q$i', selectedOptionId: 'a', order: i),
      );
      final profile = InterestScoringEngine.calculate(
        selectedInterests: const {},
        explorations: [_record(id: 'e1', experienceId: 'exp-a', categoryId: 'gaming', completed: false, interactions: manyInteractions)],
      );

      // 5 (incomplete) + 20 (interaction cap, not 100 points) = 25.
      expect(profile[InterestCategoryType.gaming]!.score, 25);
    });
  });
}
