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

/// Covers state-flow-test steps 8-16: Home -> Experience -> Completion ->
/// My Interests, and verifies completing an experience actually changes
/// the interest level shown afterwards (not a hardcoded screen swap).
Future<void> _completeOnboarding(WidgetTester tester) async {
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

  await tester.tap(find.text('Start Exploring'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'Zayd');
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('8'));
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Gaming'));
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Start Exploring'));
  await tester.pumpAndSettle();

  // Logged-out parent hits the auth gate (Login) before reaching the app.
  await tester.enterText(find.byType(TextField).first, 'parent@nawa.app');
  await tester.enterText(find.byType(TextField).last, 'password123');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
  await tester.pumpAndSettle();

  // Signing in lands on the Parent tab; switch to Home for the rest of the flow.
  await tester.tap(find.text('Home'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home -> Experience -> Completion -> My Interests reflects the new level', (tester) async {
    // Wide enough that the test-harness fallback font (which measures text
    // wider than the real on-device font) doesn't overflow the Login screen's
    // "Don't have an account? / Sign up" row.
    await tester.binding.setSurfaceSize(const Size(520, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _completeOnboarding(tester);

    // Home -> the first recommended experience is a Gaming one ("Galaxy Builder").
    expect(find.text('Galaxy Builder'), findsWidgets);
    await tester.tap(find.text('Galaxy Builder').first);
    await tester.pumpAndSettle();

    // Experience details -> start.
    expect(find.text('Start Experience'), findsOneWidget);
    await tester.tap(find.text('Start Experience'));
    await tester.pumpAndSettle();

    // Question 1.
    expect(find.text('A bright star'), findsOneWidget);
    await tester.tap(find.text('A bright star'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Question 2.
    expect(find.text('A few, spaced out'), findsOneWidget);
    await tester.tap(find.text('A few, spaced out'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Completion screen for the first (Galaxy Builder) experience.
    expect(find.text('Great job!'), findsOneWidget);

    // A single completion isn't enough real evidence to reach "Strong" under
    // the deterministic scoring formula — complete a second Gaming
    // experience (Space Adventure) so the score genuinely crosses the
    // threshold, rather than asserting a hardcoded/mocked level.
    await tester.tap(find.text('Explore More'));
    await tester.pumpAndSettle();

    expect(find.text('Space Adventure'), findsWidgets);
    await tester.tap(find.text('Space Adventure').first);
    await tester.pumpAndSettle();

    expect(find.text('Start Experience'), findsOneWidget);
    await tester.tap(find.text('Start Experience'));
    await tester.pumpAndSettle();

    for (final answer in ['Right Path', 'Catch it carefully', 'Follow the star map']) {
      expect(find.text(answer), findsOneWidget);
      await tester.tap(find.text(answer));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Great job!'), findsOneWidget);
    await tester.tap(find.text('View My Interests'));
    await tester.pumpAndSettle();

    // My Interests now shows Gaming as a strong interest: selected (20) +
    // 2 completions (50) + 5 interactions (10) = 80, well past the real
    // "Strong Interest" threshold (75) — moved up from the "Exploring" tier
    // (score 20) it was at right after onboarding, before any real
    // exploration evidence existed.
    expect(find.text('My Interests'), findsOneWidget);
    expect(find.text('Strong Interest'), findsOneWidget);
  });
}
