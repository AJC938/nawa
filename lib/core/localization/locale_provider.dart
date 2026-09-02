import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_locale.dart';

/// Holds the app's active locale and exposes it for locale switching.
///
/// Defaults to English. The next phase can wire this to a persisted
/// user/device preference.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => AppLocale.en;

  void setLocale(Locale locale) {
    if (!AppLocale.supported.contains(locale)) return;
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
