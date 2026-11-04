import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/entities/payment_info_entity.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:patient_app/features/booking/domain/usecases/create_appointment_usecase.dart';
import 'package:patient_app/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:patient_app/features/booking/presentation/bloc/booking_event.dart';
import 'package:patient_app/features/booking/presentation/bloc/booking_state.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_doctor_item.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_service_item.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';

class MockBookingRepository implements BookingRepository {
  final List<ClinicServiceItem> mockServices = const [
    ClinicServiceItem(id: 's-1', name: 'Dental Checkup', price: 500, duration: 20),
    ClinicServiceItem(id: 's-2', name: 'Teeth Cleaning', price: 900, duration: 30),
  ];

  final List<ClinicDoctorItem> mockDoctors = const [
    ClinicDoctorItem(
      id: 'd-1',
      name: 'Dr. Rahul Menon',
      initials: 'RM',
      title: 'Orthodontist',
      services: ['Teeth Cleaning'],
    ),
    ClinicDoctorItem(
      id: 'd-2',
      name: 'Dr. Fatima Noor',
      initials: 'FN',
      title: 'Cosmetic Dentist',
      services: ['Dental Checkup'],
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
      appointment.copyWith(bookingRef: 'QF-48210');

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
  group('BookingBloc Tests', () {
    late MockBookingRepository mockRepo;
    late CreateAppointmentUseCase createAppointmentUseCase;
    late BookingBloc bloc;

    const testClinic = ClinicEntity(
      id: 'smile-dental',
      name: 'Smile Dental Clinic',
      initials: 'SD',
      category: 'Dentistry',
      rating: 4.8,
      reviewCount: 120,
      distance: '1.2 km',
      city: 'Kochi',
      address: '14 MG Road',
      phone: '+91 484 234 5678',
      consultationFee: '₹500',
      openingHours: 'Mon–Sat, 9:00 AM – 8:00 PM',
    );

    setUp(() {
      mockRepo = MockBookingRepository();
      createAppointmentUseCase = CreateAppointmentUseCase(mockRepo);
      bloc = BookingBloc(
        bookingRepository: mockRepo,
        createAppointmentUseCase: createAppointmentUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has step 1 and initial status', () {
      expect(bloc.state.step, equals(1));
      expect(bloc.state.status, equals(BookingStatus.initial));
    });

    test('InitBookingWizard initializes services, doctors, and slots', () async {
      bloc.add(const InitBookingWizard(clinic: testClinic));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BookingState>((s) => s.status == BookingStatus.loading),
          predicate<BookingState>((s) =>
              s.status == BookingStatus.ready &&
              s.services.length == 2 &&
              s.doctors.length == 2 &&
              s.selectedService != null),
        ]),
      );
    });

    test('step navigation and payment flow transitions to step 5', () async {
      bloc.add(const InitBookingWizard(clinic: testClinic));
      await bloc.stream.firstWhere((s) => s.status == BookingStatus.ready);

      // Step 1 -> Step 2
      bloc.add(const NextStep());
      await expectLater(
        bloc.stream,
        emits(predicate<BookingState>((s) => s.step == 2)),
      );

      // Step 2 -> Step 3
      bloc.add(const NextStep());
      await expectLater(
        bloc.stream,
        emits(predicate<BookingState>((s) => s.step == 3)),
      );

      // Select Slot
      bloc.add(const SelectTimeSlot('02:15 PM'));
      await expectLater(
        bloc.stream,
        emits(predicate<BookingState>((s) => s.selectedTimeSlot == '02:15 PM')),
      );

      // Step 3 -> Step 4 (Confirm)
      bloc.add(const NextStep());
      await expectLater(
        bloc.stream,
        emits(predicate<BookingState>((s) => s.step == 4)),
      );

      // Confirm Payment
      const payment = PaymentInfoEntity(
        paymentId: 'pay_test_9999',
        amount: 500,
        method: 'UPI (Google Pay)',
        paidAt: '12:00 PM',
      );
      bloc.add(const ConfirmPaymentAndBook(payment));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BookingState>((s) => s.status == BookingStatus.submitting),
          predicate<BookingState>((s) =>
              s.status == BookingStatus.success &&
              s.step == 5 &&
              s.confirmedAppointment?.bookingRef == 'QF-48210'),
        ]),
      );
    });
  });
}
