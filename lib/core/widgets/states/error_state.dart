import 'package:flutter/material.dart';

import '../../../app/theme/nawa_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../buttons/nawa_primary_button.dart';
import '../mascot/nawa_mascot_placeholder.dart';

/// Friendly error UI. Never surfaces raw exceptions/technical detail to
/// the child — only [message] override is accepted, no stack traces.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(NawaSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const NawaMascotPlaceholder(size: 120, mood: MascotMood.sad),
          const SizedBox(height: NawaSpacing.xl),
          Text(l10n.errorTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: NawaSpacing.sm),
          Text(message ?? l10n.errorMessage, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: NawaSpacing.xl),
            NawaPrimaryButton(label: l10n.tryAgain, onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}
