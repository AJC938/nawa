import 'package:nawa/features/experiences/data/exploration_repository.dart';
import 'package:nawa/features/experiences/domain/exploration_interaction.dart';
import 'package:nawa/features/experiences/domain/exploration_record.dart';

/// In-memory stand-in for [FirestoreExplorationRepository]. Lets any test
/// that starts/completes an experience session run without a real
/// Firestore/Firebase app.
class FakeExplorationRepository implements ExplorationRepository {
  final Map<String, Map<String, ExplorationRecord>> _byUid = {};
  int _nextId = 0;

  bool failStart = false;
  bool failComplete = false;

  /// Number of times [startExploration] actually created a new record —
  /// tests use this to assert a rebuild/retry never creates a duplicate.
  int startCallCount = 0;

  @override
  Future<String> startExploration({required String uid, required String experienceId, required String categoryId}) async {
    if (failStart) throw Exception('simulated Firestore failure');
    startCallCount++;
    final id = 'exploration-${_nextId++}';
    final explorations = _byUid.putIfAbsent(uid, () => {});
    explorations[id] = ExplorationRecord(
      id: id,
      experienceId: experienceId,
      categoryId: categoryId,
      startedAt: DateTime.now(),
    );
    return id;
  }

  @override
  Future<void> completeExploration({
    required String uid,
    required String explorationId,
    required int durationSeconds,
    required List<ExplorationInteraction> interactions,
  }) async {
    if (failComplete) throw Exception('simulated Firestore failure');
    final existing = _byUid[uid]?[explorationId];
    if (existing == null) throw StateError('No exploration $explorationId for $uid');
    _byUid[uid]![explorationId] = ExplorationRecord(
      id: existing.id,
      experienceId: existing.experienceId,
      categoryId: existing.categoryId,
      startedAt: existing.startedAt,
      completedAt: DateTime.now(),
      durationSeconds: durationSeconds,
      completed: true,
      interactions: interactions,
    );
  }

  @override
  Future<List<ExplorationRecord>> getExplorations(String uid) async => (_byUid[uid]?.values ?? const []).toList();

  @override
  Future<List<ExplorationRecord>> getCompletedExperiences(String uid) async {
    return (await getExplorations(uid)).where((record) => record.completed).toList();
  }
}
