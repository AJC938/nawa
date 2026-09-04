import 'experience.dart';

/// Why an experience was recommended — kept as data (not just a score) so a
/// future screen can explain the recommendation, in the same priority order
/// the ranking itself applies: a strong/emerging category match wins over a
/// merely-selected interest, which wins over "just something new to try".
enum RecommendationReason { strongInterest, emergingInterest, selectedInterest, newExploration, categoryExploration }

/// One ranked experience from [RecommendationEngine.rank].
class RecommendationResult {
  const RecommendationResult({required this.experience, required this.score, required this.reason});

  final Experience experience;
  final int score;
  final RecommendationReason reason;
}
