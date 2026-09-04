import 'package:flutter/material.dart';

import '../../../app/theme/nawa_colors.dart';
import '../../../app/theme/nawa_radius.dart';
import '../../../app/theme/nawa_spacing.dart';

/// Generic pill chip — used for filter chips (Explore) and skill/concept
/// tags (experience details, completion screen).
class NawaChip extends StatelessWidget {
  const NawaChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.color,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? NawaColors.primary;
    final theme = Theme.of(context);
    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.symmetric(horizontal: NawaSpacing.md, vertical: NawaSpacing.sm),
      decoration: BoxDecoration(
        color: selected ? tint : NawaColors.surface,
        borderRadius: BorderRadius.circular(NawaRadius.pill),
        border: Border.all(color: selected ? tint : NawaColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: selected ? Colors.white : tint),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: selected ? Colors.white : NawaColors.textPrimary),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return Semantics(button: true, selected: selected, label: label, child: InkWell(borderRadius: BorderRadius.circular(NawaRadius.pill), onTap: onTap, child: chip));
  }
}
