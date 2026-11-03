import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/doctor_plan_entity.dart';
import 'doctor_ui_kit.dart';

class DoctorCapacityQuotaCard extends StatelessWidget {
  final int currentCount;
  final DoctorPlanEntity plan;
  final VoidCallback onUpgrade;

  const DoctorCapacityQuotaCard({
    super.key,
    required this.currentCount,
    required this.plan,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlimited = plan.isUnlimited;
    final docLimit = plan.doctorsLimit;
    final isAtLimit = !isUnlimited && currentCount >= docLimit;

    final summary = isUnlimited
        ? '$currentCount Doctors Active (Unlimited Doctors Plan)'
        : '$currentCount of $docLimit Doctors Active (${plan.planName})';

    final String subText;
    if (docLimit == 1) {
      subText = 'Solo practice plan covers 1 practicing physician with full live queue triage. Upgrade to add more doctors.';
    } else if (isUnlimited) {
      subText = 'Enterprise tier with unlimited doctor consultation rooms and queue management.';
    } else {
      subText = 'Multi-doctor plan covers up to $docLimit practicing physicians with room-wise queue triage.';
    }

    final pillText = isUnlimited
        ? '$currentCount / ∞ ACTIVE'
        : '$currentCount / $docLimit ACTIVE';

    final pillColor = isAtLimit ? DoctorColors.amber : DoctorColors.green;

    final infoWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: const Icon(
            Icons.medical_services_outlined,
            size: 20,
            color: Color(0xFF38BDF8),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DOCTOR PLAN CAPACITY',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: DoctorColors.muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                summary,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final actionsWidget = Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: pillColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: pillColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            pillText,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: pillColor,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: onUpgrade,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF334155)),
            backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upgrade Doctor Limit',
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 13),
            ],
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DoctorColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Color(0xFF2563EB), width: 4),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 680) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoWidget,
                    const SizedBox(height: 14),
                    actionsWidget,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: infoWidget),
                  const SizedBox(width: 16),
                  actionsWidget,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
