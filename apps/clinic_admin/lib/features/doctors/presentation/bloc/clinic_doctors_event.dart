import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/entities/doctor_daily_schedule.dart';

abstract class ClinicDoctorsEvent extends Equatable {
  const ClinicDoctorsEvent();

  @override
  List<Object?> get props => [];
}

class DoctorsSubscriptionRequested extends ClinicDoctorsEvent {
  const DoctorsSubscriptionRequested();
}

class DoctorsUpdated extends ClinicDoctorsEvent {
  final List<ClinicDoctorProfileEntity> doctors;

  const DoctorsUpdated(this.doctors);

  @override
  List<Object?> get props => [doctors];
}

class DoctorsLoadFailed extends ClinicDoctorsEvent {
  final String message;

  const DoctorsLoadFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class DoctorSelected extends ClinicDoctorsEvent {
  final ClinicDoctorProfileEntity? doctor;

  const DoctorSelected(this.doctor);

  @override
  List<Object?> get props => [doctor];
}

class DoctorAddSubmitted extends ClinicDoctorsEvent {
  final ClinicDoctorProfileEntity doctor;

  const DoctorAddSubmitted(this.doctor);

  @override
  List<Object?> get props => [doctor];
}

class DoctorProfileUpdated extends ClinicDoctorsEvent {
  final ClinicDoctorProfileEntity doctor;

  const DoctorProfileUpdated(this.doctor);

  @override
  List<Object?> get props => [doctor];
}

class DoctorScheduleUpdated extends ClinicDoctorsEvent {
  final String doctorId;
  final Map<String, DoctorDailySchedule> schedule;
  final int slotDuration;
  final List<String>? leaveDates;

  const DoctorScheduleUpdated({
    required this.doctorId,
    required this.schedule,
    required this.slotDuration,
    this.leaveDates,
  });

  @override
  List<Object?> get props => [doctorId, schedule, slotDuration, leaveDates];
}

class DoctorAccountStatusToggled extends ClinicDoctorsEvent {
  final String doctorId;

  const DoctorAccountStatusToggled(this.doctorId);

  @override
  List<Object?> get props => [doctorId];
}

class DoctorAccountStatusChanged extends ClinicDoctorsEvent {
  final String doctorId;
  final String accountStatus;

  const DoctorAccountStatusChanged({
    required this.doctorId,
    required this.accountStatus,
  });

  @override
  List<Object?> get props => [doctorId, accountStatus];
}

class DoctorStatusChanged extends ClinicDoctorsEvent {
  final String doctorId;
  final String status;

  const DoctorStatusChanged({required this.doctorId, required this.status});

  @override
  List<Object?> get props => [doctorId, status];
}

class DoctorDeletePressed extends ClinicDoctorsEvent {
  final String doctorId;
  final String doctorName;

  const DoctorDeletePressed({required this.doctorId, required this.doctorName});

  @override
  List<Object?> get props => [doctorId, doctorName];
}

class DoctorCallNextPressed extends ClinicDoctorsEvent {
  final String doctorName;

  const DoctorCallNextPressed(this.doctorName);

  @override
  List<Object?> get props => [doctorName];
}

class DoctorsClearToast extends ClinicDoctorsEvent {
  const DoctorsClearToast();
}
