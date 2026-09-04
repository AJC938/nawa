import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/headers/nawa_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../interests/presentation/state/interest_profile_controller.dart';
import '../state/child_profile_controller.dart';

class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final child = ref.watch(childProfileProvider);
    final interestsCount = ref.watch(interestProfileProvider).values.where((s) => s.score > 20).length;

    void comingSoon() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.lg),
          children: [
            Row(
              children: [
                NawaAvatar(name: child.name, radius: 36),
                const SizedBox(width: NawaSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.name, style: theme.textTheme.headlineMedium),
                      Text(l10n.yearsOld(child.age), style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: comingSoon),
              ],
            ),
            const SizedBox(height: NawaSpacing.xl),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: NawaSpacing.lg),
                child: Row(
                  children: [
                    _Stat(value: '${child.experiencesCompleted}', label: l10n.profileExperiences),
                    const _StatDivider(),
                    _Stat(value: '$interestsCount', label: l10n.profileInterests),
                    const _StatDivider(),
                    _Stat(value: '${child.streakDays}', label: l10n.profileStreak(child.streakDays)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: NawaSpacing.xl),
            _MenuRow(icon: Icons.favorite_border_rounded, label: l10n.yourInterests, onTap: () => context.push(RoutePaths.interests)),
            _MenuRow(icon: Icons.military_tech_outlined, label: l10n.myBadges, onTap: comingSoon),
            _MenuRow(icon: Icons.history_rounded, label: l10n.history, onTap: comingSoon),
            _MenuRow(icon: Icons.settings_outlined, label: l10n.settingsTitle, onTap: () => context.push(RoutePaths.settings)),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.headlineMedium),
          Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 36, child: VerticalDivider(color: NawaColors.border));
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: NawaColors.textSecondary),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right_rounded, color: NawaColors.textMuted),
      onTap: onTap,
    );
  }
}
