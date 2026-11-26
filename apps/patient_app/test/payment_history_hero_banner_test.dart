import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/presentation/widgets/payment_history/payment_history_hero_banner.dart';

void main() {
  testWidgets(
    'PaymentHistoryHeroBanner renders without overflow on narrow mobile widths',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: PaymentHistoryHeroBanner(
                totalPaid: 1600,
                paidCount: 2,
                totalRefunded: 500,
                refundCount: 1,
                queueTokensCount: 2,
                activeQueueToken: 'GH-OJ-004',
                activeQueueClinicName: 'Green Heaven Clinic',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.text('100% Verified Invoices & Instant Refunds'),
        findsOneWidget,
      );
      expect(find.text('GST Compliant'), findsOneWidget);
      expect(
        find.text('Active Token GH-OJ-004 · ₹500 Paid (Green Heaven Clinic)'),
        findsOneWidget,
      );
      expect(find.text('IN QUEUE'), findsOneWidget);
    },
  );

  testWidgets(
    'PaymentHistoryHeroBanner wraps long clinic names cleanly at 320px width',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: PaymentHistoryHeroBanner(
                totalPaid: 12500,
                paidCount: 15,
                totalRefunded: 1500,
                refundCount: 2,
                queueTokensCount: 8,
                activeQueueToken: 'GH-OJ-104',
                activeQueueClinicName:
                    'Green Heaven Multi-Specialty Medical Center & Research',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('IN QUEUE'), findsOneWidget);
    },
  );
}
