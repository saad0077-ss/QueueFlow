import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_owner/app/platform_owner_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PlatformOwnerApp builds root structure and providers',
      (tester) async {
    await tester.pumpWidget(
      const PlatformOwnerApp(
        home: Scaffold(body: Text('Platform Owner Root')),
      ),
    );
    expect(find.byType(PlatformOwnerApp), findsOneWidget);
    expect(find.text('Platform Owner Root'), findsOneWidget);
  });
}
