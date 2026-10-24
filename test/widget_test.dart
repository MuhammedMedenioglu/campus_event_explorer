import 'package:flutter_test/flutter_test.dart';
import 'package:campus_event_explorer/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Search shows an empty state for unmatched events',
      (tester) async {
    await tester.pumpWidget(const CampusApp());
    await tester.pumpAndSettle();

    expect(find.text('6 matching events'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'zzzz',
    );
    await tester.pumpAndSettle();

    expect(find.text('0 matching events'), findsOneWidget);
    expect(
      find.text('No events match your search and category.'),
      findsOneWidget,
    );
  });
}