import 'package:equatable/equatable.dart';
import 'package:patient_app/core/utils/booking_date_formatter.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_doctor_item.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_service_item.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';

enum BookingStatus { initial, loading, ready, submitting, success, failure }

class BookingState extends Equatable {
  final BookingStatus status;
  final int step; // 1, 2, 3, 4, 5
  final ClinicEntity? clinic;
  final List<ClinicServiceItem> services;
  final List<ClinicDoctorItem> doctors;
  final List<ClinicDoctorItem> filteredDoctors;
  final ClinicServiceItem? selectedService;
  final ClinicDoctorItem? selectedDoctor;
  final DateTime selectedDate;
  final List<String> availableTimeSlots;
  final String selectedTimeSlot;
  final Set<String> bookedSlots;
  final String patientName;
  final String patientPhone;
  final String patientEmail;
  final String patientNotes;
  final AppointmentEntity? confirmedAppointment;
  final String? errorMessage;

  const BookingState({
    this.bookedSlots = const {},
    this.status = BookingStatus.initial,
    this.step = 1,
    this.clinic,
    this.services = const [],
    this.doctors = const [],
    this.filteredDoctors = const [],
    this.selectedService,
    this.selectedDoctor,
    required this.selectedDate,
    this.availableTimeSlots = const [],
    this.selectedTimeSlot = '11:00 AM',
    this.patientName = 'Aisha Rahman',
    this.patientPhone = '+91 98765 43210',
    this.patientEmail = 'aisha@example.com',
    this.patientNotes = '',
    this.confirmedAppointment,
    this.errorMessage,
  });

  double get payableFee => selectedService?.price.toDouble() ?? 500.0;
  String get formattedPayableFee => '₹${payableFee.toStringAsFixed(2)}';

  String get formattedSchedule => BookingDateFormatter.formatDateTime(
        selectedDate,
        selectedTimeSlot,
      );

  String get rawDateFormatted => BookingDateFormatter.formatRawDate(selectedDate);

  bool get canProceedStep1 => selectedService != null;
  bool get canProceedStep2 => selectedDoctor != null;
  bool get canProceedStep3 => selectedTimeSlot.isNotEmpty;

  BookingState copyWith({
    BookingStatus? status,
    int? step,
    ClinicEntity? clinic,
    List<ClinicServiceItem>? services,
    List<ClinicDoctorItem>? doctors,
    List<ClinicDoctorItem>? filteredDoctors,
    ClinicServiceItem? selectedService,
    ClinicDoctorItem? selectedDoctor,
    DateTime? selectedDate,
    List<String>? availableTimeSlots,
    String? selectedTimeSlot,
    Set<String>? bookedSlots,
    String? patientName,
    String? patientPhone,
    String? patientEmail,
    String? patientNotes,
    AppointmentEntity? confirmedAppointment,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedDoctor = false,
  }) {
    return BookingState(
      status: status ?? this.status,
      step: step ?? this.step,
      clinic: clinic ?? this.clinic,
      services: services ?? this.services,
      doctors: doctors ?? this.doctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      selectedService: selectedService ?? this.selectedService,
      selectedDoctor:
          clearSelectedDoctor ? null : (selectedDoctor ?? this.selectedDoctor),
      selectedDate: selectedDate ?? this.selectedDate,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      bookedSlots: bookedSlots ?? this.bookedSlots,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientEmail: patientEmail ?? this.patientEmail,
      patientNotes: patientNotes ?? this.patientNotes,
      confirmedAppointment: confirmedAppointment ?? this.confirmedAppointment,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        step,
        clinic,
        services,
        doctors,
        filteredDoctors,
        selectedService,
        selectedDoctor,
        selectedDate,
        availableTimeSlots,
        selectedTimeSlot,
        bookedSlots,
        patientName,
        patientPhone,
        patientEmail,
        patientNotes,
        confirmedAppointment,
        errorMessage,
      ];
}
