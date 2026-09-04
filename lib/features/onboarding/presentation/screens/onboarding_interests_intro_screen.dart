import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../interests/domain/interest_category.dart';
import '../widgets/onboarding_scaffold.dart';

class OnboardingInterestsIntroScreen extends StatelessWidget {
  const OnboardingInterestsIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return OnboardingScaffold(
      continueLabel: l10n.continueLabel,
      stepIndex: 3,
      stepCount: 4,
      onContinue: () => context.go(RoutePaths.onboardingInterests),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: NawaSpacing.xxl),
        child: Column(
          children: [
            Text(l10n.onboardingInterestsIntroTitle, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: NawaSpacing.md),
            Text(l10n.onboardingInterestsIntroBody, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: NawaSpacing.xxl),
            Wrap(
              spacing: NawaSpacing.md,
              runSpacing: NawaSpacing.md,
              alignment: WrapAlignment.center,
              children: [
                for (final category in InterestCategoryType.values)
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: category.color.withValues(alpha: 0.15),
                    child: Icon(category.icon, color: category.color),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
