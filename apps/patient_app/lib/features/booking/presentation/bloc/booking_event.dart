import 'package:equatable/equatable.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_doctor_item.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_service_item.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';
import 'package:patient_app/features/booking/domain/entities/payment_info_entity.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class InitBookingWizard extends BookingEvent {
  final ClinicEntity clinic;
  final ClinicServiceItem? preselectedService;
  final ClinicDoctorItem? preselectedDoctor;

  const InitBookingWizard({
    required this.clinic,
    this.preselectedService,
    this.preselectedDoctor,
  });

  @override
  List<Object?> get props => [clinic, preselectedService, preselectedDoctor];
}

class SelectService extends BookingEvent {
  final ClinicServiceItem service;

  const SelectService(this.service);

  @override
  List<Object?> get props => [service];
}

class SelectDoctor extends BookingEvent {
  final ClinicDoctorItem doctor;

  const SelectDoctor(this.doctor);

  @override
  List<Object?> get props => [doctor];
}

class SelectDate extends BookingEvent {
  final DateTime date;

  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectTimeSlot extends BookingEvent {
  final String timeSlot;

  const SelectTimeSlot(this.timeSlot);

  @override
  List<Object?> get props => [timeSlot];
}

class UpdatePatientDetails extends BookingEvent {
  final String? name;
  final String? phone;
  final String? notes;

  const UpdatePatientDetails({this.name, this.phone, this.notes});

  @override
  List<Object?> get props => [name, phone, notes];
}

class NextStep extends BookingEvent {
  const NextStep();
}

class PreviousStep extends BookingEvent {
  const PreviousStep();
}

class GoToStep extends BookingEvent {
  final int step;

  const GoToStep(this.step);

  @override
  List<Object?> get props => [step];
}

class ConfirmPaymentAndBook extends BookingEvent {
  final PaymentInfoEntity paymentInfo;

  const ConfirmPaymentAndBook(this.paymentInfo);

  @override
  List<Object?> get props => [paymentInfo];
}

class ResetBooking extends BookingEvent {
  const ResetBooking();
}
