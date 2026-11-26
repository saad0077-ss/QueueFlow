import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/entities/payment_info_entity.dart';
import 'package:patient_app/features/booking/presentation/widgets/booking_step5_receipt.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

void main() {
  testWidgets(
    'BookingStep5Receipt omits Track Live Queue Spot Now and shows booking/home buttons',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var viewedBookings = false;
      var wentHome = false;

      final appointment = AppointmentEntity(
        id: 'apt-1',
        bookingRef: 'QF-89926',
        clinicId: 'c1',
        clinicName: 'Green Heaven Clinic',
        clinicAddress: 'Panachipara, Kerala, 686122',
        customerId: 'u1',
        customerName: 'Patient',
        doctorId: 'd1',
        doctorName: 'Dr. Shams',
        doctorSpecialty: 'General Medicine',
        serviceId: 's1',
        serviceName: 'Follow-up Checkup',
        serviceDuration: 15,
        servicePrice: 350,
        dateRaw: '2026-11-26',
        timeRaw: '11:20 AM',
        dateTime: 'Thu, 26 Nov · 11:20 AM',
        payment: const PaymentInfoEntity(
          paymentId: 'pay_U4Mx6wgVLexVJB',
          amount: 350,
          method: 'Razorpay',
          paidAt: '2026-11-25',
        ),
        createdAt: DateTime(2026, 11, 25),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: BookingStep5Receipt(
                appointment: appointment,
                onViewMyBookings: () => viewedBookings = true,
                onBackToHome: () => wentHome = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Appointment Confirmed!'), findsOneWidget);
      expect(find.text('Track Live Queue Spot Now'), findsNothing);
      expect(find.text('View in My Bookings'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      await tester.ensureVisible(find.text('View in My Bookings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View in My Bookings'));
      await tester.ensureVisible(find.text('Back to Home'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back to Home'));
      expect(viewedBookings, isTrue);
      expect(wentHome, isTrue);
    },
  );
}
