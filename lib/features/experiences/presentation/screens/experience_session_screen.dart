import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_radius.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/buttons/nawa_primary_button.dart';
import '../../../../core/widgets/indicators/nawa_progress_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../interests/domain/interest_category.dart';
import '../../domain/experience_session_state.dart';
import '../state/experience_session_controller.dart';

class ExperienceSessionScreen extends ConsumerStatefulWidget {
  const ExperienceSessionScreen({super.key, required this.experienceId});

  final String experienceId;

  @override
  ConsumerState<ExperienceSessionScreen> createState() => _ExperienceSessionScreenState();
}

class _ExperienceSessionScreenState extends ConsumerState<ExperienceSessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(experienceSessionProvider);
      if (current.experience?.id != widget.experienceId) {
        ref.read(experienceSessionProvider.notifier).start(widget.experienceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final session = ref.watch(experienceSessionProvider);
    final experience = session.experience;

    if (experience == null || experience.id != widget.experienceId) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (session.status == SessionStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(RoutePaths.experienceCompletePath(experience.id));
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = experience.questions[session.currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NawaProgressBar(value: session.progress, color: experience.category.color),
                      const SizedBox(height: NawaSpacing.sm),
                      Text(
                        l10n.questionProgress(session.currentQuestionIndex + 1, experience.questions.length),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: NawaSpacing.xl),
                      Text(question.prompt.resolve(locale), style: theme.textTheme.headlineMedium),
                      const SizedBox(height: NawaSpacing.xl),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: experience.category.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(NawaRadius.lg),
                            ),
                            alignment: Alignment.center,
                            child: Icon(experience.illustrationIcon, size: 64, color: experience.category.color),
                          ),
                        ),
                      ),
                      const SizedBox(height: NawaSpacing.xl),
                      for (final option in question.options)
                        Padding(
                          padding: const EdgeInsets.only(bottom: NawaSpacing.md),
                          child: _OptionRow(
                            label: option.label.resolve(locale),
                            selected: session.selectedOptionId == option.id,
                            feedback: session.selectedOptionId == option.id ? session.feedback : OptionFeedback.none,
                            onTap: () => ref.read(experienceSessionProvider.notifier).selectOption(option.id),
                          ),
                        ),
                      if (session.feedback == OptionFeedback.tryAgain)
                        Padding(
                          padding: const EdgeInsets.only(bottom: NawaSpacing.md),
                          child: Text(
                            l10n.tryAgainFeedback,
                            style: theme.textTheme.bodyMedium?.copyWith(color: NawaColors.warning, fontWeight: FontWeight.w600),
                          ),
                        ),
                      if (session.feedback == OptionFeedback.positive)
                        Padding(
                          padding: const EdgeInsets.only(bottom: NawaSpacing.md),
                          child: Text(
                            l10n.positiveFeedback,
                            style: theme.textTheme.bodyMedium?.copyWith(color: NawaColors.success, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: NawaSpacing.xl, top: NawaSpacing.sm),
                child: NawaPrimaryButton(
                  label: l10n.continueLabel,
                  onPressed: session.feedback == OptionFeedback.positive
                      ? () => ref.read(experienceSessionProvider.notifier).continueToNext()
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.label, required this.selected, required this.feedback, required this.onTap});

  final String label;
  final bool selected;
  final OptionFeedback feedback;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color borderColor = NawaColors.border;
    Widget trailing = const SizedBox(width: 24, height: 24);
    if (selected) {
      switch (feedback) {
        case OptionFeedback.positive:
          borderColor = NawaColors.success;
          trailing = const Icon(Icons.check_circle_rounded, color: NawaColors.success);
          break;
        case OptionFeedback.tryAgain:
          borderColor = NawaColors.warning;
          trailing = const Icon(Icons.refresh_rounded, color: NawaColors.warning);
          break;
        case OptionFeedback.none:
          borderColor = NawaColors.primary;
          trailing = const Icon(Icons.radio_button_checked_rounded, color: NawaColors.primary);
          break;
      }
    } else {
      trailing = const Icon(Icons.radio_button_unchecked_rounded, color: NawaColors.textMuted);
    }

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NawaRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.lg, vertical: NawaSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(NawaRadius.md),
            color: NawaColors.surface,
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
