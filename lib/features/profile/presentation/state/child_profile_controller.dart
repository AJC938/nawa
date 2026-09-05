import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../experiences/data/exploration_repository.dart';
import '../../../experiences/presentation/state/exploration_history_controller.dart';
import '../../../interests/domain/interest_category.dart';
import '../../../interests/presentation/state/interest_profile_controller.dart';
import '../../data/user_profile_repository.dart';
import '../../domain/child_profile.dart';

/// The active child profile. Seeded with a friendly default so the app
/// looks fully populated even before onboarding is (re-)completed;
/// onboarding overwrites the name/age/interests once finished.
class ChildProfileController extends Notifier<ChildProfile> {
  @override
  ChildProfile build() {
    return const ChildProfile(
      name: 'Omar',
      age: 8,
      interests: {InterestCategoryType.gaming, InterestCategoryType.technology},
      experiencesCompleted: 0,
      streakDays: 1,
    );
  }

  void applyOnboarding({required String name, required int age, required Set<InterestCategoryType> interests}) {
    state = state.copyWith(name: name, age: age, interests: interests);
  }

  /// Restores the real child name/age/interests from Firestore for the
  /// given [uid]'s [childId] — the currently active child, never any
  /// sibling's data. Leaves name/age untouched (e.g. the default) when
  /// there's no saved profile yet, but always recalculates the real
  /// interest profile (via [InterestProfileController.recalculate]) from
  /// whatever interests + exploration records are actually saved for THIS
  /// child — this is the "load real data" entry point the deterministic
  /// scoring engine depends on, replacing any pre-Firestore local profile
  /// wholesale.
  Future<void> restoreFromFirestore({required String uid, required String childId}) async {
    final repository = ref.read(userProfileRepositoryProvider);
    final record = await repository.getChild(uid: uid, childId: childId);
    final interests = await repository.getChildInterests(uid: uid, childId: childId);
    final explorations = await ref.read(explorationRepositoryProvider).getExplorations(uid: uid, childId: childId);

    final completedCount = explorations.where((e) => e.completed).length;
    state = record != null
        ? state.copyWith(name: record.name, age: record.age, interests: interests, experiencesCompleted: completedCount)
        : state.copyWith(interests: interests, experiencesCompleted: completedCount);
    // Cache the raw records once so the recommendation engine can reuse
    // them without a second Firestore read.
    ref.read(explorationHistoryProvider.notifier).setExplorations(explorations);
    ref.read(interestProfileProvider.notifier).recalculate(selectedInterests: interests, explorations: explorations);
  }

  void recordExperienceCompleted() {
    state = state.copyWith(experiencesCompleted: state.experiencesCompleted + 1);
  }

  /// Overwrites the completed-experience count with a real value restored
  /// from Firestore exploration records (e.g. at app/session start), so it
  /// reflects actual history instead of only this session's local count.
  void setExperiencesCompleted(int count) {
    state = state.copyWith(experiencesCompleted: count);
  }
}

final childProfileProvider = NotifierProvider<ChildProfileController, ChildProfile>(ChildProfileController.new);
