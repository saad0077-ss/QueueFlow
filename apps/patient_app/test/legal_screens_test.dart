import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/presentation/pages/privacy_policy_screen.dart';
import 'package:patient_app/features/profile/presentation/pages/terms_conditions_screen.dart';
import 'package:patient_app/features/profile/presentation/widgets/legal/legal_document_hero.dart';
import 'package:patient_app/features/profile/presentation/widgets/legal/legal_laptop_layout.dart';
import 'package:patient_app/features/profile/presentation/widgets/legal/legal_section_card.dart';
import 'package:patient_app/features/profile/presentation/widgets/profile_tab/profile_support_legal_menu_section.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

void main() {
  testWidgets('PrivacyPolicyScreen renders sections and toggles cleanly at 360px',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: const PrivacyPolicyScreen()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Your Privacy Comes First'), findsOneWidget);
    expect(find.text('Information We Collect'), findsOneWidget);
    expect(find.text('privacy@queueflow.health'), findsNothing);

    await tester.tap(find.byTooltip('Collapse all'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Expand all'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('TermsConditionsScreen and menu navigation work cleanly',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: ProfileSupportLegalMenuSection(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('Your Privacy Comes First'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terms & Conditions'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Clear Terms for Every Visit'), findsOneWidget);
    expect(find.text('Bookings & Live Queue Rules'), findsOneWidget);
    expect(find.text('Questions About These Terms?'), findsNothing);
    expect(find.text('legal@queueflow.health'), findsNothing);
    expect(find.byType(TermsConditionsScreen), findsOneWidget);
  });

  testWidgets('Legal screens render 2-column laptop layout cleanly at 1280px',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: const PrivacyPolicyScreen()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(LegalLaptopLayout), findsOneWidget);
    expect(find.text('SECTIONS OVERVIEW'), findsOneWidget);

    final heroRect = tester.getRect(find.byType(LegalDocumentHero));
    final firstClauseRect = tester.getRect(find.byType(LegalSectionCard).first);
    expect(firstClauseRect.left, greaterThan(heroRect.right));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const TermsConditionsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(LegalLaptopLayout), findsOneWidget);
  });
}
