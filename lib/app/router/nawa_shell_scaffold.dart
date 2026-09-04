import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/navigation/nawa_bottom_nav.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../../features/experiences/data/exploration_repository.dart';
import '../../features/profile/presentation/state/child_profile_controller.dart';

/// Scaffold for the 4 bottom-nav tabs (Home, Explore, Profile, Parent),
/// each with its own persistent navigation stack via [StatefulNavigationShell].
///
/// This is the entry point into the authenticated area, so it's also where
/// the real child profile (name/age/interests) and completed-experience
/// count are restored from Firestore (once per mount) — otherwise a
/// returning parent would keep seeing the local default/mock values.
class NawaShellScaffold extends ConsumerStatefulWidget {
  const NawaShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<NawaShellScaffold> createState() => _NawaShellScaffoldState();
}

class _NawaShellScaffoldState extends ConsumerState<NawaShellScaffold> {
  @override
  void initState() {
    super.initState();
    final auth = ref.read(authControllerProvider);
    final uid = auth.status == AuthStatus.authenticated ? auth.user?.uid : null;
    if (uid != null) {
      ref.read(childProfileProvider.notifier).restoreFromFirestore(uid);
      _restoreCompletedExperiences(uid);
    }
  }

  Future<void> _restoreCompletedExperiences(String uid) async {
    final completed = await ref.read(explorationRepositoryProvider).getCompletedExperiences(uid);
    if (!mounted) return;
    ref.read(childProfileProvider.notifier).setExperiencesCompleted(completed.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NawaBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
      ),
    );
  }
}
