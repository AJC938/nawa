import 'package:nawa/features/interests/domain/interest_category.dart';
import 'package:nawa/features/profile/data/user_profile_repository.dart';
import 'package:nawa/features/profile/domain/child_profile_record.dart';
import 'package:nawa/features/profile/domain/user_profile_record.dart';

/// In-memory stand-in for [FirestoreUserProfileRepository]. Lets any test
/// that pumps the full app (and therefore can reach the onboarding-sync or
/// profile-restore code paths) run without a real Firestore/Firebase app.
class FakeUserProfileRepository implements UserProfileRepository {
  final Map<String, UserProfileRecord> _users = {};
  final Map<String, ChildProfileRecord> _children = {};
  final Map<String, Set<InterestCategoryType>> _interests = {};

  bool failWrites = false;

  @override
  Future<void> createOrUpdateUserProfile({required String uid, required String email}) async {
    if (failWrites) throw Exception('simulated Firestore failure');
    _users[uid] = UserProfileRecord(uid: uid, email: email, role: 'parent');
  }

  @override
  Future<UserProfileRecord?> getUserProfile(String uid) async => _users[uid];

  @override
  Future<void> createOrUpdateChildProfile({required String uid, required String name, required int age}) async {
    if (failWrites) throw Exception('simulated Firestore failure');
    _children[uid] = ChildProfileRecord(name: name, age: age);
  }

  @override
  Future<ChildProfileRecord?> getChildProfile(String uid) async => _children[uid];

  @override
  Future<void> saveInterests({required String uid, required Set<InterestCategoryType> interests}) async {
    if (failWrites) throw Exception('simulated Firestore failure');
    _interests[uid] = interests;
  }

  @override
  Future<Set<InterestCategoryType>> getInterests(String uid) async => _interests[uid] ?? const {};

  void seedChildProfile(String uid, ChildProfileRecord record) => _children[uid] = record;

  void seedInterests(String uid, Set<InterestCategoryType> interests) => _interests[uid] = interests;
}
