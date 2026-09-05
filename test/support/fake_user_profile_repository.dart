import 'package:nawa/features/interests/domain/interest_category.dart';
import 'package:nawa/features/profile/data/user_profile_repository.dart';
import 'package:nawa/features/profile/domain/child_profile_record.dart';
import 'package:nawa/features/profile/domain/child_summary.dart';
import 'package:nawa/features/profile/domain/user_profile_record.dart';

/// In-memory stand-in for [FirestoreUserProfileRepository]. Lets any test
/// that pumps the full app (and therefore can reach the onboarding-sync or
/// profile-restore code paths) run without a real Firestore/Firebase app.
class FakeUserProfileRepository implements UserProfileRepository {
  final Map<String, UserProfileRecord> _users = {};
  final Map<String, List<ChildSummary>> _children = {};
  bool legacyMigrated = false;
  int _nextChildId = 0;

  bool failWrites = false;

  @override
  Future<void> createOrUpdateUserProfile({required String uid, required String email, String? parentName}) async {
    if (failWrites) throw Exception('simulated Firestore failure');
    final existing = _users[uid];
    _users[uid] = UserProfileRecord(uid: uid, email: email, role: 'parent', parentName: parentName ?? existing?.parentName);
  }

  @override
  Future<UserProfileRecord?> getUserProfile(String uid) async => _users[uid];

  @override
  Future<String> createChild({
    required String uid,
    required String name,
    required int age,
    Set<InterestCategoryType> interests = const {},
  }) async {
    if (failWrites) throw Exception('simulated Firestore failure');
    final id = 'child-${_nextChildId++}';
    _children.putIfAbsent(uid, () => []).add(ChildSummary(id: id, name: name, age: age, interests: interests));
    return id;
  }

  @override
  Future<void> updateChildInterests({required String uid, required String childId, required Set<InterestCategoryType> interests}) async {
    if (failWrites) throw Exception('simulated Firestore failure');
    final list = _children[uid];
    if (list == null) return;
    final index = list.indexWhere((child) => child.id == childId);
    if (index == -1) return;
    final existing = list[index];
    list[index] = ChildSummary(id: existing.id, name: existing.name, age: existing.age, interests: interests);
  }

  @override
  Future<ChildProfileRecord?> getChild({required String uid, required String childId}) async {
    final child = _find(uid, childId);
    if (child == null) return null;
    return ChildProfileRecord(name: child.name, age: child.age);
  }

  @override
  Future<Set<InterestCategoryType>> getChildInterests({required String uid, required String childId}) async {
    return _find(uid, childId)?.interests ?? const {};
  }

  @override
  Future<List<ChildSummary>> getChildren(String uid) async => List.of(_children[uid] ?? const []);

  @override
  Future<void> migrateLegacyChildIfNeeded(String uid) async {
    // Tests seed children directly via [seedChild] — there's no separate
    // legacy shape to migrate from in-memory, so this just records that it
    // ran, for tests that want to assert it's called.
    legacyMigrated = true;
  }

  ChildSummary? _find(String uid, String childId) {
    for (final child in _children[uid] ?? const <ChildSummary>[]) {
      if (child.id == childId) return child;
    }
    return null;
  }

  /// Seeds a child directly with a known id, for tests that need to
  /// reference it (e.g. via [restoreFromFirestore]) without going through
  /// [createChild] first.
  void seedChild(String uid, ChildSummary child) => _children.putIfAbsent(uid, () => []).add(child);
}
