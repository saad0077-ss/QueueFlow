import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:patient_app/features/booking/presentation/pages/booking_wizard_screen.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_doctor_item.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_service_item.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';

class MockTestBookingRepository implements BookingRepository {
  final List<ClinicServiceItem> mockServices = const [
    ClinicServiceItem(
      id: 's-1',
      name: 'General Consultation',
      price: 500,
      duration: 20,
      departmentName: 'General Medicine',
    ),
  ];

  final List<ClinicDoctorItem> mockDoctors = const [
    ClinicDoctorItem(
      id: 'd-1',
      name: 'Dr. Priya Sharma',
      initials: 'PS',
      title: 'Senior Consultant',
      services: ['General Consultation'],
    ),
  ];

  @override
  Future<List<ClinicServiceItem>> getClinicServices(String clinicId, String category) async =>
      mockServices;

  @override
  Future<List<ClinicDoctorItem>> getClinicDoctors(String clinicId, String category) async =>
      mockDoctors;

  @override
  Future<List<String>> getAvailableTimeSlots({
    required String clinicId,
    required String doctorId,
    required DateTime date,
  }) async =>
      ['09:30 AM', '11:00 AM', '02:15 PM'];

  @override
  Future<AppointmentEntity> createAppointment(AppointmentEntity appointment) async =>
      appointment.copyWith(bookingRef: 'QF-12345');

  @override
  Future<List<AppointmentEntity>> getUserAppointments({String? customerId, String? customerEmail}) async =>
      [];

  @override
  Stream<List<AppointmentEntity>> watchUserAppointments({String? customerId, String? customerEmail}) =>
      const Stream.empty();

  @override
  Future<void> cancelAppointment(String appointmentId) async {}
}

void main() {
  const testClinic = ClinicEntity(
    id: 'sunrise-health',
    name: 'Sunrise Health Clinic',
    initials: 'SH',
    category: 'General',
    rating: 4.9,
    reviewCount: 210,
    distance: '0.8 km',
    city: 'Kochi',
    address: 'Kaloor, Kochi',
    phone: '+91 484 123 4567',
    consultationFee: '₹500',
    openingHours: 'Mon–Sat, 8:00 AM – 8:00 PM',
  );

  testWidgets('BookingWizardScreen renders Stepper and Step 1, navigates to Step 2', (tester) async {
    final mockRepo = MockTestBookingRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: BookingWizardScreen(
          clinic: testClinic,
          bookingRepository: mockRepo,
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Title and Step 1
    expect(find.text('Book appointment'), findsOneWidget);
    expect(find.text('Service'), findsOneWidget);
    expect(find.text('Doctor'), findsOneWidget);
    expect(find.text('Date & Time'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Choose a service'), findsOneWidget);
    expect(find.text('General Consultation'), findsOneWidget);
    expect(find.text('Continue to Doctor'), findsOneWidget);

    // Tap Continue to Doctor
    await tester.tap(find.text('Continue to Doctor'));
    await tester.pumpAndSettle();

    // Verify Step 2 rendered
    expect(find.text('Choose a doctor'), findsOneWidget);
    expect(find.text('Dr. Priya Sharma'), findsOneWidget);
    expect(find.text('Continue to Schedule'), findsOneWidget);
  });
}
