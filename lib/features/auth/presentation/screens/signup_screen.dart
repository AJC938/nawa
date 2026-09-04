import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
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
const _minPasswordLength = 6;

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _agreed = false;
  bool _nameEmpty = false;
  bool _emailInvalid = false;
  bool _passwordTooShort = false;

  /// Set only from this screen's own submit attempts — never read from the
  /// shared [authControllerProvider] error directly, so a failed attempt on
  /// the Login screen can't bleed a stale error into this one.
  AuthErrorCode? _serverError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agreed) return;

    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final nameEmpty = name.isEmpty;
    final emailInvalid = !_emailPattern.hasMatch(email);
    final passwordTooShort = password.length < _minPasswordLength;

    setState(() {
      _nameEmpty = nameEmpty;
      _emailInvalid = emailInvalid;
      _passwordTooShort = passwordTooShort;
      _serverError = null;
    });
    if (nameEmpty || emailInvalid || passwordTooShort) return;

    final ok = await ref.read(authControllerProvider.notifier).createAccount(name: name, email: email, password: password);
    if (!mounted) return;
    if (!ok) {
      setState(() => _serverError = ref.read(authControllerProvider).errorCode ?? AuthErrorCode.unknown);
      return;
    }

    // If this signup is completing a just-finished onboarding, persist it to
    // Firestore before entering the authenticated app.
    final saved = await ref.read(onboardingProvider.notifier).syncToFirestoreIfNeeded();
    if (!mounted) return;
    if (saved) {
      context.go(RoutePaths.signupSuccess);
    } else {
      setState(() => _serverError = AuthErrorCode.unknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);
    final isSyncingOnboarding = ref.watch(onboardingProvider).syncStatus == OnboardingSyncStatus.syncing;

    final passwordError = _passwordTooShort ? l10n.authErrorWeakPassword : _serverError?.message(l10n);

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
              Text(l10n.signupTitle, style: theme.textTheme.displayMedium),
              const SizedBox(height: NawaSpacing.sm),
              Text(l10n.signupSubtitle, style: theme.textTheme.bodyLarge),
              const SizedBox(height: NawaSpacing.xl),
              NawaTextField(
                label: l10n.nameLabel,
                hint: l10n.nameHint,
                controller: _name,
                autofillHints: const [AutofillHints.name],
                errorText: _nameEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: NawaSpacing.lg),
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
                hint: l10n.createPasswordHint,
                controller: _password,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.newPassword],
                errorText: passwordError,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: NawaSpacing.md),
              Row(
                children: [
                  Checkbox(value: _agreed, onChanged: (v) => setState(() => _agreed = v ?? false)),
                  Expanded(child: Text(l10n.agreeTerms, style: theme.textTheme.bodyMedium)),
                ],
              ),
              const SizedBox(height: NawaSpacing.md),
              NawaPrimaryButton(
                label: l10n.createAccountButton,
                isLoading: auth.status == AuthStatus.loggingIn || isSyncingOnboarding,
                onPressed: (_agreed && !isSyncingOnboarding) ? _submit : null,
              ),
              const SizedBox(height: NawaSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.alreadyHaveAccountPrompt, style: theme.textTheme.bodyMedium),
                  TextButton(onPressed: () => context.go(RoutePaths.login), child: Text(l10n.logIn)),
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
