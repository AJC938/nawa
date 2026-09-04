import '../../interests/domain/interest_category.dart';
import '../../interests/domain/interest_level.dart';
import '../../interests/domain/interest_signal.dart';
import 'experience.dart';
import 'exploration_record.dart';
import 'recommendation_config.dart';
import 'recommendation_result.dart';

/// Pure, deterministic Recommendation Engine.
///
/// Ranks the available experience catalog for one child using their real
/// selected interests, calculated [InterestSignal] profile, and persisted
/// exploration history. No Firestore, no Riverpod, no I/O, no AI — the same
/// inputs always produce the same ranking.
///
/// Completed experiences are never removed from the result, only heavily
/// de-prioritized (see [RecommendationConfig.repeatedExperiencePenalty]), so
/// a caller can still show *something* even if everything has been tried.
class RecommendationEngine {
  const RecommendationEngine._();

  static List<RecommendationResult> rank({
    required List<Experience> availableExperiences,
    required Set<InterestCategoryType> selectedInterests,
    required Map<InterestCategoryType, InterestSignal> interestProfile,
    required List<ExplorationRecord> explorations,
  }) {
    final completedExperienceIds = explorations.where((r) => r.completed).map((r) => r.experienceId).toSet();

    final completedCountByCategory = <InterestCategoryType, int>{};
    for (final record in explorations.where((r) => r.completed)) {
      final category = interestCategoryFromId(record.categoryId);
      if (category == null) continue;
      completedCountByCategory[category] = (completedCountByCategory[category] ?? 0) + 1;
    }

    final results = availableExperiences.map((experience) {
      return _score(
        experience: experience,
        level: interestProfile[experience.category]?.level ?? InterestLevel.emerging,
        selected: selectedInterests.contains(experience.category),
        alreadyCompleted: completedExperienceIds.contains(experience.id),
        hasCategoryHistory: (completedCountByCategory[experience.category] ?? 0) > 0,
      );
    }).toList();

    // Highest score first; ties broken by a stable, deterministic key (the
    // experience id) so the ranking never depends on incoming list order.
    results.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.experience.id.compareTo(b.experience.id);
    });

    return results;
  }

  static RecommendationResult _score({
    required Experience experience,
    required InterestLevel level,
    required bool selected,
    required bool alreadyCompleted,
    required bool hasCategoryHistory,
  }) {
    final interestPoints = _interestPoints(level);
    final selectedBonus = selected ? RecommendationConfig.selectedInterestBonus : 0;
    final categoryHistoryBonus = hasCategoryHistory ? RecommendationConfig.categoryHistoryBonus : 0;
    final noveltyPoints = alreadyCompleted
        ? -RecommendationConfig.repeatedExperiencePenalty
        : RecommendationConfig.newExperienceBonus;
    // Diversity nudges toward categories with little/no evidence yet —
    // mutually exclusive with the "already has history" bonus above.
    final diversityBonus = hasCategoryHistory ? 0 : RecommendationConfig.diversityBonus;

    final score = interestPoints + selectedBonus + categoryHistoryBonus + noveltyPoints + diversityBonus;

    return RecommendationResult(
      experience: experience,
      score: score,
      reason: _reasonFor(
        level: level,
        selected: selected,
        alreadyCompleted: alreadyCompleted,
        hasCategoryHistory: hasCategoryHistory,
      ),
    );
  }

  static int _interestPoints(InterestLevel level) {
    switch (level) {
      case InterestLevel.veryStrong:
        return RecommendationConfig.strongInterestPoints;
      case InterestLevel.strong:
        return RecommendationConfig.emergingInterestPoints;
      case InterestLevel.exploring:
        return RecommendationConfig.exploringInterestPoints;
      case InterestLevel.emerging:
        return RecommendationConfig.noEvidencePoints;
    }
  }

  /// Picks the single dominant reason, in the same priority order the
  /// ranking favors: a strong/emerging category match beats merely being
  /// selected, which beats "just something new to try".
  static RecommendationReason _reasonFor({
    required InterestLevel level,
    required bool selected,
    required bool alreadyCompleted,
    required bool hasCategoryHistory,
  }) {
    if (level == InterestLevel.veryStrong) return RecommendationReason.strongInterest;
    if (level == InterestLevel.strong) return RecommendationReason.emergingInterest;
    if (selected) return RecommendationReason.selectedInterest;
    if (!alreadyCompleted) return RecommendationReason.newExploration;
    if (hasCategoryHistory) return RecommendationReason.categoryExploration;
    return RecommendationReason.newExploration;
  }
}
