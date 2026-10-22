import 'package:equatable/equatable.dart';

import '../../domain/entities/department_entity.dart';
import '../../domain/entities/dept_expansion_request_entity.dart';
import '../../domain/entities/dept_service_request_entity.dart';

abstract class DepartmentsEvent extends Equatable {
  const DepartmentsEvent();

  @override
  List<Object?> get props => [];
}

class DepartmentsListUpdated extends DepartmentsEvent {
  final List<DepartmentEntity> departments;
  const DepartmentsListUpdated(this.departments);

  @override
  List<Object?> get props => [departments];
}

class ExpansionRequestsUpdated extends DepartmentsEvent {
  final List<DeptExpansionRequestEntity> requests;
  const ExpansionRequestsUpdated(this.requests);

  @override
  List<Object?> get props => [requests];
}

class ServiceRequestsUpdated extends DepartmentsEvent {
  final List<DeptServiceRequestEntity> requests;
  const ServiceRequestsUpdated(this.requests);

  @override
  List<Object?> get props => [requests];
}

class DepartmentSearchQueryChanged extends DepartmentsEvent {
  final String query;
  const DepartmentSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class DepartmentStatusFilterChanged extends DepartmentsEvent {
  final String status;
  const DepartmentStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class DepartmentClinicFilterChanged extends DepartmentsEvent {
  final String clinic;
  const DepartmentClinicFilterChanged(this.clinic);

  @override
  List<Object?> get props => [clinic];
}

class DepartmentsResetFilters extends DepartmentsEvent {
  const DepartmentsResetFilters();
}
