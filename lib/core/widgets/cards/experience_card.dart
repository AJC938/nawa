import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/nawa_colors.dart';
import '../../../app/theme/nawa_radius.dart';
import '../../../app/theme/nawa_spacing.dart';

enum ExperienceCardVariant { grid, list }

/// Reusable card for an [Experience]. The [grid] variant is used in
/// featured/recommended horizontal rails; [list] is used in the category
/// experience list.
class ExperienceCard extends StatelessWidget {
  const ExperienceCard({
    super.key,
    required this.title,
    required this.categoryLabel,
    required this.metaLabel,
    required this.icon,
    required this.color,
    required this.onTap,
    this.imageAsset,
    this.variant = ExperienceCardVariant.grid,
  });

  final String title;
  final String categoryLabel;
  final String metaLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final ExperienceCardVariant variant;

  /// Local vector artwork for the experience. Falls back to [icon] on a
  /// tinted background when not provided.
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (variant == ExperienceCardVariant.list) {
      return Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NawaRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(NawaSpacing.md),
            child: Row(
              children: [
                _Thumbnail(icon: icon, color: color, imageAsset: imageAsset, size: 52),
                const SizedBox(width: NawaSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(metaLabel, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: NawaColors.textMuted),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 11,
                child: imageAsset != null
                    ? SvgPicture.asset(imageAsset!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                    : Container(
                        color: color.withValues(alpha: 0.14),
                        alignment: Alignment.center,
                        child: Icon(icon, size: 44, color: color),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(NawaSpacing.md, NawaSpacing.sm, NawaSpacing.md, NawaSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(categoryLabel, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.icon, required this.color, required this.size, this.imageAsset});

  final IconData icon;
  final Color color;
  final double size;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    if (imageAsset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(NawaRadius.md),
        child: SvgPicture.asset(imageAsset!, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(NawaRadius.md)),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
