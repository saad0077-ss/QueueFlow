import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';
import 'clinic_queue_event.dart';

class QueueDrillDownService extends ClinicQueueEvent {
  final ClinicServiceEntity? service;
  final ServiceDepartmentEntity? department;

  const QueueDrillDownService({this.service, this.department});

  @override
  List<Object?> get props => [service, department];
}

class QueueSearchChanged extends ClinicQueueEvent {
  final String query;
  const QueueSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class QueueDeptFilterChanged extends ClinicQueueEvent {
  final String departmentId;
  const QueueDeptFilterChanged(this.departmentId);

  @override
  List<Object?> get props => [departmentId];
}

class QueueStatusFilterChanged extends ClinicQueueEvent {
  final String status;
  const QueueStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class QueueSortByChanged extends ClinicQueueEvent {
  final String sortBy;
  const QueueSortByChanged(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class QueueResetFilters extends ClinicQueueEvent {
  const QueueResetFilters();
}

class QueueToggleDeptCollapsed extends ClinicQueueEvent {
  final String departmentId;
  const QueueToggleDeptCollapsed(this.departmentId);

  @override
  List<Object?> get props => [departmentId];
}

class QueueToggleAllDeptsCollapsed extends ClinicQueueEvent {
  const QueueToggleAllDeptsCollapsed();
}

class QueueServiceTabChanged extends ClinicQueueEvent {
  final String tab;
  const QueueServiceTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class QueueSelectPatient extends ClinicQueueEvent {
  final ClinicQueueItemEntity? patient;
  const QueueSelectPatient(this.patient);

  @override
  List<Object?> get props => [patient];
}

class QueueClearFeedback extends ClinicQueueEvent {
  const QueueClearFeedback();
}
