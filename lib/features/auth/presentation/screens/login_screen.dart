import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/nawa_colors.dart';
import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/buttons/nawa_primary_button.dart';
import '../../../../core/widgets/inputs/nawa_text_field.dart';
import '../../../../core/widgets/mascot/nawa_logo_mark.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../onboarding/domain/onboarding_state.dart';
import '../../../onboarding/presentation/state/onboarding_controller.dart';
import '../../domain/auth_error_code.dart';
import '../../domain/auth_state.dart';
import '../state/auth_controller.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _emailInvalid = false;
  bool _passwordEmpty = false;

  /// Set only from this screen's own submit attempts — never read from the
  /// shared [authControllerProvider] error directly, so a failed attempt on
  /// the Create Account screen can't bleed a stale error into this one.
  AuthErrorCode? _serverError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    final emailInvalid = !_emailPattern.hasMatch(email);
    final passwordEmpty = password.isEmpty;

    setState(() {
      _emailInvalid = emailInvalid;
      _passwordEmpty = passwordEmpty;
      _serverError = null;
    });
    if (emailInvalid || passwordEmpty) return;

    final ok = await ref.read(authControllerProvider.notifier).login(email: email, password: password);
    if (!mounted) return;
    if (!ok) {
      setState(() => _serverError = ref.read(authControllerProvider).errorCode ?? AuthErrorCode.unknown);
      return;
    }

    // If this login is completing a just-finished onboarding, persist it to
    // Firestore before entering the authenticated app.
    final saved = await ref.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();
    if (!mounted) return;
    if (saved) {
      context.go(RoutePaths.parent);
    } else {
      setState(() => _serverError = AuthErrorCode.unknown);
    }
  }

  void _comingSoon() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);
    final isSyncingOnboarding = ref.watch(onboardingProvider).syncStatus == OnboardingSyncStatus.syncing;

    final passwordError = _passwordEmpty ? l10n.fieldRequired : _serverError?.message(l10n);

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NawaLogoMark(compact: true),
              const SizedBox(height: NawaSpacing.xxl),
              Text(l10n.loginTitle, style: theme.textTheme.displayMedium),
              const SizedBox(height: NawaSpacing.sm),
              Text(l10n.loginSubtitle, style: theme.textTheme.bodyLarge),
              const SizedBox(height: NawaSpacing.xl),
              NawaTextField(
                label: l10n.emailLabel,
                hint: l10n.emailHint,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                errorText: _emailInvalid ? l10n.authErrorInvalidEmail : null,
              ),
              const SizedBox(height: NawaSpacing.lg),
              NawaTextField(
                label: l10n.passwordLabel,
                hint: l10n.passwordHint,
                controller: _password,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                errorText: passwordError,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _comingSoon, child: Text(l10n.forgotPassword)),
              ),
              const SizedBox(height: NawaSpacing.md),
              NawaPrimaryButton(
                label: l10n.loginButton,
                isLoading: auth.status == AuthStatus.loggingIn || isSyncingOnboarding,
                onPressed: (auth.status == AuthStatus.loggingIn || isSyncingOnboarding) ? null : _submit,
              ),
              const SizedBox(height: NawaSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.noAccountPrompt, style: theme.textTheme.bodyMedium),
                  TextButton(onPressed: () => context.go(RoutePaths.signup), child: Text(l10n.signUp)),
                ],
              ),
              const SizedBox(height: NawaSpacing.md),
              Row(
                children: const [
                  Expanded(child: Divider(color: NawaColors.border)),
                ],
              ),
              const SizedBox(height: NawaSpacing.sm),
              Center(child: Text(l10n.orContinueWith, style: theme.textTheme.bodySmall)),
              const SizedBox(height: NawaSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialButton(icon: Icons.g_mobiledata_rounded, onTap: _comingSoon),
                  const SizedBox(width: NawaSpacing.lg),
                  _SocialButton(icon: Icons.apple_rounded, onTap: _comingSoon),
                ],
              ),
              const SizedBox(height: NawaSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          border: Border.fromBorderSide(BorderSide(color: NawaColors.border)),
        ),
        child: Icon(icon, color: NawaColors.textPrimary),
      ),
    );
  }
}
