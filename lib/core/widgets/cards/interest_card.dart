import 'package:flutter/material.dart';

import '../../../app/theme/nawa_colors.dart';
import '../../../app/theme/nawa_radius.dart';
import '../../../app/theme/nawa_spacing.dart';

/// Selectable category card used on the onboarding interest-selection grid.
/// Shows an obvious filled/checked state when selected.
class InterestCard extends StatelessWidget {
  const InterestCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NawaRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: NawaSpacing.lg, horizontal: NawaSpacing.md),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : NawaColors.surface,
            borderRadius: BorderRadius.circular(NawaRadius.lg),
            border: Border.all(color: selected ? color : NawaColors.border, width: selected ? 2 : 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(radius: 26, backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
                  if (selected)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: NawaColors.success, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: NawaSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
