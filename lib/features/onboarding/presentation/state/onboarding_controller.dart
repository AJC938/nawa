import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../interests/domain/interest_category.dart';
import '../../../interests/presentation/state/interest_profile_controller.dart';
import '../../../profile/data/user_profile_repository.dart';
import '../../../profile/presentation/state/active_child_controller.dart';
import '../../../profile/presentation/state/child_profile_controller.dart';
import '../../../profile/presentation/state/children_controller.dart';
import '../../domain/onboarding_state.dart';

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void goTo(OnboardingStep step) => state = state.copyWith(step: step);

  void setName(String name) => state = state.copyWith(childName: name);

  void setAge(int age) => state = state.copyWith(age: age);

  void toggleInterest(InterestCategoryType category) {
    final next = {...state.selectedInterests};
    if (!next.add(category)) next.remove(category);
    state = state.copyWith(selectedInterests: next);
  }

  /// Applies the collected answers to the real app state (child profile +
  /// interest profile) and marks onboarding as finished.
  void complete() {
    ref.read(childProfileProvider.notifier).applyOnboarding(
          name: state.childName.trim().isEmpty ? 'Explorer' : state.childName.trim(),
          age: state.age ?? 8,
          interests: state.selectedInterests,
        );
    // Pre-Firestore local state: no exploration records exist yet, so this
    // is just the selected-interest baseline. Once the authenticated area
    // loads, ChildProfileController.restoreFromFirestore recalculates the
    // real profile from Firestore source data and replaces this wholesale.
    ref.read(interestProfileProvider.notifier).recalculate(selectedInterests: state.selectedInterests, explorations: const []);
    state = state.copyWith(completed: true, step: OnboardingStep.complete);
  }

  void reset() => state = const OnboardingState();

  /// Persists the completed onboarding as a NEW child under the
  /// authenticated parent's Firestore account, and makes it the active
  /// child. A no-op if onboarding hasn't been completed, already synced, or
  /// nobody is authenticated yet — callers must not write an orphan child
  /// before authentication.
  ///
  /// This is also how an already-authenticated parent adds another child
  /// later (re-entering this same onboarding wizard from Settings): every
  /// successful run always creates one new child, it never overwrites an
  /// existing one, so siblings never collide.
  ///
  /// Returns true if there was nothing to do or the write succeeded; false
  /// only on a genuine write failure, so callers can hold off navigating
  /// into the authenticated app until the data is actually saved.
  Future<bool> syncToFirestoreIfNeeded() async {
    if (!state.completed || state.syncStatus == OnboardingSyncStatus.synced) return true;

    final auth = ref.read(authControllerProvider);
    final user = auth.user;
    if (auth.status != AuthStatus.authenticated || user == null) return false;

    state = state.copyWith(syncStatus: OnboardingSyncStatus.syncing);
    try {
      final child = ref.read(childProfileProvider);
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.createOrUpdateUserProfile(uid: user.uid, email: user.email ?? '');
      final childId = await repository.createChild(uid: user.uid, name: child.name, age: child.age, interests: child.interests);
      await ref.read(activeChildIdProvider.notifier).selectChild(uid: user.uid, childId: childId);
      await ref.read(childrenProvider.notifier).loadChildren(user.uid);
      // This wizard run's data is now fully persisted (as the new child,
      // already active) — fully reset back to the fresh default rather than
      // leaving completed/synced flags set. Otherwise a LATER, unrelated
      // login later in the same app session would misread this stale
      // "just completed onboarding" state and wrongly skip the normal
      // (zero/one/many-children) sign-in resolution.
      state = const OnboardingState();
      return true;
    } catch (_) {
      state = state.copyWith(syncStatus: OnboardingSyncStatus.error);
      return false;
    }
  }
}

final onboardingProvider = NotifierProvider<OnboardingController, OnboardingState>(OnboardingController.new);
