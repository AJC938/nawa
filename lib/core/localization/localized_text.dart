import 'package:flutter/widgets.dart';

/// A small EN/AR text pair for bulk mock content (experience copy,
/// discovery suggestions, etc.) that doesn't warrant its own ARB entry.
///
/// Static app chrome (buttons, headers, system messages) still goes
/// through [AppLocalizations] / the ARB files.
class LocalizedText {
  const LocalizedText({required this.en, required this.ar});

  final String en;
  final String ar;

  String resolve(Locale locale) => locale.languageCode == 'ar' ? ar : en;

  String of(BuildContext context) => resolve(Localizations.localeOf(context));
}
