import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/buttons/nawa_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/state/active_child_controller.dart';
import '../state/auth_controller.dart';

class AccountCreatedScreen extends ConsumerWidget {
  const AccountCreatedScreen({super.key});

  Future<void> _goToDashboard(BuildContext context, WidgetRef ref) async {
    // Onboarding already created (and activated) the child that led here in
    // the common case; this only differs if the parent signed up without
    // ever completing onboarding, in which case there's nothing active yet.
    final uid = ref.read(authControllerProvider).user!.uid;
    final route = ref.read(activeChildIdProvider) != null ? RoutePaths.parent : await resolveChildEntryRoute(ref, uid);
    if (context.mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(color: NawaColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
              ),
              const SizedBox(height: NawaSpacing.xxl),
              Text(l10n.accountCreatedTitle, style: theme.textTheme.displayMedium, textAlign: TextAlign.center),
              const SizedBox(height: NawaSpacing.md),
              Text(l10n.accountCreatedSubtitle, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
              const Spacer(),
              NawaPrimaryButton(label: l10n.goToDashboard, onPressed: () => _goToDashboard(context, ref)),
              const SizedBox(height: NawaSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
