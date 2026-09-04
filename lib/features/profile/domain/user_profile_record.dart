/// A parent's Firestore-backed profile — the Firebase Auth UID is the
/// `users` document id, so it is always the source of ownership.
class UserProfileRecord {
  const UserProfileRecord({required this.uid, required this.email, required this.role});

  final String uid;
  final String email;
  final String role;
}
