import 'package:flutter/material.dart';

import '../../../core/localization/localized_text.dart';
import '../../interests/domain/interest_category.dart';
import 'experience_question.dart';

/// A single interactive experience a child can explore within a category.
class Experience {
  const Experience({
    required this.id,
    required this.category,
    required this.title,
    required this.ageRangeLabel,
    required this.durationMinutes,
    required this.description,
    required this.illustrationIcon,
    required this.imageAsset,
    required this.exploresTags,
    required this.questions,
    this.isFeatured = false,
  });

  final String id;
  final InterestCategoryType category;
  final LocalizedText title;
  final String ageRangeLabel;
  final int durationMinutes;
  final LocalizedText description;

  /// Fallback icon, kept for any consumer that isn't image-aware.
  final IconData illustrationIcon;

  /// Local vector artwork for this experience (card thumbnail + details
  /// hero), e.g. `assets/experiences/galaxy_builder.svg`.
  final String imageAsset;

  /// "What the child will explore" bullet list on the details screen.
  final List<LocalizedText> exploresTags;
  final List<ExperienceQuestion> questions;
  final bool isFeatured;

  String durationLabel(bool isArabic) => isArabic ? '$durationMinutes دقيقة' : '$durationMinutes min';
}
