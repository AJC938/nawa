import '../../interests/domain/interest_category.dart';

/// Derived, read-only view of a child's exploration for the parent screens.
/// Computed locally from [ChildProfile] + the interest profile — no
/// separate backend model yet.
class ParentSummary {
  const ParentSummary({
    required this.childName,
    required this.topInterestScores,
    required this.experiencesCompleted,
    required this.timeSpentMinutes,
  });

  final String childName;
  final Map<InterestCategoryType, double> topInterestScores;
  final int experiencesCompleted;
  final int timeSpentMinutes;

  String get timeSpentLabel {
    final hours = timeSpentMinutes ~/ 60;
    final minutes = timeSpentMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }
}
