import 'package:equatable/equatable.dart';
import '../../domain/entities/tenant_clinic_entity.dart';

class ClinicsDirectoryState extends Equatable {
  final List<TenantClinicEntity> allClinics;
  final List<TenantClinicEntity> filteredClinics;
  final String searchQuery;
  final String selectedPlanFilter;
  final String selectedStatusFilter;
  final bool isLoading;

  const ClinicsDirectoryState({
    this.allClinics = const [],
    this.filteredClinics = const [],
    this.searchQuery = '',
    this.selectedPlanFilter = 'All Plans',
    this.selectedStatusFilter = 'All Statuses',
    this.isLoading = false,
  });

  int get totalClinics => allClinics.length;
  int get activePractices =>
      allClinics.where((c) => c.status == 'ACTIVE').length;
  int get totalAppointmentsMonth =>
      allClinics.fold(0, (sum, c) => sum + c.monthlyVisits);
  int get totalMrr {
    return allClinics.where((c) => c.status == 'ACTIVE').fold(0, (sum, c) {
      if (c.planId == 'enterprise') return sum + 6999;
      if (c.planId == 'multi') return sum + 2999;
      return sum + 999;
    });
  }

  ClinicsDirectoryState copyWith({
    List<TenantClinicEntity>? allClinics,
    List<TenantClinicEntity>? filteredClinics,
    String? searchQuery,
    String? selectedPlanFilter,
    String? selectedStatusFilter,
    bool? isLoading,
  }) {
    return ClinicsDirectoryState(
      allClinics: allClinics ?? this.allClinics,
      filteredClinics: filteredClinics ?? this.filteredClinics,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPlanFilter: selectedPlanFilter ?? this.selectedPlanFilter,
      selectedStatusFilter:
          selectedStatusFilter ?? this.selectedStatusFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        allClinics,
        filteredClinics,
        searchQuery,
        selectedPlanFilter,
        selectedStatusFilter,
        isLoading,
      ];
}
