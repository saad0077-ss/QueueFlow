import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';
import 'package:patient_app/features/profile/domain/utils/booking_queue_access_evaluator.dart';
import 'package:patient_app/features/profile/presentation/widgets/booking_history/booking_history_card.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

AppointmentEntity _apt({required String dateRaw, String service = 'General'}) {
  return AppointmentEntity(
    id: 'a1',
    bookingRef: 'QF-101',
    clinicId: 'c1',
    clinicName: 'Green Heaven Clinic',
    customerId: 'u1',
    customerName: 'Alex',
    doctorId: 'd1',
    doctorName: 'Dr. Priya',
    serviceId: 's1',
    serviceName: service,
    dateRaw: dateRaw,
    timeRaw: '09:30 AM',
    dateTime: '$dateRaw, 09:30 AM',
    status: 'confirmed',
    createdAt: DateTime(2026, 11, 20),
  );
}

const _clinic = ClinicEntity(
  id: 'c1',
  name: 'Green Heaven Clinic',
  initials: 'GH',
  category: 'General Medicine',
  rating: 4.5,
  reviewCount: 2,
  distance: '',
  city: 'Kochi',
  address: 'Panachipara',
  phone: '9999999999',
  consultationFee: '₹500',
  openingHours: '09:00 – 18:00',
  isOpen: true,
  currentToken: 'A-1',
  waitingCount: 0,
  schedule: {
    'wednesday': {
      'isOpen': true,
      'openTime': '09:00',
      'closeTime': '18:00',
      'hasBreak': true,
      'breakStart': '13:00',
      'breakEnd': '14:00',
    },
  },
);

void main() {
  final wed830 = DateTime(2026, 11, 25, 8, 30);
  final wed900 = DateTime(2026, 11, 25, 9, 0);
  final wed1315 = DateTime(2026, 11, 25, 13, 15);

  test('disables before consultation date and before operating hours', () {
    final futureRes = BookingQueueAccessEvaluator.evaluate(
      appointment: _apt(dateRaw: '2026-11-28'),
      clinic: _clinic,
      currentTime: wed900,
    );
    expect(futureRes.isEnabled, isFalse);
    expect(futureRes.reason, 'Opens on 28 Nov');

    final earlyRes = BookingQueueAccessEvaluator.evaluate(
      appointment: _apt(dateRaw: '2026-11-25'),
      clinic: _clinic,
      currentTime: wed830,
    );
    expect(earlyRes.isEnabled, isFalse);
    expect(earlyRes.reason, 'Opens at 9:00 AM');
  });

  test('enables at operating hours start and respects admin pause/break', () {
    final openRes = BookingQueueAccessEvaluator.evaluate(
      appointment: _apt(dateRaw: '2026-11-25'),
      clinic: _clinic,
      queueDoc: const {'status': 'open', 'isPaused': false},
      currentTime: wed900,
    );
    expect(openRes.isEnabled, isTrue);

    final pausedRes = BookingQueueAccessEvaluator.evaluate(
      appointment: _apt(dateRaw: '2026-11-25'),
      clinic: _clinic,
      queueDoc: const {'status': 'paused', 'isPaused': true},
      currentTime: wed900,
    );
    expect(pausedRes.isEnabled, isFalse);
    expect(pausedRes.reason, 'Queue paused');

    final breakRes = BookingQueueAccessEvaluator.evaluate(
      appointment: _apt(dateRaw: '2026-11-25'),
      clinic: _clinic,
      currentTime: wed1315,
    );
    expect(breakRes.isEnabled, isFalse);
    expect(breakRes.reason, 'Break till 2:00 PM');
  });

  testWidgets('Join / Track Queue button toggles cleanly on BookingHistoryCard',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var tapped = false;
    Widget buildCard(DateTime now) => MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BookingHistoryCard(
            appointment: _apt(dateRaw: '2026-11-25'),
            clinicOverride: _clinic,
            currentTimeOverride: now,
            onTrackQueue: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.pumpWidget(buildCard(wed830));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Opens at 9:00 AM'), findsOneWidget);
    final disabledBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(disabledBtn.onPressed, isNull);

    await tester.pumpWidget(buildCard(wed900));
    await tester.pumpAndSettle();
    final enabledBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(enabledBtn.onPressed, isNotNull);
    await tester.tap(find.text('Join / Track Queue'));
    expect(tapped, isTrue);
  });
}
