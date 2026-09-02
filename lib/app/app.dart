import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/app_locale.dart';
import '../core/localization/locale_provider.dart';
import '../l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/nawa_theme.dart';

/// Root widget of the Nawa application.
class NawaApp extends ConsumerWidget {
  const NawaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Nawa',
      debugShowCheckedModeBanner: false,
      theme: NawaTheme.light(languageCode: locale.languageCode),
      locale: locale,
      supportedLocales: AppLocale.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
