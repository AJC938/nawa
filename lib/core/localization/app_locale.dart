import 'package:flutter/widgets.dart';

/// Locales supported by Nawa.
class AppLocale {
  const AppLocale._();

  static const Locale en = Locale('en');
  static const Locale ar = Locale('ar');

  static const List<Locale> supported = [en, ar];

  static bool isRtl(Locale locale) => locale.languageCode == 'ar';
}
