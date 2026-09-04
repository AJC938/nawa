import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_radius.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/cards/parent_summary_card.dart';
import '../../../../core/widgets/headers/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../interests/domain/interest_category.dart';
import '../state/parent_providers.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summary = ref.watch(parentSummaryProvider);
    final maxScore = summary.topInterestScores.values.fold<double>(1, (max, v) => v > max ? v : max);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.lg),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.parentOverviewTitle(summary.childName), style: theme.textTheme.headlineMedium),
                      Text(l10n.parentOverviewSubtitle(summary.childName), style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline_rounded),
                  onPressed: () => context.push(RoutePaths.parentChildProfile),
                ),
              ],
            ),
            const SizedBox(height: NawaSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.md, vertical: NawaSpacing.sm),
              decoration: BoxDecoration(border: Border.all(color: NawaColors.border), borderRadius: BorderRadius.circular(NawaRadius.md)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.thisWeek, style: theme.textTheme.bodyMedium),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: NawaColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: NawaSpacing.xl),
            SectionHeader(
              title: l10n.topInterests,
              actionLabel: l10n.seeAll,
              onAction: () => context.push(RoutePaths.parentInterestSummary),
            ),
            const SizedBox(height: NawaSpacing.lg),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final category in InterestCategoryType.values)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push(RoutePaths.parentInterestDetailPath(category.name)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                height: 96 * ((summary.topInterestScores[category] ?? 0) / maxScore).clamp(0.06, 1.0),
                                decoration: BoxDecoration(
                                  color: category.color,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(NawaRadius.sm)),
                                ),
                              ),
                              const SizedBox(height: NawaSpacing.xs),
                              Icon(category.icon, size: 16, color: category.color),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: NawaSpacing.xxl),
            Row(
              children: [
                ParentSummaryCard(label: l10n.completedExperiencesLabel, value: '${summary.experiencesCompleted}', icon: Icons.task_alt_rounded),
                const SizedBox(width: NawaSpacing.md),
                ParentSummaryCard(label: l10n.timeSpentExploring, value: summary.timeSpentLabel, icon: Icons.schedule_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
