import 'dart:async';
import 'package:clinic_admin/features/dashboard/presentation/widgets/clinic_sidebar.dart';
import 'package:clinic_admin/features/revenue/domain/entities/clinic_revenue_breakdown.dart';
import 'package:clinic_admin/features/revenue/domain/entities/clinic_revenue_summary.dart';
import 'package:clinic_admin/features/revenue/domain/repositories/clinic_revenue_repository.dart';
import 'package:clinic_admin/features/revenue/presentation/pages/clinic_revenue_view.dart';
import 'package:clinic_admin/features/revenue/presentation/widgets/clinic_revenue_area_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class _FakeRevenueRepo implements ClinicRevenueRepository {
  ClinicRevenuePeriod? lastPeriod;

  @override
  Stream<ClinicRevenueSummary> watchRevenue({
    ClinicRevenuePeriod period = ClinicRevenuePeriod.month,
  }) {
    lastPeriod = period;
    final mult = period == ClinicRevenuePeriod.week ? 1.0 : 2.0;
    return Stream.value(
      ClinicRevenueSummary(
        clinicName: 'Green Heaven Clinic',
        period: period,
        netRevenue: 12500 * mult,
        grossCollected: 13000 * mult,
        pendingCollections: 0,
        refundedTotal: 500 * mult,
        razorpayRevenue: 9000 * mult,
        walkInQueueRevenue: 4000 * mult,
        razorpayCount: 14,
        walkInQueueCount: 6,
        avgTicketValue: 650,
        paidCount: 20,
        pendingCount: 0,
        refundedCount: 1,
        trendPoints: [
          DailyRevenuePoint(label: '19 Nov', amount: 4200 * mult, count: 6),
          DailyRevenuePoint(label: '25 Nov', amount: 8300 * mult, count: 14),
        ],
        channelStats: const [
          RevenueChannelStat(
            label: 'Razorpay Payments',
            amount: 9000,
            count: 14,
            sharePercent: 69.2,
            isOnline: true,
          ),
          RevenueChannelStat(
            label: 'Walk-In Queue',
            amount: 4000,
            count: 6,
            sharePercent: 30.8,
            isOnline: false,
          ),
        ],
        serviceBreakdown: const [
          RevenueServiceStat(
            serviceName: 'General Consultation',
            departmentName: 'General Medicine',
            visits: 14,
            revenue: 7000,
            sharePercent: 54,
          ),
        ],
        doctorLeaderboard: const [
          RevenueDoctorStat(
            doctorName: 'Dr. Priya',
            specialty: 'General Physician',
            consultations: 14,
            revenue: 7000,
          ),
        ],
        recentTransactions: const [
          RevenueLedgerEntry(
            id: 'tx1', bookingId: 'QF-101', receiptNo: 'REC-101',
            patientName: 'Muhammed Saad', serviceName: 'General Consultation',
            doctorName: 'Dr. Priya', dateLabel: '2026-11-25 · 10:00 AM',
            dateRaw: '2026-11-25', method: 'Razorpay Payments', status: 'paid',
            grossAmount: 500, refundAmount: 0, netAmount: 500,
          ),
          RevenueLedgerEntry(
            id: 'tx2', bookingId: 'GH-DC-001', receiptNo: 'GH-DC-001',
            patientName: 'Amina Zahra', serviceName: 'Dental Checkup',
            doctorName: 'Dr. Anand', dateLabel: '2026-11-25 · 11:30 AM',
            dateRaw: '2026-11-25', method: 'Walk-In Queue', status: 'paid',
            grossAmount: 750, refundAmount: 0, netAmount: 750,
          ),
        ],
      ),
    );
  }
}

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.darkTheme,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('ClinicRevenueView renders aligned desktop channels and switches period', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeRevenueRepo();
    await tester.pumpWidget(_wrap(ClinicRevenueView(repository: repo)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ClinicRevenueAreaChart), findsOneWidget);
    expect(find.text('Razorpay Payments'), findsWidgets);
    expect(find.text('Walk-In Queue'), findsWidgets);
    expect(find.text('Cash / POS Counter'), findsNothing);
    expect(find.text('Pending Receivables'), findsNothing);

    await tester.tap(find.text('7D'));
    await tester.pumpAndSettle();
    expect(repo.lastPeriod, ClinicRevenuePeriod.week);
    expect(find.text('₹12,500'), findsNWidgets(3));
  });

  testWidgets('ClinicRevenueView renders without overflow on narrow mobile', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(ClinicRevenueView(repository: _FakeRevenueRepo())));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Revenue Trajectory'), findsOneWidget);
  });

  testWidgets('ClinicSidebar renders Revenue navigation tab', (tester) async {
    String? tapped;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: ClinicSidebar(activeItem: 'Revenue', onItemTap: (t) => tapped = t)),
      ),
    );
    await tester.tap(find.text('Revenue'));
    expect(tapped, 'Revenue');
  });
}
