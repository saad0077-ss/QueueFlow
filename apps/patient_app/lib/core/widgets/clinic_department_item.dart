import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ClinicDepartmentItemData {
  final String name;
  final String code;
  final String icon;
  final Color color;
  final String description;
  final String avgTime;
  final int doctorCount;

  const ClinicDepartmentItemData({
    required this.name,
    required this.code,
    required this.icon,
    required this.color,
    required this.description,
    required this.avgTime,
    required this.doctorCount,
  });

  factory ClinicDepartmentItemData.fromName(String name, {Map<String, dynamic>? firestoreData}) {
    final lName = name.toLowerCase();
    String code = firestoreData?['code']?.toString() ?? 'GEN';
    String icon = firestoreData?['icon']?.toString() ?? '🩺';
    Color color = AppColors.primary;
    String desc = firestoreData?['description']?.toString() ?? 'Routine checkups, diagnostic triage and clinical management.';
    String avg = firestoreData?['avgConsultationTime']?.toString() ?? '15 mins';
    int docs = (firestoreData?['doctorCount'] as num?)?.toInt() ?? 2;

    if (lName.contains('card')) {
      code = 'CARD'; icon = '❤️'; color = const Color(0xFFDC2626); avg = '25 mins';
      desc = 'Cardiovascular assessment, ECG review, and preventive heart care.';
    } else if (lName.contains('orth')) {
      code = 'ORTH'; icon = '🦴'; color = const Color(0xFF7C3AED); avg = '20 mins';
      desc = 'Joint evaluation, acute fracture stabilization, and injury rehab.';
    } else if (lName.contains('pedi')) {
      code = 'PEDI'; icon = '👶'; color = const Color(0xFFF43F5E); avg = '20 mins';
      desc = 'Pediatric wellness, routine vaccinations, and child development care.';
    } else if (lName.contains('dent')) {
      code = 'DENT'; icon = '🦷'; color = const Color(0xFF0F766E); avg = '30 mins';
      desc = 'Preventive, restorative, root canal, and cosmetic dental treatments.';
    } else if (lName.contains('derm')) {
      code = 'DERM'; icon = '✨'; color = const Color(0xFFD97706); avg = '20 mins';
      desc = 'Medical dermatology, laser skin therapies, and cosmetic procedures.';
    } else if (lName.contains('diag')) {
      code = 'DIAG'; icon = '🔬'; color = const Color(0xFF0891B2); avg = '15 mins';
      desc = 'Complete laboratory diagnostics, rapid blood tests, and scans.';
    }

    return ClinicDepartmentItemData(
      name: name,
      code: code,
      icon: icon,
      color: color,
      description: desc,
      avgTime: avg,
      doctorCount: docs,
    );
  }
}

class ClinicDepartmentCardWidget extends StatelessWidget {
  final ClinicDepartmentItemData data;

  const ClinicDepartmentCardWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Non-uniform border colors can't take a borderRadius, so the outer box
    // owns the rounded uniform border and clips an inner box carrying the accent stripe.
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.darkBgApp,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: data.color, width: 3.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(data.icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.name,
                        style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.darkInk),
                      ),
                    ),
                    if (data.code.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: data.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text(data.code, style: GoogleFonts.robotoMono(fontSize: 9.5, fontWeight: FontWeight.w800, color: data.color)),
                      ),
                    ],
                  ],
                ),
                if (data.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(data.description, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.darkInkMuted, height: 1.45)),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (data.avgTime.isNotEmpty) ...[
                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.darkInkFaint),
                      const SizedBox(width: 4),
                      Text('~${data.avgTime}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkInkFaint)),
                      const SizedBox(width: 12),
                    ],
                    const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.darkInkFaint),
                    const SizedBox(width: 4),
                    Text('${data.doctorCount} doctor${data.doctorCount > 1 ? "s" : ""}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkInkFaint)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
