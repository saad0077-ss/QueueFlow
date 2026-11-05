import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_appointment_entity.dart';

abstract class ClinicAppointmentsEvent extends Equatable {
  const ClinicAppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class StartWatchingAppointments extends ClinicAppointmentsEvent {
  const StartWatchingAppointments();
}

class AppointmentsUpdated extends ClinicAppointmentsEvent {
  final List<ClinicAppointmentEntity> appointments;
  const AppointmentsUpdated(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class ChangeDateRangeFilter extends ClinicAppointmentsEvent {
  final String dateRange; // 'all', 'today', 'week'
  const ChangeDateRangeFilter(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

class ChangeDepartmentFilter extends ClinicAppointmentsEvent {
  final String department;
  const ChangeDepartmentFilter(this.department);

  @override
  List<Object?> get props => [department];
}

class ChangeServiceFilter extends ClinicAppointmentsEvent {
  final String service;
  const ChangeServiceFilter(this.service);

  @override
  List<Object?> get props => [service];
}

class ChangeDoctorFilter extends ClinicAppointmentsEvent {
  final String doctor;
  const ChangeDoctorFilter(this.doctor);

  @override
  List<Object?> get props => [doctor];
}

class ChangeStatusFilter extends ClinicAppointmentsEvent {
  final String status;
  const ChangeStatusFilter(this.status);

  @override
  List<Object?> get props => [status];
}

class ChangePaymentFilter extends ClinicAppointmentsEvent {
  final String payment;
  const ChangePaymentFilter(this.payment);

  @override
  List<Object?> get props => [payment];
}

class ChangeSearchQuery extends ClinicAppointmentsEvent {
  final String query;
  const ChangeSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}

class ResetAppointmentFilters extends ClinicAppointmentsEvent {
  const ResetAppointmentFilters();
}

class ToggleAppointmentViewMode extends ClinicAppointmentsEvent {
  final String viewMode; // 'list' or 'calendar'
  const ToggleAppointmentViewMode(this.viewMode);

  @override
  List<Object?> get props => [viewMode];
}

class SelectAppointment extends ClinicAppointmentsEvent {
  final ClinicAppointmentEntity? appointment;
  const SelectAppointment(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class SelectCalendarDate extends ClinicAppointmentsEvent {
  final DateTime selectedDate;
  const SelectCalendarDate(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

class CheckInAppointment extends ClinicAppointmentsEvent {
  final String id;
  const CheckInAppointment(this.id);

  @override
  List<Object?> get props => [id];
}

class CompleteAppointment extends ClinicAppointmentsEvent {
  final String id;
  const CompleteAppointment(this.id);

  @override
  List<Object?> get props => [id];
}

class RescheduleAppointment extends ClinicAppointmentsEvent {
  final String id;
  final String newDate;
  final String newTime;
  const RescheduleAppointment({
    required this.id,
    required this.newDate,
    required this.newTime,
  });

  @override
  List<Object?> get props => [id, newDate, newTime];
}

class CancelAppointment extends ClinicAppointmentsEvent {
  final String id;
  final String? reason;
  final double? refundAmount;
  const CancelAppointment(this.id, {this.reason, this.refundAmount});

  @override
  List<Object?> get props => [id, reason, refundAmount];
}

class CreateAppointment extends ClinicAppointmentsEvent {
  final ClinicAppointmentEntity appointment;
  const CreateAppointment(this.appointment);

  @override
  List<Object?> get props => [appointment];
}
