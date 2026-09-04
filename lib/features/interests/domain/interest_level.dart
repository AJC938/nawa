import '../../../l10n/app_localizations.dart';

/// A qualitative bucketing of a real, deterministic interest score (0-100).
///
/// This intentionally never claims to be a measurement, IQ score, or
/// psychological assessment — it is a friendly, qualitative label derived
/// from how much a child has explored a category.
enum InterestLevel { emerging, exploring, strong, veryStrong }

/// Score bands: 0-19 no evidence yet, 20-49 selected/lightly explored,
/// 50-74 real exploration evidence, 75-100 strong evidence.
///
/// The app's UI only ever shows 3 distinct labels (Emerging/Exploring/Strong
/// to a child; those three plus a separate "Very Strong" to a parent), so the
/// lowest band ("no evidence yet") reuses the same [InterestLevel.emerging]
/// label the UI already treats as its lowest/empty state, rather than adding
/// a fourth visible tier.
InterestLevel interestLevelForScore(double score) {
  if (score >= 75) return InterestLevel.veryStrong;
  if (score >= 50) return InterestLevel.strong;
  if (score >= 20) return InterestLevel.exploring;
  return InterestLevel.emerging;
}

extension InterestLevelX on InterestLevel {
  /// Child-facing label. Kept to three simple, encouraging tiers.
  String childLabel(AppLocalizations l10n) {
    switch (this) {
      case InterestLevel.emerging:
        return l10n.interestLevelEmerging;
      case InterestLevel.exploring:
        return l10n.interestLevelExploring;
      case InterestLevel.strong:
      case InterestLevel.veryStrong:
        return l10n.interestLevelStrongChild;
    }
  }

  /// Parent-facing label, showing the finer-grained tier.
  String parentLabel(AppLocalizations l10n) {
    switch (this) {
      case InterestLevel.emerging:
        return l10n.interestLevelEmerging;
      case InterestLevel.exploring:
        return l10n.interestLevelExploring;
      case InterestLevel.strong:
        return l10n.interestLevelStrong;
      case InterestLevel.veryStrong:
        return l10n.interestLevelVeryStrong;
    }
  }
}
