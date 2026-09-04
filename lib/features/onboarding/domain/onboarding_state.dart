import '../../interests/domain/interest_category.dart';

enum OnboardingStep { intro, name, age, interestsIntro, interests, complete }

/// Whether the just-completed onboarding has been persisted to Firestore
/// for the authenticated parent yet.
enum OnboardingSyncStatus { idle, syncing, synced, error }

class OnboardingState {
  const OnboardingState({
    this.step = OnboardingStep.intro,
    this.childName = '',
    this.age,
    this.selectedInterests = const {},
    this.completed = false,
    this.syncStatus = OnboardingSyncStatus.idle,
  });

  final OnboardingStep step;
  final String childName;
  final int? age;
  final Set<InterestCategoryType> selectedInterests;
  final bool completed;
  final OnboardingSyncStatus syncStatus;

  bool get canContinueFromName => childName.trim().isNotEmpty;
  bool get canContinueFromAge => age != null;
  bool get canContinueFromInterests => selectedInterests.isNotEmpty;

  OnboardingState copyWith({
    OnboardingStep? step,
    String? childName,
    int? age,
    Set<InterestCategoryType>? selectedInterests,
    bool? completed,
    OnboardingSyncStatus? syncStatus,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      childName: childName ?? this.childName,
      age: age ?? this.age,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      completed: completed ?? this.completed,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
