import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../state/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _comingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(localeProvider);
    final selected = await showModalBottomSheet<Locale>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.languageEnglish),
              trailing: current.languageCode == 'en' ? const Icon(Icons.check_rounded, color: NawaColors.primary) : null,
              onTap: () => Navigator.of(context).pop(AppLocale.en),
            ),
            ListTile(
              title: Text(l10n.languageArabic),
              trailing: current.languageCode == 'ar' ? const Icon(Icons.check_rounded, color: NawaColors.primary) : null,
              onTap: () => Navigator.of(context).pop(AppLocale.ar),
            ),
          ],
        ),
      ),
    );
    if (selected != null) ref.read(localeProvider.notifier).setLocale(selected);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.md),
          children: [
            _Row(icon: Icons.person_outline_rounded, label: l10n.settingsProfile, onTap: () => _comingSoon(context, l10n)),
            _Row(icon: Icons.groups_outlined, label: l10n.settingsChildProfiles, onTap: () => _comingSoon(context, l10n)),
            _Row(
              icon: Icons.language_rounded,
              label: l10n.settingsLanguage,
              value: locale.languageCode == 'ar' ? l10n.languageArabic : l10n.languageEnglish,
              onTap: () => _pickLanguage(context, ref),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.notifications_outlined, color: NawaColors.textSecondary),
              title: Text(l10n.settingsNotifications, style: theme.textTheme.bodyLarge),
              value: notificationsEnabled,
              onChanged: (_) => ref.read(notificationsEnabledProvider.notifier).toggle(),
            ),
            _Row(icon: Icons.shield_outlined, label: l10n.settingsPrivacySafety, onTap: () => _comingSoon(context, l10n)),
            _Row(icon: Icons.help_outline_rounded, label: l10n.settingsHelpSupport, onTap: () => _comingSoon(context, l10n)),
            _Row(icon: Icons.info_outline_rounded, label: l10n.settingsAboutNawa, onTap: () => _comingSoon(context, l10n)),
            const SizedBox(height: NawaSpacing.lg),
            _Row(
              icon: Icons.logout_rounded,
              label: l10n.settingsLogout,
              color: NawaColors.error,
              onTap: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go(RoutePaths.welcome);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap, this.value, this.color});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? NawaColors.textSecondary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: tint),
      title: Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: color)),
      trailing: value != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value!, style: theme.textTheme.bodyMedium),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: NawaColors.textMuted),
              ],
            )
          : (color == null ? const Icon(Icons.chevron_right_rounded, color: NawaColors.textMuted) : null),
      onTap: onTap,
    );
  }
}
