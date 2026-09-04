import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/core/localization/localized_text.dart';
import 'package:nawa/features/experiences/domain/experience.dart';
import 'package:nawa/features/experiences/domain/exploration_interaction.dart';
import 'package:nawa/features/experiences/domain/exploration_record.dart';
import 'package:nawa/features/experiences/domain/recommendation_engine.dart';
import 'package:nawa/features/experiences/domain/recommendation_result.dart';
import 'package:nawa/features/interests/domain/interest_category.dart';
import 'package:nawa/features/interests/domain/interest_score_breakdown.dart';
import 'package:nawa/features/interests/domain/interest_signal.dart';

Experience _experience({required String id, required InterestCategoryType category}) {
  return Experience(
    id: id,
    category: category,
    title: LocalizedText(en: id, ar: id),
    ageRangeLabel: '6-10 yrs',
    durationMinutes: 10,
    description: LocalizedText(en: id, ar: id),
    illustrationIcon: Icons.star,
    imageAsset: 'assets/experiences/$id.svg',
    exploresTags: const [],
    questions: const [],
  );
}

/// Builds a profile with an explicit score per category, defaulting
/// everything else to the empty/no-evidence baseline.
Map<InterestCategoryType, InterestSignal> _profile(Map<InterestCategoryType, double> scores) {
  return {
    for (final category in InterestCategoryType.values)
      category: InterestSignal(
        category: category,
        score: scores[category] ?? 0,
        breakdown: const InterestScoreBreakdown(),
      ),
  };
}

ExplorationRecord _completed({required String experienceId, required String categoryId}) {
  return ExplorationRecord(
    id: 'exp-$experienceId',
    experienceId: experienceId,
    categoryId: categoryId,
    startedAt: DateTime(2026, 1, 1),
    completedAt: DateTime(2026, 1, 1),
    completed: true,
    durationSeconds: 60,
    interactions: const [ExplorationInteraction(questionId: 'q1', selectedOptionId: 'a', order: 0)],
  );
}

void main() {
  group('RecommendationEngine', () {
    test('1. a strong-interest category ranks highest', () {
      final gaming = _experience(id: 'gaming-exp', category: InterestCategoryType.gaming);
      final art = _experience(id: 'art-exp', category: InterestCategoryType.art);

      final ranked = RecommendationEngine.rank(
        availableExperiences: [art, gaming],
        selectedInterests: const {},
        interestProfile: _profile({InterestCategoryType.gaming: 80}), // veryStrong
        explorations: const [],
      );

      expect(ranked.first.experience.id, 'gaming-exp');
      expect(ranked.first.reason, RecommendationReason.strongInterest);
    });

    test('2. an emerging-tier category outranks a weak/no-evidence category', () {
      final tech = _experience(id: 'tech-exp', category: InterestCategoryType.technology);
      final art = _experience(id: 'art-exp', category: InterestCategoryType.art);

      final ranked = RecommendationEngine.rank(
        availableExperiences: [art, tech],
        selectedInterests: const {},
        interestProfile: _profile({InterestCategoryType.technology: 60}), // strong == "Emerging" tier bonus
        explorations: const [],
      );

      expect(ranked.first.experience.id, 'tech-exp');
      expect(ranked.first.reason, RecommendationReason.emergingInterest);
      expect(ranked.first.score, greaterThan(ranked.last.score));
    });

    test('3. the selected-interest bonus lifts an otherwise-equal category', () {
      final selected = _experience(id: 'selected-exp', category: InterestCategoryType.sports);
      final unselected = _experience(id: 'unselected-exp', category: InterestCategoryType.art);

      final ranked = RecommendationEngine.rank(
        availableExperiences: [unselected, selected],
        selectedInterests: {InterestCategoryType.sports},
        interestProfile: _profile(const {}), // both categories at no-evidence baseline
        explorations: const [],
      );

      expect(ranked.first.experience.id, 'selected-exp');
      expect(ranked.first.reason, RecommendationReason.selectedInterest);
    });

    test('4. a completed experience receives a strong repetition penalty', () {
      final experience = _experience(id: 'space-adventure', category: InterestCategoryType.gaming);

      final freshScore = RecommendationEngine.rank(
        availableExperiences: [experience],
        selectedInterests: const {},
        interestProfile: _profile(const {}),
        explorations: const [],
      ).single.score;

      final completedScore = RecommendationEngine.rank(
        availableExperiences: [experience],
        selectedInterests: const {},
        interestProfile: _profile(const {}),
        explorations: [_completed(experienceId: 'space-adventure', categoryId: 'gaming')],
      ).single.score;

      expect(completedScore, lessThan(freshScore));
    });

    test('5. a never-completed experience receives the novelty bonus and is labeled newExploration', () {
      final experience = _experience(id: 'fresh-exp', category: InterestCategoryType.art);

      final result = RecommendationEngine.rank(
        availableExperiences: [experience],
        selectedInterests: const {},
        interestProfile: _profile(const {}),
        explorations: const [],
      ).single;

      expect(result.reason, RecommendationReason.newExploration);
    });

    test('6. category history (a completion elsewhere in the category) contributes a bonus', () {
      final newInCategory = _experience(id: 'new-gaming-exp', category: InterestCategoryType.gaming);

      final withoutHistory = RecommendationEngine.rank(
        availableExperiences: [newInCategory],
        selectedInterests: const {},
        interestProfile: _profile(const {}),
        explorations: const [],
      ).single.score;

      final withHistory = RecommendationEngine.rank(
        availableExperiences: [newInCategory],
        selectedInterests: const {},
        interestProfile: _profile(const {}),
        // A different, already-completed experience in the SAME category.
        explorations: [_completed(experienceId: 'other-gaming-exp', categoryId: 'gaming')],
      ).single.score;

      expect(withHistory, greaterThan(withoutHistory));
    });

    test('7. multiple categories rank independently of each other', () {
      final gaming = _experience(id: 'gaming-exp', category: InterestCategoryType.gaming);
      final science = _experience(id: 'science-exp', category: InterestCategoryType.science);
      final sports = _experience(id: 'sports-exp', category: InterestCategoryType.sports);

      final ranked = RecommendationEngine.rank(
        availableExperiences: [sports, science, gaming],
        selectedInterests: const {},
        interestProfile: _profile({
          InterestCategoryType.gaming: 90,
          InterestCategoryType.science: 60,
          InterestCategoryType.sports: 30,
        }),
        explorations: const [],
      );

      expect(ranked.map((r) => r.experience.id).toList(), ['gaming-exp', 'science-exp', 'sports-exp']);
    });

    test('8. the same input always produces the same ranking (deterministic)', () {
      final experiences = [
        _experience(id: 'a', category: InterestCategoryType.gaming),
        _experience(id: 'b', category: InterestCategoryType.art),
      ];
      final profile = _profile({InterestCategoryType.gaming: 40});
      final explorations = [_completed(experienceId: 'a', categoryId: 'gaming')];

      final first = RecommendationEngine.rank(
        availableExperiences: experiences,
        selectedInterests: {InterestCategoryType.art},
        interestProfile: profile,
        explorations: explorations,
      );
      final second = RecommendationEngine.rank(
        availableExperiences: experiences,
        selectedInterests: {InterestCategoryType.art},
        interestProfile: profile,
        explorations: explorations,
      );

      expect(first.map((r) => r.experience.id).toList(), second.map((r) => r.experience.id).toList());
      expect(first.map((r) => r.score).toList(), second.map((r) => r.score).toList());
    });

    test('9. completed experiences do not dominate the top of the ranking when fresh alternatives exist', () {
      final completedExp = _experience(id: 'completed-exp', category: InterestCategoryType.gaming);
      final freshExp = _experience(id: 'fresh-exp', category: InterestCategoryType.gaming);

      final ranked = RecommendationEngine.rank(
        availableExperiences: [completedExp, freshExp],
        selectedInterests: const {},
        interestProfile: _profile({InterestCategoryType.gaming: 80}),
        explorations: [_completed(experienceId: 'completed-exp', categoryId: 'gaming')],
      );

      expect(ranked.first.experience.id, 'fresh-exp');
      expect(ranked.last.experience.id, 'completed-exp');
    });

    test('10. the ranking is stable — recomputing from unchanged source data does not reorder results', () {
      final experiences = [
        _experience(id: 'a', category: InterestCategoryType.gaming),
        _experience(id: 'b', category: InterestCategoryType.gaming),
        _experience(id: 'c', category: InterestCategoryType.art),
      ];
      final profile = _profile({InterestCategoryType.gaming: 55});

      final order1 = RecommendationEngine.rank(
        availableExperiences: experiences,
        selectedInterests: const {},
        interestProfile: profile,
        explorations: const [],
      ).map((r) => r.experience.id).toList();
      final order2 = RecommendationEngine.rank(
        availableExperiences: experiences,
        selectedInterests: const {},
        interestProfile: profile,
        explorations: const [],
      ).map((r) => r.experience.id).toList();

      expect(order1, order2);
    });

    test('11. an empty experience list returns an empty ranking without crashing', () {
      final ranked = RecommendationEngine.rank(
        availableExperiences: const [],
        selectedInterests: const {},
        interestProfile: _profile(const {}),
        explorations: const [],
      );

      expect(ranked, isEmpty);
    });

    test('12. a child with no interests and no exploration still gets a valid, fully-scored ranking', () {
      final experiences = [
        _experience(id: 'a', category: InterestCategoryType.gaming),
        _experience(id: 'b', category: InterestCategoryType.art),
      ];

      final ranked = RecommendationEngine.rank(
        availableExperiences: experiences,
        selectedInterests: const {},
        interestProfile: _profile(const {}),
        explorations: const [],
      );

      expect(ranked, hasLength(2));
      for (final result in ranked) {
        // No evidence (0) + new-experience bonus (15) + diversity bonus (5).
        expect(result.score, 20);
      }
    });

    test('13. different account-specific input (different profile/history) produces a different ranking', () {
      final experiences = [
        _experience(id: 'gaming-exp', category: InterestCategoryType.gaming),
        _experience(id: 'art-exp', category: InterestCategoryType.art),
      ];

      final accountA = RecommendationEngine.rank(
        availableExperiences: experiences,
        selectedInterests: const {},
        interestProfile: _profile({InterestCategoryType.gaming: 90}),
        explorations: const [],
      ).map((r) => r.experience.id).toList();

      final accountB = RecommendationEngine.rank(
        availableExperiences: experiences,
        selectedInterests: const {},
        interestProfile: _profile({InterestCategoryType.art: 90}),
        explorations: const [],
      ).map((r) => r.experience.id).toList();

      expect(accountA, ['gaming-exp', 'art-exp']);
      expect(accountB, ['art-exp', 'gaming-exp']);
      expect(accountA, isNot(accountB));
    });

    test('14. no duplicate experience entries in the ranked result', () {
      final experiences = [
        _experience(id: 'a', category: InterestCategoryType.gaming),
        _experience(id: 'b', category: InterestCategoryType.gaming),
        _experience(id: 'c', category: InterestCategoryType.art),
      ];

      final ranked = RecommendationEngine.rank(
        availableExperiences: experiences,
        selectedInterests: const {},
        interestProfile: _profile(const {}),
        explorations: const [],
      );

      expect(ranked.map((r) => r.experience.id).toSet().length, ranked.length);
    });

    test('15. score weights are applied exactly as configured', () {
      final experience = _experience(id: 'gaming-exp', category: InterestCategoryType.gaming);

      final result = RecommendationEngine.rank(
        availableExperiences: [experience],
        selectedInterests: {InterestCategoryType.gaming},
        interestProfile: _profile({InterestCategoryType.gaming: 80}), // veryStrong -> +60
        explorations: [_completed(experienceId: 'other-gaming-exp', categoryId: 'gaming')], // category history, not this exact experience
      ).single;

      // 60 (strong interest) + 15 (selected) + 10 (category history) + 15 (novelty, never completed) + 0 (diversity, has history) = 100.
      expect(result.score, 100);
      expect(result.reason, RecommendationReason.strongInterest);
    });
  });
}
