import '../../../core/localization/localized_text.dart';
import '../../interests/domain/interest_category.dart';

/// Short mock category descriptions shown on the Category screen header.
final Map<InterestCategoryType, LocalizedText> mockCategoryDescriptions = {
  InterestCategoryType.gaming: const LocalizedText(
    en: 'Explore fun games, challenges, and adventures.',
    ar: 'استكشف ألعابًا وتحديات ومغامرات ممتعة.',
  ),
  InterestCategoryType.sports: const LocalizedText(
    en: 'Play, move, and compete in friendly mini-matches.',
    ar: 'العب وتحرك ونافس في مباريات ودية قصيرة.',
  ),
  InterestCategoryType.art: const LocalizedText(
    en: 'Draw, paint, and create with colors and imagination.',
    ar: 'ارسم ولوّن وأبدع بالألوان والخيال.',
  ),
  InterestCategoryType.technology: const LocalizedText(
    en: 'Build, code, and discover how things work.',
    ar: 'ابنِ وبرمج واكتشف كيف تعمل الأشياء.',
  ),
  InterestCategoryType.science: const LocalizedText(
    en: 'Observe, experiment, and wonder about the world.',
    ar: 'راقب وجرّب وتساءل عن العالم من حولك.',
  ),
};
