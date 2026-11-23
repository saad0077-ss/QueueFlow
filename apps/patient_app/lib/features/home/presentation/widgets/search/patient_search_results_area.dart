import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/clinic_entity.dart';
import '../home_clinic_card.dart';
import 'patient_search_empty_state.dart';

class PatientSearchResultsArea extends StatelessWidget {
  final bool isSearching;
  final bool hasRecentSearches;
  final List<ClinicEntity> clinics;
  final bool useGrid;
  final bool isDesktop;
  final ValueChanged<ClinicEntity> onSelectClinic;
  final VoidCallback onResetFilters;
  final AppColorsExtension colors;

  const PatientSearchResultsArea({
    super.key,
    required this.isSearching,
    required this.hasRecentSearches,
    required this.clinics,
    required this.useGrid,
    required this.isDesktop,
    required this.onSelectClinic,
    required this.onResetFilters,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSearching) {
      if (hasRecentSearches) return const SizedBox.shrink();
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.border),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.search_rounded,
                  color: colors.textSubtle,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Search clinics & services',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Type a clinic name above or tap the filter button to choose a department and service.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: colors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${clinics.length} clinic${clinics.length == 1 ? '' : 's'} found',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        if (clinics.isEmpty)
          PatientSearchEmptyState(onReset: onResetFilters, colors: colors)
        else if (useGrid)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: clinics.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 110,
            ),
            itemBuilder: (ctx, i) => HomeClinicCard(
              clinic: clinics[i],
              onTap: () => onSelectClinic(clinics[i]),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: clinics.length,
            itemBuilder: (ctx, i) => HomeClinicCard(
              clinic: clinics[i],
              onTap: () => onSelectClinic(clinics[i]),
            ),
          ),
      ],
    );
  }
}
