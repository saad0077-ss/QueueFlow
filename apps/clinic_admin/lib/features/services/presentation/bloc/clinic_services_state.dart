import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_doctor_entity.dart';
import '../../domain/entities/clinic_service_entity.dart';
import '../../domain/entities/service_department_entity.dart';
import '../../domain/entities/service_plan_entity.dart';

enum ServicesStatus { initial, loading, success, failure }

class ClinicServicesState extends Equatable {
  final ServicesStatus status;
  final List<ClinicServiceEntity> services;
  final List<ServiceDepartmentEntity> departments;
  final ServicePlanEntity plan;
  final List<ClinicDoctorEntity> doctors;
  final String? toastMessage;
  final bool isErrorToast;

  const ClinicServicesState({
    this.status = ServicesStatus.initial,
    this.services = const [],
    this.departments = const [],
    this.plan = const ServicePlanEntity(),
    this.doctors = const [],
    this.toastMessage,
    this.isErrorToast = false,
  });

  bool get isLimitReached =>
      !plan.isUnlimited && services.length >= plan.servicesLimit;

  int get availableSlots =>
      plan.isUnlimited ? 999 : (plan.servicesLimit - services.length);

  ClinicServicesState copyWith({
    ServicesStatus? status,
    List<ClinicServiceEntity>? services,
    List<ServiceDepartmentEntity>? departments,
    ServicePlanEntity? plan,
    List<ClinicDoctorEntity>? doctors,
    String? toastMessage,
    bool? isErrorToast,
    bool clearToast = false,
  }) {
    return ClinicServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      departments: departments ?? this.departments,
      plan: plan ?? this.plan,
      doctors: doctors ?? this.doctors,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      isErrorToast: isErrorToast ?? this.isErrorToast,
    );
  }

  @override
  List<Object?> get props => [
    status,
    services,
    departments,
    plan,
    doctors,
    toastMessage,
    isErrorToast,
  ];
}
