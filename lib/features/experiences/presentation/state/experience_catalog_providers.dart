import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../interests/domain/interest_category.dart';
import '../../../interests/presentation/state/interest_profile_controller.dart';
import '../../../profile/presentation/state/child_profile_controller.dart';
import '../../data/mock_experiences.dart';
import '../../domain/experience.dart';
import '../../domain/recommendation_engine.dart';
import '../../domain/recommendation_result.dart';
import 'exploration_history_controller.dart';

final allExperiencesProvider = Provider<List<Experience>>((ref) => mockExperiences);

final featuredExperiencesProvider = Provider<List<Experience>>((ref) => featuredExperiences);

final experiencesByCategoryProvider = Provider.family<List<Experience>, InterestCategoryType>(
  (ref, category) => experiencesByCategory(category),
);

final experienceByIdProvider = Provider.family<Experience?, String>((ref, id) => experienceById(id));

/// The single source of ranked recommendations for the whole app — Home's
/// "Recommended for you" and the Discover More screen both read from this
/// same list rather than having separate ranking logic.
///
/// Combines the static experience catalog with the authenticated child's
/// real selected interests, calculated [InterestSignal] profile, and
/// exploration history via the pure, deterministic [RecommendationEngine].
final rankedExperiencesProvider = Provider<List<RecommendationResult>>((ref) {
  final experiences = ref.watch(allExperiencesProvider);
  final selectedInterests = ref.watch(childProfileProvider).interests;
  final interestProfile = ref.watch(interestProfileProvider);
  final explorations = ref.watch(explorationHistoryProvider);

  return RecommendationEngine.rank(
    availableExperiences: experiences,
    selectedInterests: selectedInterests,
    interestProfile: interestProfile,
    explorations: explorations,
  );
});

/// Home's "Recommended for you" — the top of the same ranked list used by
/// Discover More, not a separate mock source.
final recommendedExperiencesProvider = Provider<List<Experience>>((ref) {
  const homeSectionSize = 4;
  return ref.watch(rankedExperiencesProvider).take(homeSectionSize).map((result) => result.experience).toList();
});
