/// Explains exactly how a category's score was built, so a later screen
/// (e.g. Parent Dashboard) can show *why* an interest is strong instead of
/// just a number.
class InterestScoreBreakdown {
  const InterestScoreBreakdown({
    this.baselinePoints = 0,
    this.completionPoints = 0,
    this.startedIncompletePoints = 0,
    this.timePoints = 0,
    this.interactionPoints = 0,
  });

  /// From being a selected onboarding interest.
  final int baselinePoints;

  /// From completed experiences in the category.
  final int completionPoints;

  /// From started-but-not-completed experiences in the category.
  final int startedIncompletePoints;

  /// From recorded exploration time in the category (capped).
  final int timePoints;

  /// From recorded interactions in the category (capped).
  final int interactionPoints;

  /// Sum of all points before the final 0-100 score cap is applied.
  int get total => baselinePoints + completionPoints + startedIncompletePoints + timePoints + interactionPoints;
}
