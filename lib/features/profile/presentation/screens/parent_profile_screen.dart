import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/nawa_spacing.dart';
import '../../../../core/widgets/buttons/nawa_primary_button.dart';
import '../../../../core/widgets/inputs/nawa_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../data/user_profile_repository.dart';

/// Minimal Parent Profile: name (editable) + email (read-only, sourced
/// from the authenticated Firebase user — never duplicated as a separate
/// credential). Not a social profile, just the two fields the product
/// asks for.
class ParentProfileScreen extends ConsumerStatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  ConsumerState<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends ConsumerState<ParentProfileScreen> {
  final _name = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final record = await ref.read(userProfileRepositoryProvider).getUserProfile(user.uid);
    if (!mounted) return;
    setState(() {
      _name.text = record?.parentName ?? user.displayName ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _name.text.trim().isEmpty) return;
    setState(() {
      _saving = true;
      _saved = false;
    });
    await ref.read(userProfileRepositoryProvider).createOrUpdateUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          parentName: _name.text.trim(),
        );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saved = true;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final email = ref.watch(authControllerProvider).user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsProfile)),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.xl, vertical: NawaSpacing.lg),
                children: [
                  NawaTextField(label: l10n.parentNameLabel, hint: l10n.parentNameHint, controller: _name),
                  const SizedBox(height: NawaSpacing.lg),
                  Text(l10n.parentEmailLabel, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(email, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: NawaSpacing.xl),
                  NawaPrimaryButton(label: l10n.saveChanges, isLoading: _saving, onPressed: _saving ? null : _save),
                  if (_saved) ...[
                    const SizedBox(height: NawaSpacing.md),
                    Text(l10n.profileSaved, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ],
                ],
              ),
      ),
    );
  }
}
