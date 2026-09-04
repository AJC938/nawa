import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../interests/domain/interest_category.dart';
import '../domain/child_profile_record.dart';
import '../domain/user_profile_record.dart';

/// Firestore-backed parent/child profile storage, keyed by the Firebase
/// Auth UID (`users/{uid}`). UI and Riverpod controllers never touch
/// [FirebaseFirestore] directly — only this repository does.
abstract class UserProfileRepository {
  Future<void> createOrUpdateUserProfile({required String uid, required String email});

  Future<UserProfileRecord?> getUserProfile(String uid);

  Future<void> createOrUpdateChildProfile({required String uid, required String name, required int age});

  Future<ChildProfileRecord?> getChildProfile(String uid);

  /// Persists the child's selected interests as stable ids
  /// (`InterestCategoryType.id`, e.g. `"gaming"`) under `child.interests`.
  /// Merges into the existing `child` map — never touches name/age/etc.
  Future<void> saveInterests({required String uid, required Set<InterestCategoryType> interests});

  Future<Set<InterestCategoryType>> getInterests(String uid);
}

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository([FirebaseFirestore? firestore]) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _firestore.collection('users').doc(uid);

  @override
  Future<void> createOrUpdateUserProfile({required String uid, required String email}) async {
    final doc = _userDoc(uid);
    final existing = await doc.get();
    await doc.set({
      'email': email,
      'role': 'parent',
      'updatedAt': FieldValue.serverTimestamp(),
      if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<UserProfileRecord?> getUserProfile(String uid) async {
    final data = (await _userDoc(uid).get()).data();
    if (data == null) return null;
    return UserProfileRecord(uid: uid, email: data['email'] as String? ?? '', role: data['role'] as String? ?? 'parent');
  }

  @override
  Future<void> createOrUpdateChildProfile({required String uid, required String name, required int age}) async {
    final doc = _userDoc(uid);
    final existing = await doc.get();
    final hasChild = existing.data()?['child'] != null;
    await doc.set({
      'child': {
        'name': name,
        'age': age,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!hasChild) 'createdAt': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  @override
  Future<ChildProfileRecord?> getChildProfile(String uid) async {
    final child = (await _userDoc(uid).get()).data()?['child'] as Map<String, dynamic>?;
    final name = child?['name'] as String?;
    final age = child?['age'] as int?;
    if (name == null || age == null) return null;
    return ChildProfileRecord(name: name, age: age);
  }

  @override
  Future<void> saveInterests({required String uid, required Set<InterestCategoryType> interests}) async {
    await _userDoc(uid).set({
      'child': {
        'interests': interests.map((category) => category.id).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  @override
  Future<Set<InterestCategoryType>> getInterests(String uid) async {
    final child = (await _userDoc(uid).get()).data()?['child'] as Map<String, dynamic>?;
    final ids = (child?['interests'] as List?)?.cast<String>() ?? const [];
    return ids.map(interestCategoryFromId).whereType<InterestCategoryType>().toSet();
  }
}

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) => FirestoreUserProfileRepository());
