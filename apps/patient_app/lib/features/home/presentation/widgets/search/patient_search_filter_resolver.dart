import '../../../domain/entities/clinic_entity.dart';
import 'patient_search_department_constants.dart';

class PatientSearchFilterResolver {
  static const List<String> fallbackDepartments = [
    'General Medicine',
    'Dental & Oral Surgery',
    'Dermatology & Cosmetology',
    'Pediatrics & Child Care',
    'Orthopedics & Sports Rehab',
    'Cardiology',
    'Diagnostics',
    'Ear, Nose & Throat (ENT)',
  ];

  static List<String> resolveAvailableDepartments(
    List<ClinicEntity> allClinics,
  ) {
    final Set<String> depts = {'all'};
    for (final clinic in allClinics) {
      if (clinic.category.isNotEmpty) {
        final parts = clinic.category.split(RegExp(r'[,·•]'));
        for (final p in parts) {
          final clean = p.trim();
          if (clean.isNotEmpty) depts.add(clean);
        }
      }
    }
    for (final def in fallbackDepartments) {
      depts.add(def);
    }
    return depts.toList();
  }

  static List<String> getServicesForDepartment(String dept) {
    return PatientSearchDepartmentConstants.getServicesForDepartment(dept);
  }

  static List<ClinicEntity> filterClinics({
    required List<ClinicEntity> allClinics,
    required String selectedDepartment,
    required String selectedService,
    required Set<String> activeQuickFilters,
    required String query,
  }) {
    var result = List<ClinicEntity>.from(allClinics);

    // 1. Department Filter
    if (selectedDepartment.toLowerCase() != 'all') {
      final deptLower = selectedDepartment.toLowerCase();
      result = result
          .where((c) => c.category.toLowerCase().contains(deptLower))
          .toList();
    }

    // 2. Service Filter
    if (selectedService.toLowerCase() != 'all') {
      final sLower = selectedService.toLowerCase();
      result = result
          .where(
            (c) =>
                c.category.toLowerCase().contains(sLower) ||
                c.name.toLowerCase().contains(sLower),
          )
          .toList();
    }

    // 3. Quick Filters
    if (activeQuickFilters.contains('open')) {
      result = result.where((c) => c.isOpenNow).toList();
    }
    if (activeQuickFilters.contains('rating')) {
      result = result.where((c) => c.rating >= 4.5).toList();
    }
    if (activeQuickFilters.contains('near')) {
      result = result.where((c) {
        final km = c.distanceKm;
        return km != null && km <= 2.0;
      }).toList();
    }
    if (activeQuickFilters.contains('queue')) {
      result = result.where((c) => c.hasLiveQueue).toList();
    }

    // 4. Search Query Filter
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q) ||
            c.address.toLowerCase().contains(q) ||
            c.city.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }
}
