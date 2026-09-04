import '../../experiences/domain/exploration_record.dart';
import 'interest_category.dart';
import 'interest_score_breakdown.dart';
import 'interest_scoring_config.dart';
import 'interest_signal.dart';

/// Pure, deterministic Interest Scoring engine.
///
/// Takes plain domain data — the child's selected interests and their
/// persisted exploration records — and returns a fresh [InterestSignal] per
/// category. No Firestore, no Riverpod, no I/O: the same inputs always
/// produce the same outputs, which is what makes the model explainable and
/// easy to unit test.
///
/// The profile is always recalculated from source data (never incrementally
/// mutated), so it can never drift from what's actually stored.
class InterestScoringEngine {
  const InterestScoringEngine._();

  static Map<InterestCategoryType, InterestSignal> calculate({
    required Set<InterestCategoryType> selectedInterests,
    required List<ExplorationRecord> explorations,
  }) {
    return {
      for (final category in InterestCategoryType.values)
        category: _scoreCategory(
          category: category,
          selected: selectedInterests.contains(category),
          records: explorations.where((record) => record.categoryId == category.id).toList(),
        ),
    };
  }

  static InterestSignal _scoreCategory({
    required InterestCategoryType category,
    required bool selected,
    required List<ExplorationRecord> records,
  }) {
    final completed = records.where((record) => record.completed).toList();
    final incomplete = records.where((record) => !record.completed).toList();

    final totalSeconds = records.fold<int>(0, (sum, record) => sum + record.durationSeconds);
    final timeBlocks = totalSeconds ~/ InterestScoringConfig.secondsPerTimeBlock;

    final totalInteractions = records.fold<int>(0, (sum, record) => sum + record.interactions.length);

    final breakdown = InterestScoreBreakdown(
      baselinePoints: selected ? InterestScoringConfig.selectedInterestBaselinePoints : 0,
      completionPoints: completed.length * InterestScoringConfig.completedExperiencePoints,
      startedIncompletePoints: incomplete.length * InterestScoringConfig.startedIncompleteExperiencePoints,
      timePoints: _capped(timeBlocks * InterestScoringConfig.timePointsPerBlock, InterestScoringConfig.maxTimePoints),
      interactionPoints: _capped(
        totalInteractions * InterestScoringConfig.interactionPointsEach,
        InterestScoringConfig.maxInteractionPoints,
      ),
    );

    final score = breakdown.total.clamp(InterestScoringConfig.minScore, InterestScoringConfig.maxScore).toDouble();

    return InterestSignal(
      category: category,
      score: score,
      completedExperienceIds: completed.map((record) => record.experienceId).toList(),
      breakdown: breakdown,
    );
  }

  static int _capped(int value, int max) => value > max ? max : value;
}
