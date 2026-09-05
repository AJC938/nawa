import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/app/app.dart';
import 'package:nawa/core/localization/app_locale.dart';
import 'package:nawa/core/localization/locale_provider.dart';
import 'package:nawa/features/auth/data/auth_repository.dart';
import 'package:nawa/features/experiences/data/exploration_repository.dart';
import 'package:nawa/features/profile/data/user_profile_repository.dart';

import '../support/fake_auth_repository.dart';
import '../support/fake_exploration_repository.dart';
import '../support/fake_user_profile_repository.dart';

void main() {
  testWidgets('Arabic is the default locale, and switching to English still works', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        userProfileRepositoryProvider.overrideWithValue(FakeUserProfileRepository()),
        explorationRepositoryProvider.overrideWithValue(FakeExplorationRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const NawaApp()));
    // Clear the branded splash's short display timer before settling.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Arabic-first by default: RTL direction, Arabic welcome copy.
    expect(container.read(localeProvider), AppLocale.ar);
    expect(Directionality.of(tester.element(find.text('اكتشف ما تحب'))), TextDirection.rtl);

    container.read(localeProvider.notifier).setLocale(AppLocale.en);
    await tester.pumpAndSettle();

    // English remains fully supported and selectable: LTR, English welcome
    // copy, no leftover Arabic text.
    expect(Directionality.of(tester.element(find.text('Discover what you love'))), TextDirection.ltr);
    expect(find.text('اكتشف ما تحب'), findsNothing);
  });
}
