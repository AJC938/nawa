import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../interests/domain/interest_category.dart';
import '../domain/child_profile_record.dart';
import '../domain/child_summary.dart';
import '../domain/user_profile_record.dart';

/// Firestore-backed parent account + children storage, keyed by the
/// Firebase Auth UID (`users/{uid}`), with each child as its own document
/// under `users/{uid}/children/{childId}`. UI and Riverpod controllers
/// never touch [FirebaseFirestore] directly — only this repository does.
abstract class UserProfileRepository {
  Future<void> createOrUpdateUserProfile({required String uid, required String email, String? parentName});

  Future<UserProfileRecord?> getUserProfile(String uid);

  /// Creates a new child under [uid] and returns its generated, stable id
  /// (never the child's name or age) — the id every child-specific read/
  /// write is scoped by from then on.
  Future<String> createChild({
    required String uid,
    required String name,
    required int age,
    Set<InterestCategoryType> interests = const {},
  });

  Future<void> updateChildInterests({required String uid, required String childId, required Set<InterestCategoryType> interests});

  Future<ChildProfileRecord?> getChild({required String uid, required String childId});

  Future<Set<InterestCategoryType>> getChildInterests({required String uid, required String childId});

  /// All children for this parent, oldest first (so the first-ever child
  /// stays first in any picker).
  Future<List<ChildSummary>> getChildren(String uid);

  /// One-time compatibility step for accounts created before multi-child
  /// support existed: if `users/{uid}/children` is still empty but a
  /// legacy `users/{uid}.child` map is present, copies it forward into a
  /// new child document (preserving name/age/interests/createdAt) and
  /// copies any legacy `users/{uid}/explorations` records into that
  /// child's own exploration subcollection. Nothing legacy is deleted —
  /// this only ever copies forward, so no existing test data is lost. A
  /// no-op once at least one child document already exists.
  Future<void> migrateLegacyChildIfNeeded(String uid);
}

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository([FirebaseFirestore? firestore]) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _firestore.collection('users').doc(uid);
  CollectionReference<Map<String, dynamic>> _children(String uid) => _userDoc(uid).collection('children');

  @override
  Future<void> createOrUpdateUserProfile({required String uid, required String email, String? parentName}) async {
    final doc = _userDoc(uid);
    final existing = await doc.get();
    await doc.set({
      'email': email,
      'role': 'parent',
      'updatedAt': FieldValue.serverTimestamp(),
      if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
      if (parentName != null && parentName.trim().isNotEmpty) 'parentName': parentName.trim(),
    }, SetOptions(merge: true));
  }

  @override
  Future<UserProfileRecord?> getUserProfile(String uid) async {
    final data = (await _userDoc(uid).get()).data();
    if (data == null) return null;
    return UserProfileRecord(
      uid: uid,
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'parent',
      parentName: data['parentName'] as String?,
    );
  }

  @override
  Future<String> createChild({
    required String uid,
    required String name,
    required int age,
    Set<InterestCategoryType> interests = const {},
  }) async {
    final doc = _children(uid).doc();
    await doc.set({
      'name': name,
      'age': age,
      'interests': interests.map((category) => category.id).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  @override
  Future<void> updateChildInterests({required String uid, required String childId, required Set<InterestCategoryType> interests}) async {
    await _children(uid).doc(childId).set({
      'interests': interests.map((category) => category.id).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<ChildProfileRecord?> getChild({required String uid, required String childId}) async {
    final data = (await _children(uid).doc(childId).get()).data();
    final name = data?['name'] as String?;
    final age = (data?['age'] as num?)?.toInt();
    if (name == null || age == null) return null;
    return ChildProfileRecord(name: name, age: age);
  }

  @override
  Future<Set<InterestCategoryType>> getChildInterests({required String uid, required String childId}) async {
    final data = (await _children(uid).doc(childId).get()).data();
    return _interestsFromRaw(data?['interests']);
  }

  @override
  Future<List<ChildSummary>> getChildren(String uid) async {
    final snapshot = await _children(uid).orderBy('createdAt').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ChildSummary(
        id: doc.id,
        name: data['name'] as String? ?? '',
        age: (data['age'] as num?)?.toInt() ?? 0,
        interests: _interestsFromRaw(data['interests']),
      );
    }).toList();
  }

  @override
  Future<void> migrateLegacyChildIfNeeded(String uid) async {
    final existingChildren = await _children(uid).limit(1).get();
    if (existingChildren.docs.isNotEmpty) return;

    final userData = (await _userDoc(uid).get()).data();
    final legacyChild = userData?['child'] as Map<String, dynamic>?;
    final legacyName = legacyChild?['name'] as String?;
    final legacyAge = (legacyChild?['age'] as num?)?.toInt();
    if (legacyChild == null || legacyName == null || legacyAge == null) return;

    final childDoc = _children(uid).doc();
    await childDoc.set({
      'name': legacyName,
      'age': legacyAge,
      'interests': legacyChild['interests'] ?? const <String>[],
      'createdAt': legacyChild['createdAt'] ?? FieldValue.serverTimestamp(),
      'updatedAt': legacyChild['updatedAt'] ?? FieldValue.serverTimestamp(),
    });

    // Carry forward any legacy top-level explorations from before
    // multi-child support into the new child's own subcollection. The
    // originals are left untouched — this only copies, never deletes.
    final legacyExplorations = await _userDoc(uid).collection('explorations').get();
    if (legacyExplorations.docs.isEmpty) return;

    final batch = _firestore.batch();
    final newExplorations = childDoc.collection('explorations');
    for (final doc in legacyExplorations.docs) {
      batch.set(newExplorations.doc(doc.id), doc.data());
    }
    await batch.commit();
  }

  Set<InterestCategoryType> _interestsFromRaw(Object? raw) {
    final ids = (raw as List?)?.cast<String>() ?? const [];
    return ids.map(interestCategoryFromId).whereType<InterestCategoryType>().toSet();
  }
}

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) => FirestoreUserProfileRepository());
