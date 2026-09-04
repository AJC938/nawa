import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/app/app.dart';
import 'package:nawa/features/auth/data/auth_repository.dart';
import 'package:nawa/features/experiences/data/exploration_repository.dart';
import 'package:nawa/features/profile/data/user_profile_repository.dart';

import '../support/fake_auth_repository.dart';
import '../support/fake_exploration_repository.dart';
import '../support/fake_user_profile_repository.dart';

/// Covers state-flow-test steps 1-7: Welcome -> Onboarding -> Home, and
/// verifies the entered child name actually reaches the Home greeting
/// (i.e. onboarding really writes into app state, not just navigates).
void main() {
  testWidgets('Welcome -> Onboarding -> Home carries the entered name into Home', (tester) async {
    // Wide enough that the test-harness fallback font (which measures text
    // wider than the real on-device font) doesn't overflow the Login screen's
    // "Don't have an account? / Sign up" row.
    await tester.binding.setSurfaceSize(const Size(520, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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

    expect(find.text('Start Exploring'), findsOneWidget);
    await tester.tap(find.text('Start Exploring'));
    await tester.pumpAndSettle();

    // Onboarding intro.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Name step.
    await tester.enterText(find.byType(TextField), 'Zayd');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Age step.
    await tester.tap(find.text('8'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Interests intro.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Interest selection.
    await tester.tap(find.text('Gaming'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Onboarding complete -> logged-out parent must pass through the auth
    // gate (Login) before reaching the authenticated app, not straight to Home.
    expect(find.text("You're all set!"), findsOneWidget);
    await tester.tap(find.text('Start Exploring'));
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, 'parent@nawa.app');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
    await tester.pumpAndSettle();

    // Signing in lands on the Parent tab; switch to Home to confirm onboarding
    // data (the entered child name) actually reached app state.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Zayd'), findsWidgets);
  });
}
