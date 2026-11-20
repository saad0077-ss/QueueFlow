import 'package:equatable/equatable.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';
import '../../domain/entities/clinic_queue_summary_entity.dart';

export 'clinic_queue_filter_events.dart';

abstract class ClinicQueueEvent extends Equatable {
  const ClinicQueueEvent();

  @override
  List<Object?> get props => [];
}

class QueueSubscriptionRequested extends ClinicQueueEvent {
  const QueueSubscriptionRequested();
}

class QueueSummaryUpdated extends ClinicQueueEvent {
  final ClinicQueueSummaryEntity summary;
  const QueueSummaryUpdated(this.summary);

  @override
  List<Object?> get props => [summary];
}

class QueueItemsUpdated extends ClinicQueueEvent {
  final List<ClinicQueueItemEntity> items;
  const QueueItemsUpdated(this.items);

  @override
  List<Object?> get props => [items];
}

class QueueCatalogUpdated extends ClinicQueueEvent {
  final List<ServiceDepartmentEntity> departments;
  final List<ClinicServiceEntity> services;

  const QueueCatalogUpdated({
    required this.departments,
    required this.services,
  });

  @override
  List<Object?> get props => [departments, services];
}

class QueueCallNextPressed extends ClinicQueueEvent {
  final String? serviceName;
  const QueueCallNextPressed([this.serviceName]);

  @override
  List<Object?> get props => [serviceName];
}

class QueueCallSpecificPressed extends ClinicQueueEvent {
  final String token;
  const QueueCallSpecificPressed(this.token);

  @override
  List<Object?> get props => [token];
}

class QueueCompletePressed extends ClinicQueueEvent {
  final String token;
  const QueueCompletePressed(this.token);

  @override
  List<Object?> get props => [token];
}

class QueueSkipPressed extends ClinicQueueEvent {
  final String token;
  const QueueSkipPressed(this.token);

  @override
  List<Object?> get props => [token];
}

class QueueRemovePressed extends ClinicQueueEvent {
  final String token;
  const QueueRemovePressed(this.token);

  @override
  List<Object?> get props => [token];
}

class QueueToggleServiceClosedPressed extends ClinicQueueEvent {
  final String service;
  const QueueToggleServiceClosedPressed(this.service);

  @override
  List<Object?> get props => [service];
}

class QueueTogglePausePressed extends ClinicQueueEvent {
  const QueueTogglePausePressed();
}

class QueueAddWalkInSubmitted extends ClinicQueueEvent {
  final String name;
  final String phone;
  final String service;
  final String? doctor;
  final String? note;
  final String? email;
  final String? department;

  const QueueAddWalkInSubmitted({
    required this.name,
    required this.phone,
    required this.service,
    this.doctor,
    this.note,
    this.email,
    this.department,
  });

  @override
  List<Object?> get props => [
    name,
    phone,
    service,
    doctor,
    note,
    email,
    department,
  ];
}
