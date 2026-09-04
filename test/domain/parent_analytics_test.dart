import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/features/experiences/domain/exploration_interaction.dart';
import 'package:nawa/features/experiences/domain/exploration_record.dart';
import 'package:nawa/features/interests/domain/interest_category.dart';
import 'package:nawa/features/interests/domain/interest_score_breakdown.dart';
import 'package:nawa/features/interests/domain/interest_signal.dart';
import 'package:nawa/features/parent/domain/parent_analytics.dart';

// A Thursday, well inside its own Mon-Sun week — safe to offset by whole
// days within [-3, +3] and stay in the same calendar week.
final _thisWeekThursday = DateTime(2026, 1, 8, 10);

ExplorationRecord _record({
  required String id,
  required String categoryId,
  required DateTime startedAt,
  DateTime? completedAt,
  bool completed = true,
  int durationSeconds = 0,
}) {
  return ExplorationRecord(
    id: id,
    experienceId: 'exp-$id',
    categoryId: categoryId,
    startedAt: startedAt,
    completedAt: completedAt,
    completed: completed,
    durationSeconds: durationSeconds,
    interactions: const [ExplorationInteraction(questionId: 'q1', selectedOptionId: 'a', order: 0)],
  );
}

Map<InterestCategoryType, InterestSignal> _profile(Map<InterestCategoryType, double> scores) {
  return {
    for (final category in InterestCategoryType.values)
      category: InterestSignal(category: category, score: scores[category] ?? 0, breakdown: const InterestScoreBreakdown()),
  };
}

void main() {
  group('ParentAnalyticsCalculator', () {
    test('1. no explorations produces a zeroed, valid analytics', () {
      final analytics = ParentAnalyticsCalculator.calculate(
        explorations: const [],
        interestProfile: _profile(const {}),
        now: _thisWeekThursday,
      );

      expect(analytics.totalExperiencesCompleted, 0);
      expect(analytics.totalDurationSeconds, 0);
      expect(analytics.thisWeekExperiencesCompleted, 0);
      expect(analytics.thisWeekDurationSeconds, 0);
    });

    test('2. completed experience count only counts completed records', () {
      final explorations = [
        _record(id: 'a', categoryId: 'gaming', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday),
        _record(id: 'b', categoryId: 'gaming', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday),
      ];

      final analytics = ParentAnalyticsCalculator.calculate(
        explorations: explorations,
        interestProfile: _profile(const {}),
        now: _thisWeekThursday,
      );

      expect(analytics.totalExperiencesCompleted, 2);
    });

    test('3. an incomplete (started-but-not-finished) experience is excluded from the completed count', () {
      final explorations = [
        _record(id: 'done', categoryId: 'gaming', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday),
        _record(id: 'inProgress', categoryId: 'gaming', startedAt: _thisWeekThursday, completed: false),
      ];

      final analytics = ParentAnalyticsCalculator.calculate(
        explorations: explorations,
        interestProfile: _profile(const {}),
        now: _thisWeekThursday,
      );

      expect(analytics.totalExperiencesCompleted, 1);
    });

    test('4. total duration sums completed exploration durations only', () {
      final explorations = [
        _record(id: 'a', categoryId: 'gaming', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday, durationSeconds: 300),
        _record(id: 'b', categoryId: 'art', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday, durationSeconds: 120),
        _record(id: 'incomplete', categoryId: 'art', startedAt: _thisWeekThursday, completed: false, durationSeconds: 999),
      ];

      final analytics = ParentAnalyticsCalculator.calculate(
        explorations: explorations,
        interestProfile: _profile(const {}),
        now: _thisWeekThursday,
      );

      expect(analytics.totalDurationSeconds, 420);
    });

    test('5. weekly duration only sums explorations completed within the current week', () {
      final lastWeek = _thisWeekThursday.subtract(const Duration(days: 10));
      final explorations = [
        _record(id: 'thisWeek', categoryId: 'gaming', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday, durationSeconds: 300),
        _record(id: 'lastWeek', categoryId: 'gaming', startedAt: lastWeek, completedAt: lastWeek, durationSeconds: 600),
      ];

      final analytics = ParentAnalyticsCalculator.calculate(
        explorations: explorations,
        interestProfile: _profile(const {}),
        now: _thisWeekThursday,
      );

      expect(analytics.thisWeekDurationSeconds, 300);
      expect(analytics.totalDurationSeconds, 900);
    });

    test('6. weekly completed count only counts this week\'s completions', () {
      final lastWeek = _thisWeekThursday.subtract(const Duration(days: 10));
      final explorations = [
        _record(id: 'thisWeek1', categoryId: 'gaming', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday),
        _record(id: 'thisWeek2', categoryId: 'art', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday),
        _record(id: 'lastWeek', categoryId: 'gaming', startedAt: lastWeek, completedAt: lastWeek),
      ];

      final analytics = ParentAnalyticsCalculator.calculate(
        explorations: explorations,
        interestProfile: _profile(const {}),
        now: _thisWeekThursday,
      );

      expect(analytics.thisWeekExperiencesCompleted, 2);
      expect(analytics.totalExperiencesCompleted, 3);
    });

    test('7. an exploration outside the current week is excluded from weekly metrics but counted in totals', () {
      final nextWeek = _thisWeekThursday.add(const Duration(days: 10));
      final explorations = [
        _record(id: 'future', categoryId: 'gaming', startedAt: nextWeek, completedAt: nextWeek, durationSeconds: 60),
      ];

      final analytics = ParentAnalyticsCalculator.calculate(
        explorations: explorations,
        interestProfile: _profile(const {}),
        now: _thisWeekThursday,
      );

      expect(analytics.thisWeekExperiencesCompleted, 0);
      expect(analytics.thisWeekDurationSeconds, 0);
      expect(analytics.totalExperiencesCompleted, 1);
      expect(analytics.totalDurationSeconds, 60);
    });

    test('8. top interests are sorted by real score, strongest first', () {
      final analytics = ParentAnalyticsCalculator.calculate(
        explorations: const [],
        interestProfile: _profile({
          InterestCategoryType.gaming: 40,
          InterestCategoryType.art: 90,
          InterestCategoryType.sports: 10,
        }),
        now: _thisWeekThursday,
      );

      expect(analytics.topInterests.first.category, InterestCategoryType.art);
      final scores = analytics.topInterests.map((s) => s.score).toList();
      expect(scores, [90, 40, 10, 0, 0]);
    });

    test('9. multiple categories are aggregated independently in one calculation', () {
      final explorations = [
        _record(id: 'g1', categoryId: 'gaming', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday, durationSeconds: 100),
        _record(id: 'a1', categoryId: 'art', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday, durationSeconds: 200),
      ];

      final analytics = ParentAnalyticsCalculator.calculate(
        explorations: explorations,
        interestProfile: _profile({InterestCategoryType.gaming: 70, InterestCategoryType.art: 30}),
        now: _thisWeekThursday,
      );

      expect(analytics.totalExperiencesCompleted, 2);
      expect(analytics.totalDurationSeconds, 300);
      expect(analytics.topInterests.first.category, InterestCategoryType.gaming);
    });

    test('10. a zero-duration completed exploration is handled without affecting the count', () {
      final explorations = [
        _record(id: 'zero', categoryId: 'gaming', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday, durationSeconds: 0),
      ];

      final analytics = ParentAnalyticsCalculator.calculate(
        explorations: explorations,
        interestProfile: _profile(const {}),
        now: _thisWeekThursday,
      );

      expect(analytics.totalExperiencesCompleted, 1);
      expect(analytics.totalDurationSeconds, 0);
    });

    test('11. the same input always produces the same analytics (deterministic)', () {
      final explorations = [
        _record(id: 'a', categoryId: 'gaming', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday, durationSeconds: 100),
      ];
      final profile = _profile({InterestCategoryType.gaming: 55});

      final first = ParentAnalyticsCalculator.calculate(explorations: explorations, interestProfile: profile, now: _thisWeekThursday);
      final second = ParentAnalyticsCalculator.calculate(explorations: explorations, interestProfile: profile, now: _thisWeekThursday);

      expect(first.totalExperiencesCompleted, second.totalExperiencesCompleted);
      expect(first.totalDurationSeconds, second.totalDurationSeconds);
      expect(first.topInterests.map((s) => s.category), second.topInterests.map((s) => s.category));
    });

    test('12. account A data produces analytics scoped to account A', () {
      final accountA = ParentAnalyticsCalculator.calculate(
        explorations: [_record(id: 'a', categoryId: 'gaming', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday, durationSeconds: 500)],
        interestProfile: _profile({InterestCategoryType.gaming: 80}),
        now: _thisWeekThursday,
      );

      expect(accountA.totalExperiencesCompleted, 1);
      expect(accountA.totalDurationSeconds, 500);
      expect(accountA.topInterests.first.category, InterestCategoryType.gaming);
    });

    test('13. account B data produces independent, different analytics from account A', () {
      final accountA = ParentAnalyticsCalculator.calculate(
        explorations: [_record(id: 'a', categoryId: 'gaming', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday, durationSeconds: 500)],
        interestProfile: _profile({InterestCategoryType.gaming: 80}),
        now: _thisWeekThursday,
      );
      final accountB = ParentAnalyticsCalculator.calculate(
        explorations: [
          _record(id: 'b1', categoryId: 'art', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday, durationSeconds: 90),
          _record(id: 'b2', categoryId: 'art', startedAt: _thisWeekThursday, completedAt: _thisWeekThursday, durationSeconds: 90),
        ],
        interestProfile: _profile({InterestCategoryType.art: 65}),
        now: _thisWeekThursday,
      );

      expect(accountB.totalExperiencesCompleted, 2);
      expect(accountB.totalDurationSeconds, 180);
      expect(accountB.topInterests.first.category, InterestCategoryType.art);

      expect(accountA.totalExperiencesCompleted, isNot(accountB.totalExperiencesCompleted));
      expect(accountA.topInterests.first.category, isNot(accountB.topInterests.first.category));
    });
  });
}
