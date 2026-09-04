// Application bootstrap smoke test.
//
// Verifies that NawaApp builds without throwing: providers resolve,
// routing initializes to the welcome route, and localization/theme wire up.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/features/auth/data/auth_repository.dart';
import 'package:nawa/features/experiences/data/exploration_repository.dart';
import 'package:nawa/features/profile/data/user_profile_repository.dart';

import 'package:nawa/app/app.dart';

import 'support/fake_auth_repository.dart';
import 'support/fake_exploration_repository.dart';
import 'support/fake_user_profile_repository.dart';

void main() {
  testWidgets('NawaApp bootstraps successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          userProfileRepositoryProvider.overrideWithValue(FakeUserProfileRepository()),
          explorationRepositoryProvider.overrideWithValue(FakeExplorationRepository()),
        ],
        child: const NawaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NawaApp), findsOneWidget);
    expect(find.text('Start Exploring'), findsOneWidget);
  });
}
