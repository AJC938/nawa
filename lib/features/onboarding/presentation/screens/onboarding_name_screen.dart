import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/inputs/nawa_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/onboarding_state.dart';
import '../state/onboarding_controller.dart';
import '../widgets/onboarding_scaffold.dart';

class OnboardingNameScreen extends ConsumerStatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  ConsumerState<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends ConsumerState<OnboardingNameScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(onboardingProvider).childName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final onboarding = ref.watch(onboardingProvider);

    return OnboardingScaffold(
      continueLabel: l10n.continueLabel,
      stepIndex: 1,
      stepCount: 4,
      onContinue: onboarding.canContinueFromName
          ? () {
              ref.read(onboardingProvider.notifier).goTo(OnboardingStep.age);
              context.go(RoutePaths.onboardingAge);
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: NawaSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.onboardingNameTitle, style: theme.textTheme.headlineMedium),
            const SizedBox(height: NawaSpacing.sm),
            Text(l10n.onboardingNameSubtitle, style: theme.textTheme.bodyLarge),
            const SizedBox(height: NawaSpacing.xl),
            NawaTextField(
              hint: l10n.onboardingNameHint,
              controller: _controller,
              suffixIcon: const Icon(Icons.emoji_emotions_outlined),
              onChanged: (value) => ref.read(onboardingProvider.notifier).setName(value),
            ),
          ],
        ),
      ),
    );
  }
}
