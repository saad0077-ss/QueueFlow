import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/presentation/pages/about_app_screen.dart';
import 'package:patient_app/features/profile/presentation/widgets/about/about_app_hero_card.dart';
import 'package:patient_app/features/profile/presentation/widgets/about/about_app_highlights_grid.dart';
import 'package:patient_app/features/profile/presentation/widgets/about/about_app_info_card.dart';
import 'package:patient_app/features/profile/presentation/widgets/about/about_app_laptop_layout.dart';
import 'package:patient_app/features/profile/presentation/widgets/profile_tab/profile_support_legal_menu_section.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

void main() {
  testWidgets(
    'AboutAppScreen renders enhanced hero, workflow, and app links without support email or licenses',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.darkTheme, home: const AboutAppScreen()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('About App'), findsOneWidget);
      expect(find.text('Book smarter. Wait less.'), findsOneWidget);
      expect(find.text('Live Sync'), findsOneWidget);
      expect(find.text('Trusted Care'), findsOneWidget);
      expect(find.text('Smart Slips'), findsOneWidget);
      expect(find.text('Live Queue Radar'), findsOneWidget);
      expect(find.text('Find & Reserve'), findsOneWidget);
      expect(find.text('0.1.0 (Build 1)'), findsOneWidget);
      expect(find.text('QueueFlow health suite'), findsOneWidget);
      expect(find.text('Open-Source Licenses'), findsNothing);
      expect(find.text('support@queueflow.health'), findsNothing);

      final versionRight = tester.getTopRight(find.text('0.1.0 (Build 1)')).dx;
      final editionRight = tester.getTopRight(find.text('Patient App')).dx;
      expect((versionRight - editionRight).abs(), lessThan(1.0));

      await tester.ensureVisible(find.text('Privacy Policy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();
      expect(find.text('Your Privacy Comes First'), findsOneWidget);
    },
  );

  testWidgets('Support & Legal menu navigates to AboutAppScreen cleanly',
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

    await tester.tap(find.text('About App'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AboutAppScreen), findsOneWidget);
  });

  testWidgets('AboutAppScreen renders 2-column laptop layout cleanly at 1280px',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: const AboutAppScreen()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AboutAppLaptopLayout), findsOneWidget);

    final heroRect = tester.getRect(find.byType(AboutAppHeroCard));
    final infoRect = tester.getRect(find.byType(AboutAppInfoCard));
    final highlightsRect = tester.getRect(find.byType(AboutAppHighlightsGrid));
    expect((heroRect.left - infoRect.left).abs(), lessThan(1.0));
    expect(highlightsRect.left, greaterThan(heroRect.right));
  });
}
