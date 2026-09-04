import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/mascot/nawa_mascot_placeholder.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/onboarding_scaffold.dart';

class OnboardingIntroScreen extends StatelessWidget {
  const OnboardingIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return OnboardingScaffold(
      continueLabel: l10n.continueLabel,
      stepIndex: 0,
      stepCount: 4,
      showBack: false,
      onContinue: () => context.go(RoutePaths.onboardingName),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: NawaSpacing.xxl),
        child: Column(
          children: [
            const NawaMascotPlaceholder(size: 160),
            const SizedBox(height: NawaSpacing.xxl),
            Text(l10n.onboardingIntroTitle, style: theme.textTheme.headlineLarge, textAlign: TextAlign.center),
            const SizedBox(height: NawaSpacing.md),
            Text(l10n.onboardingIntroSubtitle, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
