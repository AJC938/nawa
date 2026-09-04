import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/exploration_interaction.dart';
import '../domain/exploration_record.dart';

/// Firestore-backed exploration (experience session) storage, keyed by the
/// Firebase Auth UID under `users/{uid}/explorations/{explorationId}`. UI
/// and Riverpod controllers never touch [FirebaseFirestore] directly —
/// only this repository does.
abstract class ExplorationRepository {
  /// Creates a new exploration record and returns its generated id, so the
  /// caller can hold onto it and later update the SAME record on completion
  /// rather than creating a second one.
  Future<String> startExploration({required String uid, required String experienceId, required String categoryId});

  /// Updates the same exploration record in place — never creates a new one.
  Future<void> completeExploration({
    required String uid,
    required String explorationId,
    required int durationSeconds,
    required List<ExplorationInteraction> interactions,
  });

  Future<List<ExplorationRecord>> getExplorations(String uid);

  Future<List<ExplorationRecord>> getCompletedExperiences(String uid);
}

class FirestoreExplorationRepository implements ExplorationRepository {
  FirestoreExplorationRepository([FirebaseFirestore? firestore]) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _explorations(String uid) =>
      _firestore.collection('users').doc(uid).collection('explorations');

  @override
  Future<String> startExploration({required String uid, required String experienceId, required String categoryId}) async {
    final doc = _explorations(uid).doc();
    await doc.set({
      'experienceId': experienceId,
      'categoryId': categoryId,
      'startedAt': FieldValue.serverTimestamp(),
      'completedAt': null,
      'durationSeconds': 0,
      'completed': false,
      'interactions': const <Map<String, dynamic>>[],
    });
    return doc.id;
  }

  @override
  Future<void> completeExploration({
    required String uid,
    required String explorationId,
    required int durationSeconds,
    required List<ExplorationInteraction> interactions,
  }) async {
    await _explorations(uid).doc(explorationId).set({
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
      'durationSeconds': durationSeconds,
      'interactions': interactions.map((i) => i.toMap()).toList(),
    }, SetOptions(merge: true));
  }

  @override
  Future<List<ExplorationRecord>> getExplorations(String uid) async {
    final snapshot = await _explorations(uid).orderBy('startedAt', descending: true).get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Future<List<ExplorationRecord>> getCompletedExperiences(String uid) async {
    final all = await getExplorations(uid);
    return all.where((record) => record.completed).toList();
  }

  ExplorationRecord _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawInteractions = (data['interactions'] as List?) ?? const [];
    return ExplorationRecord(
      id: doc.id,
      experienceId: data['experienceId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      durationSeconds: (data['durationSeconds'] as num?)?.toInt() ?? 0,
      completed: data['completed'] as bool? ?? false,
      interactions: rawInteractions
          .map((raw) => ExplorationInteraction.fromMap(Map<String, dynamic>.from(raw as Map)))
          .toList(),
    );
  }
}

final explorationRepositoryProvider = Provider<ExplorationRepository>((ref) => FirestoreExplorationRepository());
