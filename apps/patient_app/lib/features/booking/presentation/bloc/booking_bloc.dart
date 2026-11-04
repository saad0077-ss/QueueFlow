import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_app/core/utils/booking_date_formatter.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_doctor_item.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:patient_app/features/booking/domain/usecases/create_appointment_usecase.dart';
import 'package:patient_app/features/booking/presentation/bloc/booking_event.dart';
import 'package:patient_app/features/booking/presentation/bloc/booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;
  final CreateAppointmentUseCase createAppointmentUseCase;
  final FirebaseAuth? _firebaseAuth;

  BookingBloc({
    required this.bookingRepository,
    required this.createAppointmentUseCase,
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? _safeAuth(),
        super(BookingState(selectedDate: DateTime.now())) {
    on<InitBookingWizard>(_onInitBookingWizard);
    on<SelectService>(_onSelectService);
    on<SelectDoctor>(_onSelectDoctor);
    on<SelectDate>(_onSelectDate);
    on<SelectTimeSlot>(_onSelectTimeSlot);
    on<UpdatePatientDetails>(_onUpdatePatientDetails);
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<GoToStep>(_onGoToStep);
    on<ConfirmPaymentAndBook>(_onConfirmPaymentAndBook);
    on<ResetBooking>(_onResetBooking);
  }

  static FirebaseAuth? _safeAuth() {
    try {
      if (Firebase.apps.isNotEmpty) return FirebaseAuth.instance;
    } catch (_) {}
    return null;
  }

  Future<void> _onInitBookingWizard(
    InitBookingWizard event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(
      status: BookingStatus.loading,
      clinic: event.clinic,
      step: 1,
      clearError: true,
    ));

    try {
      final services = await bookingRepository.getClinicServices(
        event.clinic.id,
        event.clinic.category,
      );

      final doctors = await bookingRepository.getClinicDoctors(
        event.clinic.id,
        event.clinic.category,
      );

      final today = DateTime.now();
      final slots = await bookingRepository.getAvailableTimeSlots(
        clinicId: event.clinic.id,
        doctorId: doctors.isNotEmpty ? doctors.first.id : '',
        date: today,
      );

      // Prepopulate logged in user info
      final currentUser = _firebaseAuth?.currentUser;
      String pName = 'Aisha Rahman';
      String pPhone = '+91 98765 43210';
      String pEmail = 'aisha@example.com';

      if (currentUser?.displayName != null && currentUser!.displayName!.trim().isNotEmpty) {
        pName = currentUser.displayName!.trim();
      }
      if (currentUser?.phoneNumber != null && currentUser!.phoneNumber!.trim().isNotEmpty) {
        pPhone = currentUser.phoneNumber!.trim();
      }
      if (currentUser?.email != null && currentUser!.email!.trim().isNotEmpty) {
        pEmail = currentUser.email!.trim();
      }

      final initialService = event.preselectedService ?? (services.isNotEmpty ? services.first : null);
      final initialFilteredDoctors = _filterDoctorsForService(doctors, initialService?.name);
      final initialDoctor = event.preselectedDoctor ??
          (initialFilteredDoctors.isNotEmpty
              ? initialFilteredDoctors.first
              : (doctors.isNotEmpty ? doctors.first : null));

      emit(state.copyWith(
        status: BookingStatus.ready,
        services: services,
        doctors: doctors,
        filteredDoctors: initialFilteredDoctors,
        selectedService: initialService,
        selectedDoctor: initialDoctor,
        selectedDate: today,
        availableTimeSlots: slots,
        selectedTimeSlot: slots.contains('11:00 AM') ? '11:00 AM' : (slots.isNotEmpty ? slots.first : '09:30 AM'),
        patientName: pName,
        patientPhone: pPhone,
        patientEmail: pEmail,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: 'Failed to initialize booking flow: $e',
      ));
    }
  }

  void _onSelectService(
    SelectService event,
    Emitter<BookingState> emit,
  ) {
    final filtered = _filterDoctorsForService(state.doctors, event.service.name);
    final currentDoc = state.selectedDoctor;
    ClinicDoctorItem? doctor = currentDoc;
    if (currentDoc == null || !filtered.any((d) => d.id == currentDoc.id || d.name == currentDoc.name)) {
      doctor = filtered.isNotEmpty ? filtered.first : (state.doctors.isNotEmpty ? state.doctors.first : null);
    }

    emit(state.copyWith(
      selectedService: event.service,
      filteredDoctors: filtered,
      selectedDoctor: doctor,
    ));
  }

  void _onSelectDoctor(
    SelectDoctor event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(selectedDoctor: event.doctor));
  }

  void _onSelectDate(
    SelectDate event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onSelectTimeSlot(
    SelectTimeSlot event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(selectedTimeSlot: event.timeSlot));
  }

  void _onUpdatePatientDetails(
    UpdatePatientDetails event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      patientName: event.name ?? state.patientName,
      patientPhone: event.phone ?? state.patientPhone,
      patientNotes: event.notes ?? state.patientNotes,
    ));
  }

  void _onNextStep(
    NextStep event,
    Emitter<BookingState> emit,
  ) {
    if (state.step < 4) {
      emit(state.copyWith(step: state.step + 1));
    }
  }

  void _onPreviousStep(
    PreviousStep event,
    Emitter<BookingState> emit,
  ) {
    if (state.step > 1) {
      emit(state.copyWith(step: state.step - 1));
    }
  }

  void _onGoToStep(
    GoToStep event,
    Emitter<BookingState> emit,
  ) {
    if (event.step >= 1 && event.step <= 4) {
      emit(state.copyWith(step: event.step));
    }
  }

  Future<void> _onConfirmPaymentAndBook(
    ConfirmPaymentAndBook event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingStatus.submitting));

    final clinic = state.clinic;
    final service = state.selectedService;
    final doctor = state.selectedDoctor;

    if (clinic == null || service == null || doctor == null) {
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: 'Missing clinic, service, or doctor details.',
      ));
      return;
    }

    final rand = 10000 + Random().nextInt(90000);
    final bookingRef = 'QF-$rand';
    final dateTimeFormatted = BookingDateFormatter.formatDateTime(
      state.selectedDate,
      state.selectedTimeSlot,
    );
    final dateRaw = BookingDateFormatter.formatRawDate(state.selectedDate);

    final appointment = AppointmentEntity(
      id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
      bookingRef: bookingRef,
      clinicId: clinic.id,
      clinicName: clinic.name,
      clinicAddress: clinic.address,
      customerId: _firebaseAuth?.currentUser?.uid ?? 'guest-patient',
      customerName: state.patientName,
      customerPhone: state.patientPhone,
      customerEmail: state.patientEmail,
      doctorId: doctor.id,
      doctorName: doctor.name,
      doctorSpecialty: doctor.specialty,
      serviceId: service.id,
      serviceName: service.name,
      serviceDuration: service.duration,
      servicePrice: service.price.toDouble(),
      dateRaw: dateRaw,
      timeRaw: state.selectedTimeSlot,
      dateTime: dateTimeFormatted,
      status: 'confirmed',
      payment: event.paymentInfo,
      notes: state.patientNotes,
      createdAt: DateTime.now(),
    );

    try {
      final savedAppointment = await createAppointmentUseCase(appointment);
      emit(state.copyWith(
        status: BookingStatus.success,
        step: 5,
        confirmedAppointment: savedAppointment,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: 'Error securing booking: $e',
      ));
    }
  }

  void _onResetBooking(
    ResetBooking event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      step: 1,
      status: BookingStatus.ready,
      clearError: true,
    ));
  }

  List<ClinicDoctorItem> _filterDoctorsForService(
    List<ClinicDoctorItem> doctors,
    String? serviceName,
  ) {
    if (serviceName == null || serviceName.isEmpty) return doctors;
    final nameLower = serviceName.toLowerCase();

    final matching = doctors.where((d) {
      if (d.services.isEmpty) return true;
      return d.services.any((s) => s.toLowerCase().contains(nameLower) || nameLower.contains(s.toLowerCase()));
    }).toList();

    return matching.isNotEmpty ? matching : doctors;
  }
}
