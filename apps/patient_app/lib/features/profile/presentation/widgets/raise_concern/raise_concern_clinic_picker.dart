import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'clinic_list_avatar.dart';
import 'clinic_option_model.dart';

class RaiseConcernClinicPicker extends StatelessWidget {
  final List<ClinicOption> availableClinics;
  final String selectedClinicId;
  final String selectedClinicName;
  final bool isLoadingClinics;
  final VoidCallback onOpenSearch;
  final AppColorsExtension colors;

  const RaiseConcernClinicPicker({
    super.key,
    required this.availableClinics,
    required this.selectedClinicId,
    required this.selectedClinicName,
    required this.isLoadingClinics,
    required this.onOpenSearch,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final selectedClinic = availableClinics.cast<ClinicOption?>().firstWhere(
      (c) => c?.id == selectedClinicId,
      orElse: () => null,
    );

    final displayName = selectedClinic?.name ?? selectedClinicName;
    final displayDetails = selectedClinic != null
        ? '${selectedClinic.category} • ${selectedClinic.city}'
        : 'Tap to search & select partner clinic';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Target Clinic *',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.textMuted,
              ),
            ),
            if (isLoadingClinics)
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Syncing clinics...',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              )
            else
              Text(
                '${availableClinics.length} available',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onOpenSearch,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                ClinicListAvatar(
                  clinicId: selectedClinicId,
                  name: displayName,
                  imageUrl: selectedClinic?.imageUrl,
                  isSelected: true,
                  colors: colors,
                  size: 40,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayDetails,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: colors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 13,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Change',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
