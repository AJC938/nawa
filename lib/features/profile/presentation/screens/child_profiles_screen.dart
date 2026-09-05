import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/buttons/nawa_primary_button.dart';
import '../../../../core/widgets/headers/nawa_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../onboarding/presentation/state/onboarding_controller.dart';
import '../../domain/child_summary.dart';
import '../state/active_child_controller.dart';
import '../state/children_controller.dart';

/// Lists the parent's children and lets them pick which one is active, or
/// add another. Used in two places with the same list/select/add logic:
///
/// - [isEntryGate] true: the required "which child?" step shown right
///   after login/signup when the account has more than one child.
/// - [isEntryGate] false: the normal Settings -> "Child Profiles" screen,
///   reachable any time to switch the active child or add a new one.
class ChildProfilesScreen extends ConsumerStatefulWidget {
  const ChildProfilesScreen({super.key, this.isEntryGate = false});

  final bool isEntryGate;

  @override
  ConsumerState<ChildProfilesScreen> createState() => _ChildProfilesScreenState();
}

class _ChildProfilesScreenState extends ConsumerState<ChildProfilesScreen> {
  @override
  void initState() {
    super.initState();
    final uid = ref.read(authControllerProvider).user?.uid;
    if (uid != null) ref.read(childrenProvider.notifier).loadChildren(uid);
  }

  Future<void> _select(ChildSummary child) async {
    final uid = ref.read(authControllerProvider).user?.uid;
    if (uid == null) return;
    await ref.read(activeChildIdProvider.notifier).selectChild(uid: uid, childId: child.id);
    if (!mounted) return;
    if (widget.isEntryGate) {
      context.go(RoutePaths.parent);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.parent);
    }
  }

  void _addChild() {
    // A fresh wizard run for a NEW child — reset first so a previous
    // child's completed/synced state can't make this run a silent no-op.
    ref.read(onboardingProvider.notifier).reset();
    context.go(RoutePaths.onboardingIntro);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final children = ref.watch(childrenProvider);
    final activeChildId = ref.watch(activeChildIdProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isEntryGate,
        title: Text(widget.isEntryGate ? l10n.selectChildTitle : l10n.settingsChildProfiles),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.lg),
          children: [
            if (widget.isEntryGate) ...[
              Text(l10n.selectChildSubtitle, style: theme.textTheme.bodyLarge),
              const SizedBox(height: NawaSpacing.lg),
            ],
            for (final child in children)
              Card(
                margin: const EdgeInsets.only(bottom: NawaSpacing.sm),
                child: ListTile(
                  leading: NawaAvatar(name: child.name, radius: 24),
                  title: Text(child.name, style: theme.textTheme.titleMedium),
                  subtitle: Text(l10n.yearsOld(child.age)),
                  trailing: child.id == activeChildId
                      ? const Icon(Icons.check_circle_rounded, color: NawaColors.primary)
                      : const Icon(Icons.chevron_right_rounded, color: NawaColors.textMuted),
                  onTap: () => _select(child),
                ),
              ),
            if (children.isEmpty) Text(l10n.noChildProfilesYet, style: theme.textTheme.bodyMedium),
            const SizedBox(height: NawaSpacing.lg),
            NawaPrimaryButton(label: l10n.addChild, onPressed: _addChild),
          ],
        ),
      ),
    );
  }
}
