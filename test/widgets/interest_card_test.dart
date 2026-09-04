import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/core/widgets/cards/interest_card.dart';

void main() {
  testWidgets('InterestCard shows a check indicator only when selected', (tester) async {
    Widget build(bool selected) => MaterialApp(
          home: Scaffold(
            body: InterestCard(
              label: 'Gaming',
              icon: Icons.sports_esports_rounded,
              color: Colors.blue,
              selected: selected,
              onTap: () {},
            ),
          ),
        );

    await tester.pumpWidget(build(false));
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    await tester.pumpWidget(build(true));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('InterestCard fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InterestCard(
            label: 'Gaming',
            icon: Icons.sports_esports_rounded,
            color: Colors.blue,
            selected: false,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InterestCard));
    expect(tapped, isTrue);
  });
}
