import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localized_text.dart';
import '../../../experiences/data/mock_experiences.dart';
import '../../../experiences/domain/exploration_record.dart';
import '../../domain/interest_category.dart';
import '../../domain/interest_scoring_engine.dart';
import '../../domain/interest_signal.dart';

/// Holds Nawa's real, calculated interest profile for every category.
///
/// This is the single source of truth for interest scores/levels — it is
/// always fully recalculated from source data (selected interests +
/// persisted exploration records) via [InterestScoringEngine], never
/// incrementally mutated, so it can never drift from what's actually stored.
/// See [recalculate].
class InterestProfileController extends Notifier<Map<InterestCategoryType, InterestSignal>> {
  @override
  Map<InterestCategoryType, InterestSignal> build() {
    // Valid empty/default profile before any real data has loaded — no
    // selected interests, no explorations. Deterministic, not a mock.
    return InterestScoringEngine.calculate(selectedInterests: const {}, explorations: const []);
  }

  /// Recalculates the whole profile from source-of-truth data. Safe to call
  /// as often as needed (onboarding completion, Firestore restore, after an
  /// experience completes) — it always replaces the profile wholesale rather
  /// than layering on top of whatever was there before.
  void recalculate({
    required Set<InterestCategoryType> selectedInterests,
    required List<ExplorationRecord> explorations,
  }) {
    final signals = InterestScoringEngine.calculate(selectedInterests: selectedInterests, explorations: explorations);
    state = {
      for (final entry in signals.entries)
        entry.key: entry.value.copyWith(exploredConcepts: _conceptsFor(entry.value.completedExperienceIds)),
    };
  }

  /// The scoring engine only knows about exploration records, not the
  /// static experience catalog — so the "what concepts did they explore"
  /// enrichment (existing UI needs this) happens here, one level up.
  List<LocalizedText> _conceptsFor(List<String> completedExperienceIds) {
    final concepts = <LocalizedText>{};
    for (final experienceId in completedExperienceIds) {
      final experience = experienceById(experienceId);
      if (experience != null) {
        concepts.addAll(experience.questions.expand((question) => question.conceptTags));
      }
    }
    return concepts.toList();
  }
}

final interestProfileProvider = NotifierProvider<InterestProfileController, Map<InterestCategoryType, InterestSignal>>(
  InterestProfileController.new,
);
