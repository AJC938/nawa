import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/exploration_record.dart';

/// Caches the authenticated child's real exploration records (from
/// `users/{uid}/explorations`) in Riverpod state, so both
/// [InterestScoringEngine] and [RecommendationEngine] can reuse the same
/// already-loaded data instead of each issuing their own Firestore read.
///
/// Populated wherever exploration data is fetched — profile restore and
/// experience completion — via [setExplorations]. Always a full wholesale
/// replace, same as [InterestProfileController.recalculate], so it can
/// never drift or leak between accounts.
class ExplorationHistoryController extends Notifier<List<ExplorationRecord>> {
  @override
  List<ExplorationRecord> build() => const [];

  void setExplorations(List<ExplorationRecord> explorations) => state = explorations;
}

final explorationHistoryProvider = NotifierProvider<ExplorationHistoryController, List<ExplorationRecord>>(
  ExplorationHistoryController.new,
);
