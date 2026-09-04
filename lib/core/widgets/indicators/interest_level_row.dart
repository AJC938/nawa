import 'package:flutter/material.dart';

import '../../../app/theme/nawa_spacing.dart';
import 'nawa_progress_bar.dart';

/// A single row in the My Interests / Parent Interest Summary lists:
/// icon + category name + status label, with a progress bar beneath.
class InterestLevelRow extends StatelessWidget {
  const InterestLevelRow({
    super.key,
    required this.label,
    required this.statusLabel,
    required this.icon,
    required this.color,
    required this.progress,
    this.onTap,
  });

  final String label;
  final String statusLabel;
  final IconData icon;
  final Color color;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: NawaSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 20, backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: NawaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
                    Text(statusLabel, style: theme.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: NawaSpacing.sm),
                NawaProgressBar(value: progress, color: color),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
