import 'package:flutter/material.dart';

import '../../../app/theme/nawa_colors.dart';
import '../../../app/theme/nawa_radius.dart';

/// Text-based stand-in for the approved Nawa logo lockup.
///
/// `assets/branding/nawa_logo.png` is not yet available. Swap this widget
/// for `Image.asset('assets/branding/nawa_logo.png')` once the real,
/// approved asset is added — do not treat this as the final logo design.
class NawaLogoMark extends StatelessWidget {
  const NawaLogoMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Nawa',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 28 : 36,
            height: compact ? 28 : 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [NawaColors.primary, NawaColors.accent]),
              borderRadius: BorderRadius.circular(NawaRadius.md),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Text(
            'Nawa',
            style: (compact ? theme.textTheme.titleLarge : theme.textTheme.headlineMedium)?.copyWith(color: NawaColors.textPrimary),
          ),
          const SizedBox(width: 6),
          Text(
            'نوى',
            style: (compact ? theme.textTheme.titleMedium : theme.textTheme.headlineMedium)?.copyWith(color: NawaColors.primary),
          ),
        ],
      ),
    );
  }
}
