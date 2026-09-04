import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/onboarding_state.dart';
import '../state/onboarding_controller.dart';
import '../widgets/onboarding_scaffold.dart';

const _ages = [6, 7, 8, 9, 10, 11, 12];

class OnboardingAgeScreen extends ConsumerWidget {
  const OnboardingAgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final onboarding = ref.watch(onboardingProvider);

    return OnboardingScaffold(
      continueLabel: l10n.continueLabel,
      stepIndex: 2,
      stepCount: 4,
      onContinue: onboarding.canContinueFromAge
          ? () {
              ref.read(onboardingProvider.notifier).goTo(OnboardingStep.interestsIntro);
              context.go(RoutePaths.onboardingInterestsIntro);
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: NawaSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.onboardingAgeTitle, style: theme.textTheme.headlineMedium),
            const SizedBox(height: NawaSpacing.sm),
            Text(l10n.onboardingAgeSubtitle, style: theme.textTheme.bodyLarge),
            const SizedBox(height: NawaSpacing.xl),
            Wrap(
              spacing: NawaSpacing.md,
              runSpacing: NawaSpacing.md,
              children: [
                for (final age in _ages) _AgeChip(age: age, selected: onboarding.age == age),
                _AgeChip(age: 13, selected: onboarding.age != null && onboarding.age! >= 13, label: l10n.age13Plus, value: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeChip extends ConsumerWidget {
  const _AgeChip({required this.age, required this.selected, this.label, this.value});

  final int age;
  final bool selected;
  final String? label;
  final int? value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => ref.read(onboardingProvider.notifier).setAge(value ?? age),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? NawaColors.primary : NawaColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: selected ? NawaColors.primary : NawaColors.border),
          ),
          child: Text(
            label ?? '$age',
            style: theme.textTheme.titleMedium?.copyWith(color: selected ? Colors.white : NawaColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
