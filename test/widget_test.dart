// Basic smoke test — full app bootstrap requires Hive in integration tests.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('RankedGym'),
        ),
      ),
    );
    expect(find.text('RankedGym'), findsOneWidget);
  });
}
