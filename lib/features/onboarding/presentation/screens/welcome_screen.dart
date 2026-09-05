import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/buttons/nawa_primary_button.dart';
import '../../../../core/widgets/mascot/nawa_mascot_placeholder.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../profile/presentation/state/active_child_controller.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  Future<void> _handleIHaveAnAccount(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authControllerProvider);
    final uid = auth.user?.uid;
    if (auth.status != AuthStatus.authenticated || uid == null) {
      context.go(RoutePaths.login);
      return;
    }
    final route = await resolveChildEntryRoute(ref, uid);
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
              const NawaMascotPlaceholder(size: 180, mood: MascotMood.celebrating),
              const SizedBox(height: NawaSpacing.xxl),
              Text(
                l10n.welcomeHeading,
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: NawaSpacing.md),
              Text(
                l10n.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(),
              NawaPrimaryButton(
                label: l10n.startExploring,
                onPressed: () => context.go(RoutePaths.onboardingIntro),
              ),
              const SizedBox(height: NawaSpacing.md),
              TextButton(
                onPressed: () => _handleIHaveAnAccount(context, ref),
                child: Text(l10n.iHaveAnAccount),
              ),
              const SizedBox(height: NawaSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
