// Application bootstrap smoke test.
//
// Verifies that NawaApp builds without throwing: providers resolve,
// routing initializes to the welcome route, and localization/theme wire up.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nawa/app/app.dart';

void main() {
  testWidgets('NawaApp bootstraps successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NawaApp()));
    await tester.pumpAndSettle();

    expect(find.byType(NawaApp), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });
}
