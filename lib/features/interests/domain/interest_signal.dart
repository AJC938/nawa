import '../../../core/localization/localized_text.dart';
import 'interest_category.dart';
import 'interest_level.dart';
import 'interest_score_breakdown.dart';

/// The real exploration signal Nawa has calculated for one category, from
/// the child's selected interests and their persisted exploration history.
/// See [InterestScoringEngine] for how [score] is derived.
class InterestSignal {
  const InterestSignal({
    required this.category,
    required this.score,
    this.exploredConcepts = const [],
    this.completedExperienceIds = const [],
    this.breakdown = const InterestScoreBreakdown(),
  });

  final InterestCategoryType category;

  /// 0-100 deterministic exploration score. Never shown as a raw number to
  /// users — only [level] is user-facing.
  final double score;

  final List<LocalizedText> exploredConcepts;
  final List<String> completedExperienceIds;

  /// How [score] was built up, for future "why is this strong" explanations.
  final InterestScoreBreakdown breakdown;

  InterestLevel get level => interestLevelForScore(score);

  InterestSignal copyWith({
    double? score,
    List<LocalizedText>? exploredConcepts,
    List<String>? completedExperienceIds,
    InterestScoreBreakdown? breakdown,
  }) {
    return InterestSignal(
      category: category,
      score: score ?? this.score,
      exploredConcepts: exploredConcepts ?? this.exploredConcepts,
      completedExperienceIds: completedExperienceIds ?? this.completedExperienceIds,
      breakdown: breakdown ?? this.breakdown,
    );
  }
}
