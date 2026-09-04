import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../experiences/presentation/state/exploration_history_controller.dart';
import '../../../interests/presentation/state/interest_profile_controller.dart';
import '../../../profile/presentation/state/child_profile_controller.dart';
import '../../domain/parent_analytics.dart';
import '../../domain/parent_summary.dart';

/// Real, derived Parent Dashboard analytics — composed entirely from data
/// already loaded by [explorationHistoryProvider] and
/// [interestProfileProvider] (both populated at profile restore / experience
/// completion), so this adds no extra Firestore reads of its own.
final parentAnalyticsProvider = Provider<ParentAnalytics>((ref) {
  final explorations = ref.watch(explorationHistoryProvider);
  final interestProfile = ref.watch(interestProfileProvider);
  return ParentAnalyticsCalculator.calculate(explorations: explorations, interestProfile: interestProfile);
});

/// The existing Parent Dashboard / Parent Child Profile UI model, now filled
/// with real numbers from [parentAnalyticsProvider] instead of a mock
/// formula. Preserves the cards' existing all-time meaning — the "This
/// Week" figures are available on [ParentAnalytics] for when the dashboard's
/// (currently non-functional) "This Week" selector gets wired up, without
/// redesigning what these specific cards already show today.
final parentSummaryProvider = Provider<ParentSummary>((ref) {
  final child = ref.watch(childProfileProvider);
  final analytics = ref.watch(parentAnalyticsProvider);

  return ParentSummary(
    childName: child.name,
    topInterestScores: {for (final signal in analytics.topInterests) signal.category: signal.score},
    experiencesCompleted: analytics.totalExperiencesCompleted,
    timeSpentMinutes: analytics.totalDurationSeconds ~/ 60,
  );
});
