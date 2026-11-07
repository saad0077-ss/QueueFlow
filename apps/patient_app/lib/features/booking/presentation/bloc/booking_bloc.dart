import 'dart:math';
import 'package:flutter/material.dart' show DateUtils;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_app/core/utils/booking_date_formatter.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_doctor_item.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_service_item.dart';
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
      final initialFilteredDoctors = _filterDoctorsForService(doctors, initialService);
      final preDoc = event.preselectedDoctor;
      final initialDoctor =
          preDoc != null && initialFilteredDoctors.any((d) => d.id == preDoc.id)
              ? preDoc
              : (initialFilteredDoctors.isNotEmpty ? initialFilteredDoctors.first : null);

      final schedule = _scheduleFor(initialDoctor, initialService, DateTime.now());

      emit(state.copyWith(
        status: BookingStatus.ready,
        services: services,
        doctors: doctors,
        filteredDoctors: initialFilteredDoctors,
        selectedService: initialService,
        selectedDoctor: initialDoctor,
        selectedDate: schedule.date,
        availableTimeSlots: schedule.slots,
        selectedTimeSlot: schedule.slots.isNotEmpty ? schedule.slots.first : '',
        patientName: pName,
        patientPhone: pPhone,
        patientEmail: pEmail,
      ));
      await _syncAvailability(emit);
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: 'Failed to initialize booking flow: $e',
      ));
    }
  }

  Future<void> _onSelectService(
    SelectService event,
    Emitter<BookingState> emit,
  ) async {
    final filtered = _filterDoctorsForService(state.doctors, event.service);
    final currentDoc = state.selectedDoctor;
    final keep = currentDoc != null && filtered.any((d) => d.id == currentDoc.id);

    final doctor = keep ? currentDoc : (filtered.isNotEmpty ? filtered.first : null);
    final schedule = _scheduleFor(doctor, event.service, state.selectedDate);

    emit(state.copyWith(
      selectedService: event.service,
      filteredDoctors: filtered,
      selectedDoctor: doctor,
      clearSelectedDoctor: doctor == null,
      selectedDate: schedule.date,
      availableTimeSlots: schedule.slots,
      selectedTimeSlot: schedule.slots.isNotEmpty ? schedule.slots.first : '',
      bookedSlots: const {},
    ));
    await _syncAvailability(emit);
  }

  Future<void> _onSelectDoctor(
    SelectDoctor event,
    Emitter<BookingState> emit,
  ) async {
    final schedule = _scheduleFor(event.doctor, state.selectedService, state.selectedDate);
    emit(state.copyWith(
      selectedDoctor: event.doctor,
      selectedDate: schedule.date,
      availableTimeSlots: schedule.slots,
      selectedTimeSlot: schedule.slots.isNotEmpty ? schedule.slots.first : '',
      bookedSlots: const {},
    ));
    await _syncAvailability(emit);
  }

  Future<void> _onSelectDate(
    SelectDate event,
    Emitter<BookingState> emit,
  ) async {
    final slots = state.selectedDoctor?.slotsFor(event.date, state.selectedDoctor!.slotDuration) ?? const <String>[];
    emit(state.copyWith(
      selectedDate: event.date,
      availableTimeSlots: slots,
      selectedTimeSlot: slots.isNotEmpty ? slots.first : '',
      bookedSlots: const {},
    ));
    await _syncAvailability(emit);
  }

  /// Loads booked slots for the selected doctor/date (optionally re-reading
  /// doctors so admin leave/availability changes show up), picks first free slot.
  Future<void> _syncAvailability(
    Emitter<BookingState> emit, {
    bool refreshDoctors = false,
  }) async {
    final clinic = state.clinic;
    if (clinic == null) return;

    if (refreshDoctors) {
      try {
        final fresh = await bookingRepository.getClinicDoctors(clinic.id, clinic.category);
        if (fresh.isNotEmpty) {
          final cur = state.selectedDoctor;
          ClinicDoctorItem? doc;
          for (final d in fresh) {
            if (cur != null && d.id == cur.id) doc = d;
          }
          final schedule = _scheduleFor(doc, state.selectedService, state.selectedDate);
          emit(state.copyWith(
            doctors: fresh,
            filteredDoctors: _filterDoctorsForService(fresh, state.selectedService),
            selectedDoctor: doc,
            clearSelectedDoctor: doc == null,
            selectedDate: schedule.date,
            availableTimeSlots: schedule.slots,
            selectedTimeSlot: schedule.slots.isNotEmpty ? schedule.slots.first : '',
            bookedSlots: const {},
          ));
        }
      } catch (_) {}
    }

    final doctor = state.selectedDoctor;
    if (doctor == null) return;
    final date = state.selectedDate;
    final booked = await bookingRepository.getBookedSlots(
      clinicId: clinic.id,
      doctorId: doctor.id,
      date: date,
    );
    if (state.selectedDoctor?.id != doctor.id || !DateUtils.isSameDay(state.selectedDate, date)) {
      return;
    }
    String pick = state.selectedTimeSlot;
    bool isBooked(String s) => booked.contains(s.trim().toUpperCase());
    if (pick.isEmpty || isBooked(pick)) {
      pick = '';
      for (final s in state.availableTimeSlots) {
        if (!isBooked(s)) {
          pick = s;
          break;
        }
      }
    }
    emit(state.copyWith(bookedSlots: booked, selectedTimeSlot: pick));
  }

  /// Keeps [preferred] if the doctor works that day, otherwise jumps to the
  /// doctor's next bookable date (within a year) and returns its slots.
  ({DateTime date, List<String> slots}) _scheduleFor(
    ClinicDoctorItem? doctor,
    ClinicServiceItem? service,
    DateTime preferred,
  ) {
    final start = DateTime(preferred.year, preferred.month, preferred.day);
    if (doctor == null) return (date: start, slots: const <String>[]);
    final now = DateTime.now();
    var d = start.isBefore(DateTime(now.year, now.month, now.day))
        ? DateTime(now.year, now.month, now.day)
        : start;
    for (var i = 0; i < 366; i++) {
      final slots = doctor.slotsFor(d, doctor.slotDuration);
      if (slots.isNotEmpty) return (date: d, slots: slots);
      d = d.add(const Duration(days: 1));
    }
    return (date: start, slots: const <String>[]);
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

  Future<void> _onNextStep(
    NextStep event,
    Emitter<BookingState> emit,
  ) async {
    if (state.step < 4) {
      emit(state.copyWith(step: state.step + 1));
      if (state.step == 3) await _syncAvailability(emit, refreshDoctors: true);
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

  Future<void> _onGoToStep(
    GoToStep event,
    Emitter<BookingState> emit,
  ) async {
    if (event.step >= 1 && event.step <= 4) {
      emit(state.copyWith(step: event.step));
      if (event.step == 3) await _syncAvailability(emit, refreshDoctors: true);
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

  /// Doctors who serve [service]: explicitly assigned to it, listed under it,
  /// or belonging to the service's department.
  List<ClinicDoctorItem> _filterDoctorsForService(
    List<ClinicDoctorItem> doctors,
    ClinicServiceItem? service,
  ) {
    if (service == null) return doctors;
    String norm(String s) => s.toLowerCase().trim();
    final serviceName = norm(service.name);
    final dept = norm(service.departmentName);
    final assigned = service.assignedStaff.map(norm).toSet();

    return doctors.where((d) {
      final name = norm(d.name);
      if (assigned.isNotEmpty) {
        return assigned.contains(name) || assigned.contains(norm(d.id));
      }
      if (d.services.any((s) => norm(s) == serviceName)) return true;
      if (dept.isEmpty) return false;
      return norm(d.department) == dept || norm(d.specialty) == dept;
    }).toList();
  }
}
