import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/buttons/nawa_primary_button.dart';
import '../../../../l10n/app_localizations.dart';

class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(color: NawaColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
              ),
              const SizedBox(height: NawaSpacing.xxl),
              Text(l10n.accountCreatedTitle, style: theme.textTheme.displayMedium, textAlign: TextAlign.center),
              const SizedBox(height: NawaSpacing.md),
              Text(l10n.accountCreatedSubtitle, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
              const Spacer(),
              NawaPrimaryButton(label: l10n.goToDashboard, onPressed: () => context.go(RoutePaths.parent)),
              const SizedBox(height: NawaSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
