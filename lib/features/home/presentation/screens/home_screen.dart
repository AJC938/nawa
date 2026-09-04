import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_radius.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/cards/category_card.dart';
import '../../../../core/widgets/cards/experience_card.dart';
import '../../../../core/widgets/headers/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../experiences/domain/experience_session_state.dart';
import '../../../experiences/presentation/state/experience_catalog_providers.dart';
import '../../../experiences/presentation/state/experience_session_controller.dart';
import '../../../interests/domain/interest_category.dart';
import '../../../profile/presentation/state/child_profile_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final child = ref.watch(childProfileProvider);
    final session = ref.watch(experienceSessionProvider);
    final recommended = ref.watch(recommendedExperiencesProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final continueExperience = session.status == SessionStatus.inProgress && session.experience != null
        ? session.experience!
        : (recommended.isNotEmpty ? recommended.first : null);
    final continueProgress = session.status == SessionStatus.inProgress && session.experience != null ? session.progress : 0.0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.lg),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.homeGreeting(child.name),
                    style: theme.textTheme.headlineMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  tooltip: l10n.navHome,
                  onPressed: () {},
                ),
              ],
            ),
            Text(l10n.homeSubtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: NawaSpacing.xl),
            if (continueExperience != null) ...[
              SectionHeader(title: l10n.continueExploring),
              const SizedBox(height: NawaSpacing.md),
              _ContinueExploringCard(
                title: continueExperience.title.resolve(Localizations.localeOf(context)),
                categoryLabel: continueExperience.category.label(l10n),
                icon: continueExperience.illustrationIcon,
                progress: continueProgress,
                onTap: () => context.push(RoutePaths.experiencePath(continueExperience.id)),
              ),
              const SizedBox(height: NawaSpacing.xxl),
            ],
            SectionHeader(title: l10n.recommendedForYou, actionLabel: l10n.seeAll, onAction: () => context.go(RoutePaths.explore)),
            const SizedBox(height: NawaSpacing.md),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recommended.length,
                separatorBuilder: (_, _) => const SizedBox(width: NawaSpacing.md),
                itemBuilder: (context, index) {
                  final experience = recommended[index];
                  return ExperienceCard(
                    title: experience.title.resolve(Localizations.localeOf(context)),
                    categoryLabel: experience.category.label(l10n),
                    metaLabel: isArabic ? experience.durationLabel(true) : experience.durationLabel(false),
                    icon: experience.illustrationIcon,
                    color: experience.category.color,
                    imageAsset: experience.imageAsset,
                    onTap: () => context.push(RoutePaths.experiencePath(experience.id)),
                  );
                },
              ),
            ),
            const SizedBox(height: NawaSpacing.xxl),
            SectionHeader(title: l10n.yourInterests),
            const SizedBox(height: NawaSpacing.sm),
            SizedBox(
              height: 108,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: InterestCategoryType.values.length,
                itemBuilder: (context, index) {
                  final category = InterestCategoryType.values[index];
                  return CategoryCard(
                    label: category.label(l10n),
                    icon: category.icon,
                    color: category.color,
                    onTap: () => context.push(RoutePaths.categoryPath(category.name)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueExploringCard extends StatelessWidget {
  const _ContinueExploringCard({
    required this.title,
    required this.categoryLabel,
    required this.icon,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String categoryLabel;
  final IconData icon;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NawaRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(NawaSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [NawaColors.primary, NawaColors.primaryDark]),
          borderRadius: BorderRadius.circular(NawaRadius.lg),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 28, backgroundColor: Colors.white.withValues(alpha: 0.2), child: Icon(icon, color: Colors.white)),
            const SizedBox(width: NawaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(categoryLabel, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                  if (progress > 0) ...[
                    const SizedBox(height: NawaSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(NawaRadius.pill),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(NawaColors.secondary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
