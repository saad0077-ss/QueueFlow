import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/department_entity.dart';
import 'departments_event.dart';
import 'departments_state.dart';

class DepartmentsBloc extends Bloc<DepartmentsEvent, DepartmentsState> {
  DepartmentsBloc() : super(const DepartmentsState()) {
    on<DepartmentsListUpdated>(_onListUpdated);
    on<ExpansionRequestsUpdated>(_onExpansionRequestsUpdated);
    on<ServiceRequestsUpdated>(_onServiceRequestsUpdated);
    on<DepartmentSearchQueryChanged>(_onSearchQueryChanged);
    on<DepartmentStatusFilterChanged>(_onStatusFilterChanged);
    on<DepartmentClinicFilterChanged>(_onClinicFilterChanged);
    on<DepartmentsResetFilters>(_onResetFilters);
  }

  void _onListUpdated(DepartmentsListUpdated event, Emitter<DepartmentsState> emit) {
    final filtered = _applyFilters(event.departments, state.searchQuery, state.selectedStatusFilter, state.selectedClinicFilter);
    emit(state.copyWith(allDepartments: event.departments, filteredDepartments: filtered));
  }

  void _onExpansionRequestsUpdated(ExpansionRequestsUpdated event, Emitter<DepartmentsState> emit) {
    emit(state.copyWith(expansionRequests: event.requests));
  }

  void _onServiceRequestsUpdated(ServiceRequestsUpdated event, Emitter<DepartmentsState> emit) {
    emit(state.copyWith(serviceRequests: event.requests));
  }

  void _onSearchQueryChanged(DepartmentSearchQueryChanged event, Emitter<DepartmentsState> emit) {
    final filtered = _applyFilters(state.allDepartments, event.query, state.selectedStatusFilter, state.selectedClinicFilter);
    emit(state.copyWith(searchQuery: event.query, filteredDepartments: filtered));
  }

  void _onStatusFilterChanged(DepartmentStatusFilterChanged event, Emitter<DepartmentsState> emit) {
    final filtered = _applyFilters(state.allDepartments, state.searchQuery, event.status, state.selectedClinicFilter);
    emit(state.copyWith(selectedStatusFilter: event.status, filteredDepartments: filtered));
  }

  void _onClinicFilterChanged(DepartmentClinicFilterChanged event, Emitter<DepartmentsState> emit) {
    final filtered = _applyFilters(state.allDepartments, state.searchQuery, state.selectedStatusFilter, event.clinic);
    emit(state.copyWith(selectedClinicFilter: event.clinic, filteredDepartments: filtered));
  }

  void _onResetFilters(DepartmentsResetFilters event, Emitter<DepartmentsState> emit) {
    final filtered = _applyFilters(state.allDepartments, '', 'All Statuses', 'All Clinics');
    emit(state.copyWith(searchQuery: '', selectedStatusFilter: 'All Statuses', selectedClinicFilter: 'All Clinics', filteredDepartments: filtered));
  }

  List<DepartmentEntity> _applyFilters(List<DepartmentEntity> list, String query, String status, String clinic) {
    var res = List<DepartmentEntity>.from(list);
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      res = res.where((d) {
        return d.name.toLowerCase().contains(q) || d.code.toLowerCase().contains(q) || d.description.toLowerCase().contains(q);
      }).toList();
    }
    if (status == 'Active Specialties') {
      res = res.where((d) => d.isActive).toList();
    } else if (status == 'Inactive') {
      res = res.where((d) => !d.isActive).toList();
    }
    if (clinic != 'All Clinics' && clinic != 'all') {
      res = res.where((d) => d.assignedClinics.contains(clinic)).toList();
    }
    return res;
  }
}
