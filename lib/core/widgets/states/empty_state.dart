import 'package:flutter/material.dart';

import '../../../app/theme/nawa_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../buttons/nawa_primary_button.dart';
import '../mascot/nawa_mascot_placeholder.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.title, this.message, this.actionLabel, this.onAction});

  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(NawaSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NawaMascotPlaceholder(size: 120),
          const SizedBox(height: NawaSpacing.xl),
          Text(title ?? l10n.emptyExperiencesTitle, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: NawaSpacing.sm),
          Text(
            message ?? l10n.emptyExperiencesSubtitle,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onAction != null) ...[
            const SizedBox(height: NawaSpacing.xl),
            NawaPrimaryButton(label: actionLabel ?? l10n.exploreNow, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
