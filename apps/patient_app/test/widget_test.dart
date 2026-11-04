// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patient_app/main.dart';

void main() {
  // `testWidgets` defines one widget test. The `tester` argument lets us build
  // widgets, interact with them (tap, drag, enter text) and inspect the result.
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // `pumpWidget` renders the given widget as if the app had just started.
    // We pass a simple home screen so the test does not need Firebase.
    await tester.pumpWidget(const PatientApp(
      home: Scaffold(body: Text('0')),
    ));

    // Verify that our counter starts at 0.
    // `find` locates widgets in the tree; `expect` asserts what was found.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    // (Uncomment once your screen has a '+' button.)
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}
