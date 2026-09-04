import '../../../core/localization/localized_text.dart';

/// A single choice within an experience session question.
///
/// [isEncouraged] marks the option Nawa gently steers the child toward.
/// Picking the other option is never "wrong" — it just prompts a friendly
/// nudge to try the encouraged path before continuing, so the session never
/// feels like a test.
class ExperienceOption {
  const ExperienceOption({
    required this.id,
    required this.label,
    required this.isEncouraged,
  });

  final String id;
  final LocalizedText label;
  final bool isEncouraged;
}

class ExperienceQuestion {
  const ExperienceQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.conceptTags,
  });

  final String id;
  final LocalizedText prompt;
  final List<ExperienceOption> options;

  /// Skill/concept tags this question contributes to the interest profile
  /// once answered (e.g. "Problem solving", "Focus & attention").
  final List<LocalizedText> conceptTags;
}
