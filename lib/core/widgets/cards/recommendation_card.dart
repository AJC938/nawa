import 'package:flutter/material.dart';

import '../../../app/theme/nawa_colors.dart';
import '../../../app/theme/nawa_radius.dart';
import '../../../app/theme/nawa_spacing.dart';

/// A single "you might also like" suggestion row on the Discover screen.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key, required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NawaRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(NawaSpacing.md),
          child: Row(
            children: [
              CircleAvatar(radius: 22, backgroundColor: NawaColors.accent.withValues(alpha: 0.15), child: Icon(icon, color: NawaColors.accent)),
              const SizedBox(width: NawaSpacing.md),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
              const Icon(Icons.chevron_right_rounded, color: NawaColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
