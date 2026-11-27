import 'package:equatable/equatable.dart';

import '../../domain/entities/clinic_entity.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeInitialDataRequested extends HomeEvent {
  const HomeInitialDataRequested();
}

class HomeClinicsUpdated extends HomeEvent {
  final List<ClinicEntity> clinics;

  const HomeClinicsUpdated(this.clinics);

  @override
  List<Object?> get props => [clinics];
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

class HomeCategorySelected extends HomeEvent {
  final String category;

  const HomeCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class HomeSearchQueryChanged extends HomeEvent {
  final String query;

  const HomeSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class HomeNavTabChanged extends HomeEvent {
  final int tabIndex;

  const HomeNavTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class HomeJoinQueueRequested extends HomeEvent {
  final ClinicEntity clinic;
  final String patientName;
  final String serviceName;
  final String departmentName;

  const HomeJoinQueueRequested({
    required this.clinic,
    required this.patientName,
    this.serviceName = 'General Consultation',
    this.departmentName = '',
  });

  @override
  List<Object?> get props => [clinic, patientName, serviceName, departmentName];
}

/// The active ticket finished on the clinic side ('completed' or 'cancelled').
class HomeActiveTicketEnded extends HomeEvent {
  final String ticketId;
  final String status;

  const HomeActiveTicketEnded({required this.ticketId, required this.status});

  @override
  List<Object?> get props => [ticketId, status];
}

class HomeCancelTicketRequested extends HomeEvent {
  final String? ticketId;

  const HomeCancelTicketRequested([this.ticketId]);

  @override
  List<Object?> get props => [ticketId];
}

class HomeUnreadNotificationsUpdated extends HomeEvent {
  final int count;

  const HomeUnreadNotificationsUpdated(this.count);

  @override
  List<Object?> get props => [count];
}

class HomeAuthCleared extends HomeEvent {
  const HomeAuthCleared();
}
