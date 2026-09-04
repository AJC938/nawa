/// A child profile as stored in Firestore (`users/{uid}.child`) — distinct
/// from [ChildProfile], the app's local/mock model, which also carries
/// interests and stats not yet backed by Firestore.
class ChildProfileRecord {
  const ChildProfileRecord({required this.name, required this.age});

  final String name;
  final int age;
}
