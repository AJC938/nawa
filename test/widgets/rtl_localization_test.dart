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
  testWidgets('Switching to Arabic flips text direction to RTL and translates chrome text', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        userProfileRepositoryProvider.overrideWithValue(FakeUserProfileRepository()),
        explorationRepositoryProvider.overrideWithValue(FakeExplorationRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const NawaApp()));
    await tester.pumpAndSettle();

    // English by default: LTR, English welcome copy.
    expect(Directionality.of(tester.element(find.text('Discover what you love'))), TextDirection.ltr);

    container.read(localeProvider.notifier).setLocale(AppLocale.ar);
    await tester.pumpAndSettle();

    // Arabic: RTL direction, Arabic welcome copy, no leftover English text.
    expect(Directionality.of(tester.element(find.text('اكتشف ما تحب'))), TextDirection.rtl);
    expect(find.text('Discover what you love'), findsNothing);
  });
}
