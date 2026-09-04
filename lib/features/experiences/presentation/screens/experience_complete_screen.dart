import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/buttons/nawa_primary_button.dart';
import '../../../../core/widgets/buttons/nawa_secondary_button.dart';
import '../../../../core/widgets/chips/interest_chip.dart';
import '../../../../core/widgets/states/error_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../interests/domain/interest_category.dart';
import '../state/experience_catalog_providers.dart';

class ExperienceCompleteScreen extends ConsumerWidget {
  const ExperienceCompleteScreen({super.key, required this.experienceId});

  final String experienceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final experience = ref.watch(experienceByIdProvider(experienceId));

    if (experience == null) {
      return Scaffold(appBar: AppBar(), body: ErrorStateView(onRetry: () => context.go(RoutePaths.home)));
    }

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(color: NawaColors.secondary, shape: BoxShape.circle),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 56),
              ),
              const SizedBox(height: NawaSpacing.xl),
              Text(l10n.experienceCompleteTitle, style: theme.textTheme.displayMedium, textAlign: TextAlign.center),
              const SizedBox(height: NawaSpacing.sm),
              Text(
                l10n.experienceCompleteSubtitle(experience.title.resolve(locale)),
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NawaSpacing.xl),
              Text(l10n.youExplored, style: theme.textTheme.titleMedium),
              const SizedBox(height: NawaSpacing.md),
              Wrap(
                spacing: NawaSpacing.sm,
                runSpacing: NawaSpacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  for (final tag in experience.exploresTags)
                    NawaChip(label: tag.resolve(locale), icon: Icons.auto_awesome_rounded, color: experience.category.color),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(child: NawaSecondaryButton(label: l10n.exploreMore, onPressed: () => context.go(RoutePaths.explore))),
                  const SizedBox(width: NawaSpacing.md),
                  Expanded(child: NawaPrimaryButton(label: l10n.viewMyInterests, onPressed: () => context.push(RoutePaths.interests))),
                ],
              ),
              const SizedBox(height: NawaSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
