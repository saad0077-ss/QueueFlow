import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_service_entity.dart';

abstract class ClinicServicesEvent extends Equatable {
  const ClinicServicesEvent();

  @override
  List<Object?> get props => [];
}

class ServicesSubscriptionRequested extends ClinicServicesEvent {
  const ServicesSubscriptionRequested();
}

class ServicesUpdated extends ClinicServicesEvent {
  final List<ClinicServiceEntity> services;
  const ServicesUpdated(this.services);

  @override
  List<Object?> get props => [services];
}

class ServicesLoadFailed extends ClinicServicesEvent {
  final String message;
  const ServicesLoadFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class ServiceSaveSubmitted extends ClinicServicesEvent {
  final ClinicServiceEntity service;
  const ServiceSaveSubmitted(this.service);

  @override
  List<Object?> get props => [service];
}

class ServiceStatusTogglePressed extends ClinicServicesEvent {
  final String serviceId;
  final String currentStatus;
  const ServiceStatusTogglePressed(this.serviceId, this.currentStatus);

  @override
  List<Object?> get props => [serviceId, currentStatus];
}

class ServiceDeletePressed extends ClinicServicesEvent {
  final String serviceId;
  const ServiceDeletePressed(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

class ServicesClearToast extends ClinicServicesEvent {
  const ServicesClearToast();
}
