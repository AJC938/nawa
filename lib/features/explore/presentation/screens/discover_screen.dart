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

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    // The full personalized ranking, highest-scoring experience first — the
    // same RecommendationEngine output Home's "Recommended for you" takes
    // its top slice from.
    final ranked = ref.watch(rankedExperiencesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.discoverTitle)),
      body: SafeArea(
        top: false,
        child: ranked.isEmpty
            ? EmptyState(title: l10n.emptyExperiencesTitle, message: l10n.emptyExperiencesSubtitle)
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.lg),
                children: [
                  Text(l10n.discoverSubtitle, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: NawaSpacing.lg),
                  for (final result in ranked)
                    Padding(
                      padding: const EdgeInsets.only(bottom: NawaSpacing.md),
                      child: ExperienceCard(
                        variant: ExperienceCardVariant.list,
                        title: result.experience.title.resolve(locale),
                        categoryLabel: result.experience.category.label(l10n),
                        metaLabel: '${result.experience.ageRangeLabel} · ${result.experience.durationLabel(locale.languageCode == 'ar')}',
                        icon: result.experience.illustrationIcon,
                        color: result.experience.category.color,
                        imageAsset: result.experience.imageAsset,
                        onTap: () => context.push(RoutePaths.experiencePath(result.experience.id)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
