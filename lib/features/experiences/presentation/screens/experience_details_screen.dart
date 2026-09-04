import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_radius.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/buttons/nawa_primary_button.dart';
import '../../../../core/widgets/states/error_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../interests/domain/interest_category.dart';
import '../state/experience_catalog_providers.dart';
import '../state/experience_session_controller.dart';

class ExperienceDetailsScreen extends ConsumerStatefulWidget {
  const ExperienceDetailsScreen({super.key, required this.experienceId});

  final String experienceId;

  @override
  ConsumerState<ExperienceDetailsScreen> createState() => _ExperienceDetailsScreenState();
}

class _ExperienceDetailsScreenState extends ConsumerState<ExperienceDetailsScreen> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final experience = ref.watch(experienceByIdProvider(widget.experienceId));

    if (experience == null) {
      return Scaffold(appBar: AppBar(), body: ErrorStateView(onRetry: () => context.pop()));
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(_saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
            onPressed: () => setState(() => _saved = !_saved),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl),
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(NawaRadius.lg),
                child: SvgPicture.asset(
                  experience.imageAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: NawaSpacing.lg),
            Text(experience.title.resolve(locale), style: theme.textTheme.displayMedium),
            const SizedBox(height: NawaSpacing.sm),
            Wrap(
              spacing: NawaSpacing.sm,
              runSpacing: NawaSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Tag(label: experience.category.label(l10n), color: experience.category.color),
                Text(
                  '${experience.ageRangeLabel} · ${experience.durationLabel(locale.languageCode == 'ar')}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: NawaSpacing.lg),
            Text(experience.description.resolve(locale), style: theme.textTheme.bodyLarge),
            const SizedBox(height: NawaSpacing.xl),
            Text(l10n.youWillExplore, style: theme.textTheme.titleMedium),
            const SizedBox(height: NawaSpacing.sm),
            for (final tag in experience.exploresTags)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: experience.category.color, shape: BoxShape.circle)),
                    const SizedBox(width: NawaSpacing.sm),
                    Text(tag.resolve(locale), style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            const SizedBox(height: NawaSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(NawaSpacing.xl),
        child: NawaPrimaryButton(
          label: l10n.startExperience,
          onPressed: () {
            ref.read(experienceSessionProvider.notifier).start(experience.id);
            context.push(RoutePaths.experienceSessionPath(experience.id));
          },
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.md, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(NawaRadius.pill)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
