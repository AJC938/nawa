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

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isAuthenticated = ref.watch(authControllerProvider).status == AuthStatus.authenticated;

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
                onPressed: () => context.go(isAuthenticated ? RoutePaths.parent : RoutePaths.login),
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
