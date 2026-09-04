import 'package:flutter/material.dart';

import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/buttons/nawa_primary_button.dart';

/// Shared layout for onboarding steps: optional back button, scrollable
/// content, step-progress dots, and a pinned bottom Continue button.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.child,
    required this.continueLabel,
    this.onContinue,
    this.stepIndex,
    this.stepCount,
    this.showBack = true,
  });

  final Widget child;
  final String continueLabel;
  final VoidCallback? onContinue;
  final int? stepIndex;
  final int? stepCount;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: showBack && canPop
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl),
          child: Column(
            children: [
              Expanded(child: SingleChildScrollView(child: child)),
              if (stepIndex != null && stepCount != null) ...[
                _StepDots(stepIndex: stepIndex!, stepCount: stepCount!),
                const SizedBox(height: NawaSpacing.lg),
              ],
              Padding(
                padding: const EdgeInsets.only(bottom: NawaSpacing.xl),
                child: NawaPrimaryButton(label: continueLabel, onPressed: onContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.stepIndex, required this.stepCount});

  final int stepIndex;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(stepCount, (i) {
        final active = i == stepIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? NawaColors.primary : NawaColors.border,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
