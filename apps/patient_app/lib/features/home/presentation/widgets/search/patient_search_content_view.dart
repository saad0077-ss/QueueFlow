import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/clinic_entity.dart';
import 'patient_search_active_tags.dart';
import 'patient_search_filter_dialog.dart';
import 'patient_search_filter_resolver.dart';
import 'patient_search_recent_searches.dart';
import 'patient_search_results_area.dart';
import 'patient_search_top_bar.dart';

class PatientSearchContentView extends StatelessWidget {
  final TextEditingController searchCtrl;
  final bool autoFocus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchSubmitted;
  final List<ClinicEntity> allClinics;
  final void Function(String dept, String service, Set<String> quick)
  onApplyFilters;
  final bool hasActiveFilters;
  final int activeCount;
  final String selectedDepartment;
  final String selectedService;
  final Set<String> activeQuickFilters;
  final VoidCallback onClearDepartment;
  final VoidCallback onClearService;
  final ValueChanged<String> onRemoveQuickFilter;
  final List<String> recentSearches;
  final ValueChanged<String> onSelectRecent;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearAllRecent;
  final bool isSearching;
  final List<ClinicEntity> clinics;
  final ValueChanged<ClinicEntity> onSelectClinic;
  final VoidCallback onResetFilters;
  final AppColorsExtension colors;

  const PatientSearchContentView({
    super.key,
    required this.searchCtrl,
    required this.autoFocus,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.allClinics,
    required this.onApplyFilters,
    required this.hasActiveFilters,
    required this.activeCount,
    required this.selectedDepartment,
    required this.selectedService,
    required this.activeQuickFilters,
    required this.onClearDepartment,
    required this.onClearService,
    required this.onRemoveQuickFilter,
    required this.recentSearches,
    required this.onSelectRecent,
    required this.onRemoveRecent,
    required this.onClearAllRecent,
    required this.isSearching,
    required this.clinics,
    required this.onSelectClinic,
    required this.onResetFilters,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isDesktop = width >= 960;
        final bool isTablet = width >= 640 && width < 960;
        final double pad = isDesktop ? 32 : (isTablet ? 24 : 18);
        final double maxWidth = isDesktop
            ? 960
            : (isTablet ? 720 : double.infinity);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                PatientSearchTopBar(
                  searchCtrl: searchCtrl,
                  autoFocus: autoFocus,
                  onSearchChanged: onSearchChanged,
                  onSearchSubmitted: onSearchSubmitted,
                  onOpenFilter: () => PatientSearchFilterDialog.show(
                    context,
                    allDepartments:
                        PatientSearchFilterResolver.resolveAvailableDepartments(
                          allClinics,
                        ),
                    initialDepartment: selectedDepartment,
                    initialService: selectedService,
                    initialQuickFilters: activeQuickFilters,
                    onApply: onApplyFilters,
                  ),
                  hasActiveFilters: hasActiveFilters,
                  activeCount: activeCount,
                  horizontalPadding: pad,
                  colors: colors,
                ),
                if (hasActiveFilters)
                  PatientSearchActiveTags(
                    selectedDepartment: selectedDepartment,
                    selectedService: selectedService,
                    activeQuickFilters: activeQuickFilters,
                    onClearDepartment: onClearDepartment,
                    onClearService: onClearService,
                    onRemoveQuickFilter: onRemoveQuickFilter,
                    horizontalPadding: pad,
                    colors: colors,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PatientSearchRecentSearches(
                          recentSearches: recentSearches,
                          onSelect: onSelectRecent,
                          onRemove: onRemoveRecent,
                          onClearAll: onClearAllRecent,
                          colors: colors,
                        ),
                        PatientSearchResultsArea(
                          isSearching: isSearching,
                          hasRecentSearches: recentSearches.isNotEmpty,
                          clinics: clinics,
                          useGrid: width >= 720,
                          isDesktop: isDesktop,
                          onSelectClinic: onSelectClinic,
                          onResetFilters: onResetFilters,
                          colors: colors,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
