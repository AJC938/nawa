import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/cards/experience_card.dart';
import '../../../../core/widgets/chips/interest_chip.dart';
import '../../../../core/widgets/headers/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../experiences/data/mock_experiences.dart';
import '../../../experiences/domain/experience.dart';
import '../../domain/interest_category.dart';
import '../../domain/interest_level.dart';
import '../state/interest_profile_controller.dart';

class InterestDetailScreen extends ConsumerWidget {
  const InterestDetailScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final category = InterestCategoryType.values.byName(categoryId);
    final signal = ref.watch(interestProfileProvider)[category]!;
    final completed = signal.completedExperienceIds.map(experienceById).whereType<Experience>().toList();
    final next = experiencesByCategory(category).where((e) => !signal.completedExperienceIds.contains(e.id)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(category.label(l10n))),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.md),
          children: [
            NawaChip(label: signal.level.childLabel(l10n), icon: category.icon, color: category.color, selected: true),
            const SizedBox(height: NawaSpacing.xl),
            if (signal.exploredConcepts.isNotEmpty) ...[
              Text(l10n.youExplored, style: theme.textTheme.titleMedium),
              const SizedBox(height: NawaSpacing.sm),
              Wrap(
                spacing: NawaSpacing.sm,
                runSpacing: NawaSpacing.sm,
                children: [for (final concept in signal.exploredConcepts) NawaChip(label: concept.resolve(locale), color: category.color)],
              ),
              const SizedBox(height: NawaSpacing.xl),
            ],
            SectionHeader(title: l10n.completedExperiencesLabel),
            const SizedBox(height: NawaSpacing.md),
            if (completed.isEmpty)
              Text(l10n.emptyExperiencesSubtitle, style: theme.textTheme.bodyMedium)
            else
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: completed.length,
                  separatorBuilder: (_, _) => const SizedBox(width: NawaSpacing.md),
                  itemBuilder: (context, index) {
                    final experience = completed[index];
                    return ExperienceCard(
                      title: experience.title.resolve(locale),
                      categoryLabel: experience.category.label(l10n),
                      metaLabel: experience.durationLabel(locale.languageCode == 'ar'),
                      icon: experience.illustrationIcon,
                      color: category.color,
                      imageAsset: experience.imageAsset,
                      onTap: () => context.push(RoutePaths.experiencePath(experience.id)),
                    );
                  },
                ),
              ),
            if (next.isNotEmpty) ...[
              const SizedBox(height: NawaSpacing.xl),
              SectionHeader(title: l10n.nextExperience),
              const SizedBox(height: NawaSpacing.md),
              ExperienceCard(
                variant: ExperienceCardVariant.list,
                title: next.first.title.resolve(locale),
                categoryLabel: next.first.category.label(l10n),
                metaLabel: '${next.first.ageRangeLabel} · ${next.first.durationLabel(locale.languageCode == 'ar')}',
                icon: next.first.illustrationIcon,
                color: category.color,
                imageAsset: next.first.imageAsset,
                onTap: () => context.push(RoutePaths.experiencePath(next.first.id)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
