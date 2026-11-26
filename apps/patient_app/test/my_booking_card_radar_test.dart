import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/presentation/widgets/my_bookings/my_booking_card.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

AppointmentEntity _apt({
  String dateRaw = '2026-11-26',
  String status = 'confirmed',
}) => AppointmentEntity(
  id: 'apt-1',
  bookingRef: 'QF-202',
  clinicId: 'c1',
  clinicName: 'Sunrise Family Care Center',
  customerId: 'u1',
  customerName: 'Alex',
  doctorId: 'd1',
  doctorName: 'Dr. Priya',
  serviceId: 's1',
  serviceName: 'General Consultation',
  dateRaw: dateRaw,
  timeRaw: '10:00 AM',
  dateTime: '$dateRaw, 10:00 AM',
  status: status,
  createdAt: DateTime(2026, 11, 25),
);

const _clinic = ClinicEntity(
  id: 'c1',
  name: 'Sunrise Family Care Center',
  initials: 'SF',
  category: 'General Medicine',
  rating: 4.8,
  reviewCount: 12,
  distance: '',
  city: 'Kochi',
  address: 'MG Road',
  phone: '9999999999',
  consultationFee: '₹300',
  openingHours: '09:00 – 18:00',
  isOpen: true,
  schedule: {
    'thursday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '18:00'},
  },
);

void main() {
  final midnight0045 = DateTime(2026, 11, 26, 0, 45);
  final morning0900 = DateTime(2026, 11, 26, 9, 0);

  testWidgets(
    'MyBookingCard removes Check-In button and gates Live Queue Radar on date, hours & open queue',
    (tester) async {
      var radarOpened = false;

      Future<void> pumpCard({
        String dateRaw = '2026-11-26',
        String status = 'confirmed',
        Map<String, dynamic>? queueDoc,
        required DateTime now,
      }) => tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: MyBookingCard(
              apt: _apt(dateRaw: dateRaw, status: status),
              onCancel: () {},
              onTrackLiveQueue: () => radarOpened = true,
              clinicOverride: _clinic,
              queueDocOverride: queueDoc,
              currentTimeOverride: now,
            ),
          ),
        ),
      );

      // 1. Future booked date -> hidden
      await pumpCard(dateRaw: '2026-11-28', now: morning0900);
      expect(find.text('Check-In to Live Queue Now'), findsNothing);
      expect(find.text('Live Queue Radar'), findsNothing);

      // 2. Booked date at 00:45 AM (before 09:00 AM operating hours) -> hidden
      await pumpCard(now: midnight0045);
      expect(find.text('Check-In to Live Queue Now'), findsNothing);
      expect(find.text('Live Queue Radar'), findsNothing);

      // 3. Open hours, queue paused or not started by clinic admin -> hidden
      await pumpCard(queueDoc: const {'status': 'paused', 'isPaused': true}, now: morning0900);
      expect(find.text('Live Queue Radar'), findsNothing);

      await pumpCard(queueDoc: const {'status': 'not_started', 'isQueueOpen': false}, now: morning0900);
      expect(find.text('Live Queue Radar'), findsNothing);

      // 4. Open hours & queue started -> Live Queue Radar visible & tappable
      await pumpCard(queueDoc: const {'status': 'open', 'isPaused': false}, now: morning0900);
      expect(find.text('Check-In to Live Queue Now'), findsNothing);
      expect(find.text('Live Queue Radar'), findsOneWidget);
      await tester.tap(find.text('Live Queue Radar'));
      expect(radarOpened, isTrue);

      // 5. Checked-in booking during open hours shows active-token radar CTA
      await pumpCard(
        status: 'checkedin',
        queueDoc: const {'status': 'open', 'isPaused': false},
        now: morning0900,
      );
      expect(find.text('Live Queue Radar · Token Active'), findsOneWidget);
    },
  );
}
