import 'package:flutter/material.dart';

import '../../../app/theme/nawa_colors.dart';
import '../../../app/theme/nawa_spacing.dart';

/// Small stat card used on the Parent Dashboard (e.g. "Experiences
/// Completed", "Time Spent Exploring").
class ParentSummaryCard extends StatelessWidget {
  const ParentSummaryCard({super.key, required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(NawaSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: NawaColors.primary),
              const SizedBox(height: NawaSpacing.sm),
              Text(value, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 2),
              Text(label, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
