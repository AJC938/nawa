import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_locale.dart';

/// Holds the app's active locale and exposes it for locale switching.
///
/// Nawa is Arabic-first, so Arabic is the default locale on a fresh
/// launch; English remains fully supported and selectable from Settings.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => AppLocale.ar;

  void setLocale(Locale locale) {
    if (!AppLocale.supported.contains(locale)) return;
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
