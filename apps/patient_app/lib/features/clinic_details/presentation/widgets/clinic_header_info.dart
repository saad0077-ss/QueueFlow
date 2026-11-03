import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/clinic_dept_chip.dart';
import '../../../home/domain/entities/clinic_entity.dart';
import 'clinic_status_pill.dart';

class ClinicHeaderInfo extends StatelessWidget {
  final ClinicEntity clinic;
  final String? holidayNotice;

  const ClinicHeaderInfo({
    super.key,
    required this.clinic,
    this.holidayNotice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                clinic.name,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkInk,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ClinicStatusPill(isOpen: clinic.isOpen),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              clinic.hasRatings ? clinic.rating.toStringAsFixed(1) : 'New',
              style: GoogleFonts.robotoMono(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.darkInk,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                clinic.hasRatings
                    ? '(${clinic.reviewCount} review${clinic.reviewCount == 1 ? '' : 's'}) · ${clinic.primaryCategory}'
                    : 'No reviews yet · ${clinic.primaryCategory}',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppColors.darkInkMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ClinicDeptChip(clinic: clinic),
          ],
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.location_on_outlined,
          text: '${clinic.address} · ${clinic.distance} away',
          color: AppColors.darkInkMuted,
        ),
        const SizedBox(height: 5),
        _buildInfoRow(
          icon: Icons.phone_outlined,
          text: clinic.phone,
          color: AppColors.primaryLight,
          isBold: true,
        ),
        const SizedBox(height: 5),
        _buildInfoRow(
          icon: Icons.access_time_rounded,
          text: clinic.openingHours,
          color: AppColors.darkInkMuted,
        ),
        if (holidayNotice != null && holidayNotice!.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildHolidayNotice(holidayNotice!),
        ],
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHolidayNotice(String notice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Text(
        '📢 Notice: $notice',
        style: GoogleFonts.inter(
          fontSize: 11.5,
          color: AppColors.warning,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
