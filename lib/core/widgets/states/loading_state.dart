import 'package:flutter/material.dart';

import '../../../app/theme/nawa_colors.dart';
import '../../../app/theme/nawa_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../mascot/nawa_mascot_placeholder.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(NawaSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NawaMascotPlaceholder(size: 120, mood: MascotMood.sleepy),
          const SizedBox(height: NawaSpacing.xl),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.6, color: NawaColors.primary),
          ),
          const SizedBox(height: NawaSpacing.lg),
          Text(l10n.loadingTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: NawaSpacing.sm),
          Text(l10n.loadingSubtitle, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
