import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import 'doctor_ui_kit.dart';

class DoctorDetailHeaderCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;
  final VoidCallback onEditProfile;
  final VoidCallback onManageSchedule;
  final VoidCallback onToggleAccount;
  final VoidCallback onRemoveDoctor;

  const DoctorDetailHeaderCard({
    super.key,
    required this.doctor,
    required this.onEditProfile,
    required this.onManageSchedule,
    required this.onToggleAccount,
    required this.onRemoveDoctor,
  });

  @override
  Widget build(BuildContext context) {
    Color accountColor;
    String accountLabel;
    if (doctor.isActiveAccount) {
      accountColor = DoctorColors.green;
      accountLabel = 'ACTIVE';
    } else if (doctor.isPendingAccount) {
      accountColor = DoctorColors.amber;
      accountLabel = 'PENDING VERIFICATION';
    } else {
      accountColor = DoctorColors.red;
      accountLabel = 'INACTIVE';
    }

    final metaParts = [
      if (doctor.qualifications.isNotEmpty) doctor.qualifications,
      if (doctor.experienceYears > 0) '${doctor.experienceYears} yrs experience',
      if (doctor.room.isNotEmpty) doctor.room,
    ];

    final identityWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DoctorAvatar(
          photoUrl: doctor.photoUrl,
          initials: doctor.initials,
          size: 76,
          radius: 18,
          fontSize: 24,
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    doctor.name,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accountColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accountColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '● $accountLabel',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: accountColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                doctor.title.isNotEmpty
                    ? '${doctor.specialty} · ${doctor.title}'
                    : doctor.specialty,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: DoctorColors.cyan,
                ),
              ),
              if (metaParts.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  metaParts.join('  •  '),
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: DoctorColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final actionsWidget = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton(
          onPressed: onEditProfile,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF334155)),
            backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            'Edit Profile',
            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
        OutlinedButton(
          onPressed: onManageSchedule,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF334155)),
            backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            'Manage Schedule',
            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
        OutlinedButton(
          onPressed: onToggleAccount,
          style: OutlinedButton.styleFrom(
            foregroundColor: doctor.isActiveAccount ? const Color(0xFFEF4444) : DoctorColors.green,
            side: BorderSide(
              color: (doctor.isActiveAccount ? const Color(0xFFEF4444) : DoctorColors.green).withValues(alpha: 0.4),
            ),
            backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            doctor.isActiveAccount ? 'Deactivate' : 'Activate',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: doctor.isActiveAccount ? const Color(0xFFEF4444) : DoctorColors.green,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: onRemoveDoctor,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFEF4444),
            side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
            backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFEF4444)),
              const SizedBox(width: 5),
              Text(
                'Remove Doctor',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DoctorColors.border),
      ),
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 740) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identityWidget,
                const SizedBox(height: 18),
                actionsWidget,
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: identityWidget),
              const SizedBox(width: 16),
              actionsWidget,
            ],
          );
        },
      ),
    );
  }

}
