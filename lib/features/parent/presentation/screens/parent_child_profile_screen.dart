import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/chips/interest_chip.dart';
import '../../../../core/widgets/headers/nawa_avatar.dart';
import '../../../../core/widgets/headers/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../interests/domain/interest_category.dart';
import '../../../interests/domain/interest_level.dart';
import '../../../interests/presentation/state/interest_profile_controller.dart';
import '../../../profile/presentation/state/child_profile_controller.dart';
import '../state/parent_providers.dart';

class ParentChildProfileScreen extends ConsumerWidget {
  const ParentChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final child = ref.watch(childProfileProvider);
    final profile = ref.watch(interestProfileProvider);
    final summary = ref.watch(parentSummaryProvider);

    void comingSoon() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));

    return Scaffold(
      appBar: AppBar(
        title: Text(child.name),
        actions: [IconButton(icon: const Icon(Icons.edit_outlined), onPressed: comingSoon)],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.lg),
          children: [
            Center(
              child: Column(
                children: [
                  NawaAvatar(name: child.name, radius: 40),
                  const SizedBox(height: NawaSpacing.md),
                  Text(child.name, style: theme.textTheme.headlineMedium),
                  Text(l10n.yearsOld(child.age), style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: NawaSpacing.xl),
            Row(
              children: [
                Expanded(child: _SummaryTile(label: l10n.completedExperiencesLabel, value: '${summary.experiencesCompleted}')),
                const SizedBox(width: NawaSpacing.md),
                Expanded(child: _SummaryTile(label: l10n.timeSpentExploring, value: summary.timeSpentLabel)),
              ],
            ),
            const SizedBox(height: NawaSpacing.xl),
            SectionHeader(title: l10n.yourInterests),
            const SizedBox(height: NawaSpacing.sm),
            Wrap(
              spacing: NawaSpacing.sm,
              runSpacing: NawaSpacing.sm,
              children: [
                for (final category in child.interests)
                  NawaChip(
                    label: '${category.label(l10n)} · ${profile[category]!.level.parentLabel(l10n)}',
                    icon: category.icon,
                    color: category.color,
                    selected: true,
                  ),
                if (child.interests.isEmpty)
                  Text(l10n.emptyExperiencesSubtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: NawaSpacing.xl),
            SectionHeader(title: l10n.settingsChildProfiles),
            const SizedBox(height: NawaSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.swap_horiz_rounded, color: NawaColors.textSecondary),
              title: Text(l10n.settingsChildProfiles, style: theme.textTheme.bodyLarge),
              trailing: const Icon(Icons.chevron_right_rounded, color: NawaColors.textMuted),
              onTap: comingSoon,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NawaSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: theme.textTheme.headlineMedium),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
