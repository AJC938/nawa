import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/cards/interest_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../interests/domain/interest_category.dart';
import '../state/onboarding_controller.dart';
import '../widgets/onboarding_scaffold.dart';

class OnboardingInterestsScreen extends ConsumerWidget {
  const OnboardingInterestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final onboarding = ref.watch(onboardingProvider);

    return OnboardingScaffold(
      continueLabel: l10n.continueLabel,
      onContinue: onboarding.canContinueFromInterests
          ? () {
              ref.read(onboardingProvider.notifier).complete();
              context.go(RoutePaths.onboardingComplete);
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: NawaSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.onboardingInterestsTitle, style: theme.textTheme.headlineMedium),
            const SizedBox(height: NawaSpacing.sm),
            Text(l10n.onboardingInterestsSubtitle, style: theme.textTheme.bodyLarge),
            const SizedBox(height: NawaSpacing.xl),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: NawaSpacing.md,
              mainAxisSpacing: NawaSpacing.md,
              childAspectRatio: 1.15,
              children: [
                for (final category in InterestCategoryType.values)
                  InterestCard(
                    label: category.label(l10n),
                    icon: category.icon,
                    color: category.color,
                    selected: onboarding.selectedInterests.contains(category),
                    onTap: () => ref.read(onboardingProvider.notifier).toggleInterest(category),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
