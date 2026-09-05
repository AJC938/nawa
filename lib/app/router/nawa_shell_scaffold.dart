import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/navigation/nawa_bottom_nav.dart';

/// Scaffold for the 4 bottom-nav tabs (Home, Explore, Profile, Parent),
/// each with its own persistent navigation stack via [StatefulNavigationShell].
///
/// This is the entry point into the authenticated, per-child area of the
/// app — but which child is active, and loading that child's real
/// profile/interests/exploration history from Firestore, is already
/// resolved before the shell is ever reached (via `resolveChildEntryRoute`
/// from Welcome/Login/Signup, or explicit selection on the child-selection
/// screen), so there's nothing left to bootstrap here.
class NawaShellScaffold extends StatelessWidget {
  const NawaShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NawaBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
