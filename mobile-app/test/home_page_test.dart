import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kadam/features/home/presentation/pages/home_page.dart';

void main() {
  testWidgets('HomePage renders correctly', (WidgetTester tester) async {
    // Build the HomePage widget
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    // Verify that the header text is present
    expect(find.text('Hi User'), findsOneWidget);

    // Verify that the View All button is present
    expect(find.text('View All'), findsOneWidget);

    // Verify that the StepProgressGauge text is present
    expect(find.text('6300'), findsOneWidget);
    expect(find.text('of 10000 steps'), findsOneWidget);

    // Verify that StatCards are present
    expect(find.text('Distance Covered'), findsOneWidget);
    expect(find.text('Calories burned'), findsOneWidget);
    expect(find.text('Stairs Climbed'), findsOneWidget);

    // Verify that DateSelector days are present (e.g., '07', 'Mon')
    expect(find.text('07'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
  });
}
