import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/home/domain/entities/clinic_entity.dart';
import '../theme/app_colors.dart';
import 'clinic_departments_dialog.dart';

class ClinicDeptChip extends StatelessWidget {
  final ClinicEntity clinic;

  const ClinicDeptChip({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    if (!clinic.hasMultipleDepartments) {
      return const SizedBox.shrink();
    }

    final count = clinic.departmentCount;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showClinicDepartmentsDialog(context, clinic: clinic);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$count Depts',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryLight,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.chevron_right_rounded,
              size: 11,
              color: AppColors.primaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
