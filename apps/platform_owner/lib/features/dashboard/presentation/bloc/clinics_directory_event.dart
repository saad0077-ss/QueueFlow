import 'package:equatable/equatable.dart';
import '../../domain/entities/tenant_clinic_entity.dart';

abstract class ClinicsDirectoryEvent extends Equatable {
  const ClinicsDirectoryEvent();

  @override
  List<Object?> get props => [];
}

class ClinicsListUpdated extends ClinicsDirectoryEvent {
  final List<TenantClinicEntity> clinics;
  const ClinicsListUpdated(this.clinics);

  @override
  List<Object?> get props => [clinics];
}

class ClinicsSearchQueryChanged extends ClinicsDirectoryEvent {
  final String query;
  const ClinicsSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ClinicsPlanFilterChanged extends ClinicsDirectoryEvent {
  final String plan;
  const ClinicsPlanFilterChanged(this.plan);

  @override
  List<Object?> get props => [plan];
}

class ClinicsStatusFilterChanged extends ClinicsDirectoryEvent {
  final String status;
  const ClinicsStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class ClinicsResetFilters extends ClinicsDirectoryEvent {
  const ClinicsResetFilters();
}
