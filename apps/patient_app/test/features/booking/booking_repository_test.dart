import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/entities/payment_info_entity.dart';

void main() {
  group('BookingRepositoryImpl Tests', () {
    late BookingRepositoryImpl repository;

    setUp(() {
      repository = BookingRepositoryImpl();
    });

    test('getClinicServices returns fallback list for dental category when firestore is not mocked', () async {
      final services = await repository.getClinicServices('smile-dental', 'Dentistry');
      expect(services, isNotEmpty);
      expect(services.any((s) => s.name.contains('Dental') || s.name.contains('Teeth')), isTrue);
    });

    test('getClinicDoctors returns fallback list for dental category', () async {
      final doctors = await repository.getClinicDoctors('smile-dental', 'Dentistry');
      expect(doctors, isNotEmpty);
      expect(doctors.any((d) => d.name.contains('Dr.')), isTrue);
    });

    test('getAvailableTimeSlots returns valid consultation slots', () async {
      final slots = await repository.getAvailableTimeSlots(
        clinicId: 'smile-dental',
        doctorId: 'd-1',
        date: DateTime.now(),
      );
      expect(slots, contains('11:00 AM'));
      expect(slots.length, greaterThanOrEqualTo(5));
    });

    test('createAppointment adds new appointment with valid QF reference code', () async {
      final newApt = AppointmentEntity(
        id: 'test-apt-01',
        bookingRef: '', // will be auto-generated as QF-XXXXX
        clinicId: 'smile-dental',
        clinicName: 'Smile Dental Clinic',
        clinicAddress: '14 MG Road, Kochi',
        customerId: 'user-test-01',
        customerName: 'Aisha Rahman',
        customerPhone: '+91 98765 43210',
        customerEmail: 'aisha@example.com',
        doctorId: 'd-1',
        doctorName: 'Dr. Rahul Menon',
        doctorSpecialty: 'Orthodontics',
        serviceId: 's-1',
        serviceName: 'Dental Consultation',
        serviceDuration: 20,
        servicePrice: 400,
        dateRaw: '2026-11-10',
        timeRaw: '11:00 AM',
        dateTime: 'Tue, 10 Nov · 11:00 AM',
        status: 'confirmed',
        payment: const PaymentInfoEntity(
          paymentId: 'pay_test_unit123',
          amount: 400,
          method: 'UPI (GPay)',
          paidAt: '11:00 AM',
        ),
        createdAt: DateTime.now(),
      );

      final result = await repository.createAppointment(newApt);
      expect(result.bookingRef, startsWith('QF-'));
      expect(result.customerName, equals('Aisha Rahman'));

      final list = await repository.getUserAppointments(customerId: 'user-test-01');
      expect(list.any((a) => a.bookingRef == result.bookingRef), isTrue);
    });
  });
}
