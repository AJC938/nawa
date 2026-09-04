import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/cards/category_card.dart';
import '../../../../core/widgets/cards/experience_card.dart';
import '../../../../core/widgets/chips/interest_chip.dart';
import '../../../../core/widgets/headers/section_header.dart';
import '../../../../core/widgets/states/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../experiences/presentation/state/experience_catalog_providers.dart';
import '../../../interests/domain/interest_category.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _search = TextEditingController();
  InterestCategoryType? _filter;
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final all = ref.watch(allExperiencesProvider);
    final featured = ref.watch(featuredExperiencesProvider);

    final filtered = all.where((e) {
      final matchesCategory = _filter == null || e.category == _filter;
      final matchesQuery = _query.isEmpty || e.title.resolve(locale).toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
    final isSearching = _query.isNotEmpty || _filter != null;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.lg),
          children: [
            Text(l10n.exploreTitle, style: theme.textTheme.displayMedium),
            const SizedBox(height: NawaSpacing.lg),
            TextField(
              controller: _search,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: NawaSpacing.md),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: NawaSpacing.sm),
                    child: NawaChip(label: l10n.filterAll, selected: _filter == null, onTap: () => setState(() => _filter = null)),
                  ),
                  for (final category in InterestCategoryType.values)
                    Padding(
                      padding: const EdgeInsets.only(right: NawaSpacing.sm),
                      child: NawaChip(
                        label: category.label(l10n),
                        color: category.color,
                        selected: _filter == category,
                        onTap: () => setState(() => _filter = _filter == category ? null : category),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: NawaSpacing.xl),
            if (isSearching) ...[
              SectionHeader(title: l10n.searchResults),
              const SizedBox(height: NawaSpacing.md),
              if (filtered.isEmpty)
                EmptyState(title: l10n.emptyExperiencesTitle, message: l10n.emptyExperiencesSubtitle)
              else
                ...filtered.map(
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
            ] else ...[
              SectionHeader(title: l10n.featured),
              const SizedBox(height: NawaSpacing.md),
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (_, _) => const SizedBox(width: NawaSpacing.md),
                  itemBuilder: (context, index) {
                    final experience = featured[index];
                    return ExperienceCard(
                      title: experience.title.resolve(locale),
                      categoryLabel: experience.category.label(l10n),
                      metaLabel: experience.durationLabel(locale.languageCode == 'ar'),
                      icon: experience.illustrationIcon,
                      color: experience.category.color,
                      imageAsset: experience.imageAsset,
                      onTap: () => context.push(RoutePaths.experiencePath(experience.id)),
                    );
                  },
                ),
              ),
              const SizedBox(height: NawaSpacing.xxl),
              SectionHeader(title: l10n.categoriesLabel),
              const SizedBox(height: NawaSpacing.sm),
              Wrap(
                children: [
                  for (final category in InterestCategoryType.values)
                    CategoryCard(
                      label: category.label(l10n),
                      icon: category.icon,
                      color: category.color,
                      onTap: () => context.push(RoutePaths.categoryPath(category.name)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
