/// Centralized, tunable constants for the deterministic interest scoring
/// model. Keep every scoring magic-number here — nowhere else — so the
/// formula can be retuned in one place.
class InterestScoringConfig {
  const InterestScoringConfig._();

  /// Points a category gets for being one of the child's selected interests.
  static const int selectedInterestBaselinePoints = 20;

  /// Points per completed experience in the category.
  static const int completedExperiencePoints = 25;

  /// Points per started-but-not-completed experience in the category.
  static const int startedIncompleteExperiencePoints = 5;

  /// Points per [secondsPerTimeBlock] of recorded exploration time.
  static const int timePointsPerBlock = 5;
  static const int secondsPerTimeBlock = 5 * 60;

  /// Time points are capped per scoring run so a single very long session
  /// can't dominate the score.
  static const int maxTimePoints = 20;

  /// Points per recorded interaction (e.g. a question answered).
  static const int interactionPointsEach = 2;

  /// Interaction points are capped per scoring run for the same reason as
  /// [maxTimePoints].
  static const int maxInteractionPoints = 20;

  static const int minScore = 0;
  static const int maxScore = 100;
}
