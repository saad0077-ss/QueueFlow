import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'clinic_list_avatar.dart';
import 'clinic_option_model.dart';

class ClinicSearchTile extends StatelessWidget {
  final ClinicOption clinic;
  final bool isSelected;
  final AppColorsExtension colors;
  final VoidCallback onTap;

  const ClinicSearchTile({
    super.key,
    required this.clinic,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB).withValues(alpha: 0.08)
              : colors.surfaceSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            ClinicListAvatar(
              clinicId: clinic.id,
              name: clinic.name,
              imageUrl: clinic.imageUrl,
              isSelected: isSelected,
              colors: colors,
              size: 38,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic.name,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: colors.border),
                          ),
                          child: Text(
                            clinic.category,
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: colors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (clinic.city.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '📍 ${clinic.city}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFF2563EB) : colors.border,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
