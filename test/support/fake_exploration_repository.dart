import 'package:nawa/features/experiences/data/exploration_repository.dart';
import 'package:nawa/features/experiences/domain/exploration_interaction.dart';
import 'package:nawa/features/experiences/domain/exploration_record.dart';

/// In-memory stand-in for [FirestoreExplorationRepository]. Lets any test
/// that starts/completes an experience session run without a real
/// Firestore/Firebase app. Keyed by (uid, childId) — the same isolation
/// boundary the real repository uses.
class FakeExplorationRepository implements ExplorationRepository {
  final Map<String, Map<String, ExplorationRecord>> _byChild = {};
  int _nextId = 0;

  bool failStart = false;
  bool failComplete = false;

  /// Number of times [startExploration] actually created a new record —
  /// tests use this to assert a rebuild/retry never creates a duplicate.
  int startCallCount = 0;

  String _key(String uid, String childId) => '$uid/$childId';

  @override
  Future<String> startExploration({
    required String uid,
    required String childId,
    required String experienceId,
    required String categoryId,
  }) async {
    if (failStart) throw Exception('simulated Firestore failure');
    startCallCount++;
    final id = 'exploration-${_nextId++}';
    final explorations = _byChild.putIfAbsent(_key(uid, childId), () => {});
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
    required String childId,
    required String explorationId,
    required int durationSeconds,
    required List<ExplorationInteraction> interactions,
  }) async {
    if (failComplete) throw Exception('simulated Firestore failure');
    final key = _key(uid, childId);
    final existing = _byChild[key]?[explorationId];
    if (existing == null) throw StateError('No exploration $explorationId for $key');
    _byChild[key]![explorationId] = ExplorationRecord(
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
  Future<List<ExplorationRecord>> getExplorations({required String uid, required String childId}) async =>
      (_byChild[_key(uid, childId)]?.values ?? const []).toList();

  @override
  Future<List<ExplorationRecord>> getCompletedExperiences({required String uid, required String childId}) async {
    return (await getExplorations(uid: uid, childId: childId)).where((record) => record.completed).toList();
  }
}
