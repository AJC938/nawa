import '../../interests/domain/interest_category.dart';

/// One child under a parent account, as listed from
/// `users/{uid}/children`. The Firestore document id (never the child's
/// name or age) is the stable [id] used to scope all child-specific data.
class ChildSummary {
  const ChildSummary({required this.id, required this.name, required this.age, this.interests = const {}});

  final String id;
  final String name;
  final int age;
  final Set<InterestCategoryType> interests;
}
