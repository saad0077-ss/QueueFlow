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

  const HomeJoinQueueRequested({
    required this.clinic,
    required this.patientName,
  });

  @override
  List<Object?> get props => [clinic, patientName];
}

class HomeCancelTicketRequested extends HomeEvent {
  final String? ticketId;

  const HomeCancelTicketRequested([this.ticketId]);

  @override
  List<Object?> get props => [ticketId];
}
