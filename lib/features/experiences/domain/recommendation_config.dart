/// Centralized, tunable weights for the deterministic recommendation
/// engine. Keep every ranking magic-number here — nowhere else — so the
/// model can be retuned in one place.
class RecommendationConfig {
  const RecommendationConfig._();

  // --- A. Interest match, by the category's InterestLevel ---
  // (InterestLevel.veryStrong / .strong / .exploring / .emerging, from
  // strongest to weakest evidence — see InterestScoringEngine.)
  static const int strongInterestPoints = 60;
  static const int emergingInterestPoints = 40;
  static const int exploringInterestPoints = 25;
  static const int noEvidencePoints = 0;

  // --- B. Selected interest match ---
  static const int selectedInterestBonus = 15;

  // --- C. Exploration continuity: already has completions in this category ---
  static const int categoryHistoryBonus = 10;

  // --- D. Freshness / novelty for this exact experience ---
  static const int newExperienceBonus = 15;
  static const int repeatedExperiencePenalty = 30;

  // --- E. Diversity: category has little/no exploration evidence yet ---
  static const int diversityBonus = 5;
}
