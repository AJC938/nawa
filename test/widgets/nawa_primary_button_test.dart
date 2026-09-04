import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/core/widgets/buttons/nawa_primary_button.dart';

void main() {
  testWidgets('NawaPrimaryButton shows its label and fires onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NawaPrimaryButton(label: 'Continue', onPressed: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.byType(NawaPrimaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('NawaPrimaryButton is disabled while isLoading', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NawaPrimaryButton(label: 'Continue', isLoading: true, onPressed: () => tapped = true),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    expect(tapped, isFalse);
  });

  testWidgets('NawaPrimaryButton is disabled when onPressed is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NawaPrimaryButton(label: 'Continue', onPressed: null)),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
