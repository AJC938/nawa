import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/buttons/nawa_primary_button.dart';
import '../../../../core/widgets/mascot/nawa_mascot_placeholder.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../domain/onboarding_state.dart';
import '../state/onboarding_controller.dart';

class OnboardingCompleteScreen extends ConsumerWidget {
  const OnboardingCompleteScreen({super.key});

  Future<void> _handleStartExploring(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authControllerProvider);
    if (auth.status != AuthStatus.authenticated) {
      // Not signed in yet — send them through the auth gate first rather
      // than writing an orphan profile with no owning UID.
      context.go(RoutePaths.login);
      return;
    }

    final saved = await ref.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();
    if (!context.mounted) return;
    if (saved) {
      context.go(RoutePaths.home);
    } else {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authErrorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isSyncing = ref.watch(onboardingProvider).syncStatus == OnboardingSyncStatus.syncing;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              const NawaMascotPlaceholder(size: 180, mood: MascotMood.celebrating),
              const SizedBox(height: NawaSpacing.xxl),
              Text(l10n.onboardingCompleteTitle, style: theme.textTheme.displayMedium, textAlign: TextAlign.center),
              const SizedBox(height: NawaSpacing.md),
              Text(l10n.onboardingCompleteSubtitle, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
              const Spacer(),
              NawaPrimaryButton(
                label: l10n.startExploring,
                isLoading: isSyncing,
                onPressed: isSyncing ? null : () => _handleStartExploring(context, ref),
              ),
              const SizedBox(height: NawaSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
