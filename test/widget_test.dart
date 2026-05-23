<<<<<<< HEAD
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotel_booking/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
=======
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/main.dart';

void main() {
  testWidgets('Weather App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(WeatherApp());

    // Wait for the mock data to load
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Verify that the weather app loads correctly
    expect(find.text('Weather App'), findsOneWidget);

    // Check if we can find weather-related elements
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Look for search functionality
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Test search dialog
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.text('Search City'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('Weather search functionality test', (WidgetTester tester) async {
    await tester.pumpWidget(WeatherApp());
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Open search dialog
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Enter a city name
    await tester.enterText(find.byType(TextField), 'London');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // The dialog should close after search
    expect(find.text('Search City'), findsNothing);
  });
}
>>>>>>> temp-weather/main
