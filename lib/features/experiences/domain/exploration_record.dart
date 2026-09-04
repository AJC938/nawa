import 'exploration_interaction.dart';

/// A single Firestore-backed exploration session
/// (`users/{uid}/explorations/{explorationId}`) — one child starting (and
/// possibly completing) one [Experience].
class ExplorationRecord {
  const ExplorationRecord({
    required this.id,
    required this.experienceId,
    required this.categoryId,
    required this.startedAt,
    this.completedAt,
    this.durationSeconds = 0,
    this.completed = false,
    this.interactions = const [],
  });

  final String id;
  final String experienceId;
  final String categoryId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int durationSeconds;
  final bool completed;
  final List<ExplorationInteraction> interactions;
}
