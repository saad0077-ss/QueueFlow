import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/entities/doctor_plan_entity.dart';

enum DoctorsStatus { initial, loading, success, failure }

class ClinicDoctorsState extends Equatable {
  final DoctorsStatus status;
  final List<ClinicDoctorProfileEntity> doctors;
  final ClinicDoctorProfileEntity? selectedDoctor;
  final DoctorPlanEntity plan;
  final List<String> departments;
  final int waitingCount;
  final String? toastMessage;
  final bool isErrorToast;

  const ClinicDoctorsState({
    this.status = DoctorsStatus.initial,
    this.doctors = const [],
    this.selectedDoctor,
    this.plan = const DoctorPlanEntity(),
    this.departments = const [],
    this.waitingCount = 0,
    this.toastMessage,
    this.isErrorToast = false,
  });

  bool get isLimitReached => !plan.isUnlimited && doctors.length >= plan.doctorsLimit;

  int get remainingSlots => plan.isUnlimited ? 999 : (plan.doctorsLimit - doctors.length).clamp(0, 999);

  ClinicDoctorsState copyWith({
    DoctorsStatus? status,
    List<ClinicDoctorProfileEntity>? doctors,
    ClinicDoctorProfileEntity? selectedDoctor,
    bool clearSelectedDoctor = false,
    DoctorPlanEntity? plan,
    List<String>? departments,
    int? waitingCount,
    String? toastMessage,
    bool? isErrorToast,
    bool clearToast = false,
  }) {
    return ClinicDoctorsState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      selectedDoctor: clearSelectedDoctor
          ? null
          : (selectedDoctor ?? this.selectedDoctor),
      plan: plan ?? this.plan,
      departments: departments ?? this.departments,
      waitingCount: waitingCount ?? this.waitingCount,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      isErrorToast: isErrorToast ?? this.isErrorToast,
    );
  }

  @override
  List<Object?> get props => [
    status,
    doctors,
    selectedDoctor,
    plan,
    departments,
    waitingCount,
    toastMessage,
    isErrorToast,
  ];
}
