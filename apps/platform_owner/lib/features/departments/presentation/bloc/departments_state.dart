import 'package:equatable/equatable.dart';

import '../../domain/entities/department_entity.dart';
import '../../domain/entities/dept_expansion_request_entity.dart';
import '../../domain/entities/dept_service_request_entity.dart';

class DepartmentsState extends Equatable {
  final List<DepartmentEntity> allDepartments;
  final List<DepartmentEntity> filteredDepartments;
  final List<DeptExpansionRequestEntity> expansionRequests;
  final List<DeptServiceRequestEntity> serviceRequests;
  final String searchQuery;
  final String selectedStatusFilter;
  final String selectedClinicFilter;
  final bool isLoading;

  const DepartmentsState({
    this.allDepartments = const [],
    this.filteredDepartments = const [],
    this.expansionRequests = const [],
    this.serviceRequests = const [],
    this.searchQuery = '',
    this.selectedStatusFilter = 'All Statuses',
    this.selectedClinicFilter = 'All Clinics',
    this.isLoading = false,
  });

  int get totalDepartments => allDepartments.length;
  int get activeDepartments => allDepartments.where((d) => d.isActive).length;
  int get totalDoctors => allDepartments.fold(0, (sum, d) => sum + d.doctorCount);
  int get totalMonthlyVisits => allDepartments.fold(0, (sum, d) => sum + d.totalVisits);

  List<DeptExpansionRequestEntity> get pendingExpansionRequests => expansionRequests.where((r) => r.isPending).toList();

  List<DeptServiceRequestEntity> get pendingServiceRequests => serviceRequests.where((r) => r.isPending).toList();

  int get totalPendingRequests => pendingExpansionRequests.length + pendingServiceRequests.length;

  DepartmentsState copyWith({
    List<DepartmentEntity>? allDepartments,
    List<DepartmentEntity>? filteredDepartments,
    List<DeptExpansionRequestEntity>? expansionRequests,
    List<DeptServiceRequestEntity>? serviceRequests,
    String? searchQuery,
    String? selectedStatusFilter,
    String? selectedClinicFilter,
    bool? isLoading,
  }) {
    return DepartmentsState(
      allDepartments: allDepartments ?? this.allDepartments,
      filteredDepartments: filteredDepartments ?? this.filteredDepartments,
      expansionRequests: expansionRequests ?? this.expansionRequests,
      serviceRequests: serviceRequests ?? this.serviceRequests,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      selectedClinicFilter: selectedClinicFilter ?? this.selectedClinicFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    allDepartments,
    filteredDepartments,
    expansionRequests,
    serviceRequests,
    searchQuery,
    selectedStatusFilter,
    selectedClinicFilter,
    isLoading,
  ];
}
