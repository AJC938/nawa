import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/route_paths.dart';
import 'child_profile_controller.dart';
import 'children_controller.dart';

/// Which child, among the authenticated parent's [childrenProvider] list,
/// every child-facing screen (Home, Explore, experience tracking, My
/// Interests, Recommendations, Parent) currently reads and writes for.
///
/// The Firebase UID identifies the parent account; this id identifies
/// WHICH child within that account is active right now — never the
/// child's name or age, and never a local-only id that would be lost on
/// restart (it's the real Firestore document id).
class ActiveChildController extends Notifier<String?> {
  @override
  String? build() => null;

  /// Selects [childId] and loads that child's real profile/interests/
  /// exploration history into the existing shared providers
  /// ([childProfileProvider] etc.) — the same reused business-logic path
  /// every other phase already depends on, just scoped by child now.
  Future<void> selectChild({required String uid, required String childId}) async {
    state = childId;
    await ref.read(childProfileProvider.notifier).restoreFromFirestore(uid: uid, childId: childId);
  }

  /// Clears the active child without touching Firestore — used on logout so
  /// a subsequent login never starts from a stale sibling's selection.
  void clear() => state = null;
}

final activeChildIdProvider = NotifierProvider<ActiveChildController, String?>(ActiveChildController.new);

/// Loads the parent's children and decides where to go next — reused by
/// Welcome ("I have an account"), Login, and Signup so this branching
/// logic exists in exactly one place:
///
/// - zero children  -> the onboarding flow, to create the first one
/// - exactly one    -> auto-selected as active, straight into the app
/// - more than one  -> the child-selection screen
Future<String> resolveChildEntryRoute(WidgetRef ref, String uid) async {
  final children = await ref.read(childrenProvider.notifier).loadChildren(uid);
  if (children.isEmpty) return RoutePaths.onboardingIntro;
  if (children.length == 1) {
    await ref.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: children.single.id);
    return RoutePaths.parent;
  }
  return RoutePaths.selectChild;
}
