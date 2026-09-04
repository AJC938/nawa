import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/cards/experience_card.dart';
import '../../../../core/widgets/states/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../experiences/presentation/state/experience_catalog_providers.dart';
import '../../../interests/domain/interest_category.dart';
import '../../data/mock_category_copy.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final category = InterestCategoryType.values.byName(categoryId);
    final experiences = ref.watch(experiencesByCategoryProvider(category));

    return Scaffold(
      appBar: AppBar(title: Text(category.label(l10n))),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.lg),
          children: [
            Text(
              mockCategoryDescriptions[category]?.resolve(locale) ?? '',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: NawaSpacing.sm),
            Text(l10n.experienceCount(experiences.length), style: theme.textTheme.bodyMedium),
            const SizedBox(height: NawaSpacing.lg),
            if (experiences.isEmpty)
              EmptyState(title: l10n.emptyExperiencesTitle, message: l10n.emptyExperiencesSubtitle)
            else
              ...experiences.map(
                (experience) => Padding(
                  padding: const EdgeInsets.only(bottom: NawaSpacing.md),
                  child: ExperienceCard(
                    variant: ExperienceCardVariant.list,
                    title: experience.title.resolve(locale),
                    categoryLabel: experience.category.label(l10n),
                    metaLabel: '${experience.ageRangeLabel} · ${experience.durationLabel(locale.languageCode == 'ar')}',
                    icon: experience.illustrationIcon,
                    color: experience.category.color,
                    imageAsset: experience.imageAsset,
                    onTap: () => context.push(RoutePaths.experiencePath(experience.id)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
