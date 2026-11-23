import 'package:flutter/material.dart';
import '../../domain/entities/clinic_appointment_entity.dart';
import '../bloc/clinic_appointments_bloc.dart';
import '../bloc/clinic_appointments_event.dart';
import '../bloc/clinic_appointments_state.dart';
import 'appointments_filter_bar.dart';

class ClinicAppointmentsFilterWrapper extends StatelessWidget {
  final ClinicAppointmentsState state;
  final ClinicAppointmentsBloc bloc;
  final List<ClinicAppointmentEntity> filtered;

  const ClinicAppointmentsFilterWrapper({
    super.key,
    required this.state,
    required this.bloc,
    required this.filtered,
  });

  @override
  Widget build(BuildContext context) {
    return AppointmentsFilterBar(
      searchQuery: state.searchQuery,
      onSearchChanged: (val) => bloc.add(ChangeSearchQuery(val)),
      selectedDateRange: state.dateRangeFilter,
      selectedDept: state.departmentFilter,
      selectedService: state.serviceFilter,
      selectedDoctor: state.doctorFilter,
      selectedStatus: state.statusFilter,
      selectedPayment: state.paymentFilter,
      availableDepts: state.availableDepartments,
      availableServices: state.availableServices,
      availableDoctors: state.availableDoctors,
      totalCount: state.allAppointments.length,
      filteredCount: filtered.length,
      hasActiveFilters: state.hasActiveFilters,
      onDateRangeChanged: (val) => bloc.add(ChangeDateRangeFilter(val)),
      onDeptChanged: (val) => bloc.add(ChangeDepartmentFilter(val)),
      onServiceChanged: (val) => bloc.add(ChangeServiceFilter(val)),
      onDoctorChanged: (val) => bloc.add(ChangeDoctorFilter(val)),
      onStatusChanged: (val) => bloc.add(ChangeStatusFilter(val)),
      onPaymentChanged: (val) => bloc.add(ChangePaymentFilter(val)),
      onClearFilters: () => bloc.add(const ResetAppointmentFilters()),
    );
  }
}
