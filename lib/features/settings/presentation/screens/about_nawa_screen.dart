import 'package:flutter/material.dart';

import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/mascot/nawa_logo_mark.dart';
import '../../../../l10n/app_localizations.dart';

/// A plain, minimal "About Nawa" page — a normal Settings item, not a
/// marketing page.
class AboutNawaScreen extends StatelessWidget {
  const AboutNawaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAboutNawa)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.lg),
          children: [
            const NawaLogoMark(),
            const SizedBox(height: NawaSpacing.xl),
            Text(l10n.aboutNawaBody, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
