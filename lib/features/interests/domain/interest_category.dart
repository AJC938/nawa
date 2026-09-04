import 'package:flutter/material.dart';

import '../../../app/theme/nawa_colors.dart';
import '../../../l10n/app_localizations.dart';

/// The five core Nawa interest categories. Gaming is the largest category.
enum InterestCategoryType { gaming, sports, art, technology, science }

/// Non-localized visual metadata for a category (icon + brand color tint).
class InterestCategoryMeta {
  const InterestCategoryMeta({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

const Map<InterestCategoryType, InterestCategoryMeta> kInterestCategoryMeta = {
  InterestCategoryType.gaming: InterestCategoryMeta(icon: Icons.sports_esports_rounded, color: NawaColors.primary),
  InterestCategoryType.sports: InterestCategoryMeta(icon: Icons.sports_soccer_rounded, color: NawaColors.warning),
  InterestCategoryType.art: InterestCategoryMeta(icon: Icons.palette_rounded, color: NawaColors.error),
  InterestCategoryType.technology: InterestCategoryMeta(icon: Icons.memory_rounded, color: NawaColors.info),
  InterestCategoryType.science: InterestCategoryMeta(icon: Icons.science_rounded, color: NawaColors.accent),
};

/// Parses a stable Firestore interest id (e.g. `"gaming"`) back into an
/// [InterestCategoryType]. Returns null for an unrecognized id instead of
/// throwing, so a future/unknown value in Firestore is just ignored.
InterestCategoryType? interestCategoryFromId(String id) {
  for (final type in InterestCategoryType.values) {
    if (type.id == id) return type;
  }
  return null;
}

extension InterestCategoryTypeX on InterestCategoryType {
  IconData get icon => kInterestCategoryMeta[this]!.icon;
  Color get color => kInterestCategoryMeta[this]!.color;

  /// Stable, non-localized identifier used for Firestore storage
  /// (e.g. `"gaming"`) — never a translated UI label.
  String get id => name;

  String label(AppLocalizations l10n) {
    switch (this) {
      case InterestCategoryType.gaming:
        return l10n.categoryGaming;
      case InterestCategoryType.sports:
        return l10n.categorySports;
      case InterestCategoryType.art:
        return l10n.categoryArt;
      case InterestCategoryType.technology:
        return l10n.categoryTechnology;
      case InterestCategoryType.science:
        return l10n.categoryScience;
    }
  }
}
