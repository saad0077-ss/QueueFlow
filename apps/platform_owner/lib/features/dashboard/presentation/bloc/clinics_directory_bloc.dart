import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import 'clinics_directory_event.dart';
import 'clinics_directory_state.dart';

class ClinicsDirectoryBloc
    extends Bloc<ClinicsDirectoryEvent, ClinicsDirectoryState> {
  ClinicsDirectoryBloc() : super(const ClinicsDirectoryState()) {
    on<ClinicsListUpdated>(_onListUpdated);
    on<ClinicsSearchQueryChanged>(_onSearchQueryChanged);
    on<ClinicsPlanFilterChanged>(_onPlanFilterChanged);
    on<ClinicsStatusFilterChanged>(_onStatusFilterChanged);
    on<ClinicsResetFilters>(_onResetFilters);
  }

  List<TenantClinicEntity> _applyFilters({
    required List<TenantClinicEntity> list,
    required String query,
    required String plan,
    required String status,
  }) {
    return list.where((c) {
      final q = query.trim().toLowerCase();
      final matchQuery = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.adminName.toLowerCase().contains(q) ||
          c.adminEmail.toLowerCase().contains(q) ||
          c.city.toLowerCase().contains(q);

      final matchPlan = plan == 'All Plans' ||
          c.planName.toLowerCase().contains(plan.toLowerCase()) ||
          c.planId.toLowerCase() == plan.toLowerCase();

      final matchStatus = status == 'All Statuses' ||
          c.status.toLowerCase() == status.toLowerCase();

      return matchQuery && matchPlan && matchStatus;
    }).toList();
  }

  void _onListUpdated(
    ClinicsListUpdated event,
    Emitter<ClinicsDirectoryState> emit,
  ) {
    final filtered = _applyFilters(
      list: event.clinics,
      query: state.searchQuery,
      plan: state.selectedPlanFilter,
      status: state.selectedStatusFilter,
    );
    emit(state.copyWith(allClinics: event.clinics, filteredClinics: filtered));
  }

  void _onSearchQueryChanged(
    ClinicsSearchQueryChanged event,
    Emitter<ClinicsDirectoryState> emit,
  ) {
    final filtered = _applyFilters(
      list: state.allClinics,
      query: event.query,
      plan: state.selectedPlanFilter,
      status: state.selectedStatusFilter,
    );
    emit(state.copyWith(searchQuery: event.query, filteredClinics: filtered));
  }

  void _onPlanFilterChanged(
    ClinicsPlanFilterChanged event,
    Emitter<ClinicsDirectoryState> emit,
  ) {
    final filtered = _applyFilters(
      list: state.allClinics,
      query: state.searchQuery,
      plan: event.plan,
      status: state.selectedStatusFilter,
    );
    emit(state.copyWith(
      selectedPlanFilter: event.plan,
      filteredClinics: filtered,
    ));
  }

  void _onStatusFilterChanged(
    ClinicsStatusFilterChanged event,
    Emitter<ClinicsDirectoryState> emit,
  ) {
    final filtered = _applyFilters(
      list: state.allClinics,
      query: state.searchQuery,
      plan: state.selectedPlanFilter,
      status: event.status,
    );
    emit(state.copyWith(
      selectedStatusFilter: event.status,
      filteredClinics: filtered,
    ));
  }

  void _onResetFilters(
    ClinicsResetFilters event,
    Emitter<ClinicsDirectoryState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: '',
      selectedPlanFilter: 'All Plans',
      selectedStatusFilter: 'All Statuses',
      filteredClinics: state.allClinics,
    ));
  }
}
