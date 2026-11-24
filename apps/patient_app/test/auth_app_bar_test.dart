import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/widgets/app_logo.dart';
import 'package:patient_app/core/widgets/auth_app_bar.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AuthAppBar renders back button and logo with no theme toggle',
      (tester) async {
    bool backTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          appBar: AuthAppBar(
            onBack: () => backTapped = true,
          ),
          body: const SizedBox(),
        ),
      ),
    );

    // Verify back button and logo are present
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);

    // Verify sun / theme toggle icon is NOT present
    expect(find.byIcon(Icons.light_mode_rounded), findsNothing);
    expect(find.byIcon(Icons.dark_mode_rounded), findsNothing);

    // Test back button tap
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(backTapped, isTrue);
  });
}
