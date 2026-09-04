import '../../interests/domain/interest_category.dart';

/// The active child profile. Mock/local only — a later phase can back
/// this with a Firebase-backed repository behind the same shape.
class ChildProfile {
  const ChildProfile({
    required this.name,
    required this.age,
    this.interests = const {},
    this.experiencesCompleted = 0,
    this.streakDays = 0,
  });

  final String name;
  final int age;
  final Set<InterestCategoryType> interests;
  final int experiencesCompleted;
  final int streakDays;

  ChildProfile copyWith({
    String? name,
    int? age,
    Set<InterestCategoryType>? interests,
    int? experiencesCompleted,
    int? streakDays,
  }) {
    return ChildProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      experiencesCompleted: experiencesCompleted ?? this.experiencesCompleted,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}
