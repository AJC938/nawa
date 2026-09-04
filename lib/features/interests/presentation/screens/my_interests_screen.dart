import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/cards/recommendation_card.dart';
import '../../../../core/widgets/headers/section_header.dart';
import '../../../../core/widgets/indicators/interest_level_row.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/interest_category.dart';
import '../../domain/interest_level.dart';
import '../state/interest_profile_controller.dart';

class MyInterestsScreen extends ConsumerWidget {
  const MyInterestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(interestProfileProvider);
    final ranked = InterestCategoryType.values.toList()..sort((a, b) => profile[b]!.score.compareTo(profile[a]!.score));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myInterestsTitle),
        actions: [IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: () {})],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.md),
          children: [
            Text(l10n.myInterestsSubtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: NawaSpacing.lg),
            for (final category in ranked)
              InterestLevelRow(
                label: category.label(l10n),
                statusLabel: profile[category]!.level.childLabel(l10n),
                icon: category.icon,
                color: category.color,
                progress: profile[category]!.score / 100,
                onTap: () => context.push(RoutePaths.interestDetailPath(category.name)),
              ),
            const SizedBox(height: NawaSpacing.xl),
            SectionHeader(title: l10n.discoverTitle),
            const SizedBox(height: NawaSpacing.md),
            RecommendationCard(
              label: l10n.discoverSubtitle,
              icon: Icons.explore_rounded,
              onTap: () => context.push(RoutePaths.discover),
            ),
          ],
        ),
      ),
    );
  }
}
