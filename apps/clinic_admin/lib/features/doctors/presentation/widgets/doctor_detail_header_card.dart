import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
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
    final colors = context.colors;
    Color accountColor;
    String accountLabel;
    if (doctor.isActiveAccount) {
      accountColor = colors.success;
      accountLabel = 'ACTIVE';
    } else if (doctor.isPendingAccount) {
      accountColor = colors.warning;
      accountLabel = 'PENDING VERIFICATION';
    } else {
      accountColor = colors.error;
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
                      color: colors.textPrimary,
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
                  color: colors.primaryLight,
                ),
              ),
              if (metaParts.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  metaParts.join('  •  '),
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: colors.textMuted,
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
            foregroundColor: colors.textPrimary,
            side: BorderSide(color: colors.border),
            backgroundColor: colors.surfaceSecondary,
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
            foregroundColor: colors.textPrimary,
            side: BorderSide(color: colors.border),
            backgroundColor: colors.surfaceSecondary,
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
            foregroundColor: doctor.isActiveAccount ? colors.error : colors.success,
            side: BorderSide(
              color: (doctor.isActiveAccount ? colors.error : colors.success).withValues(alpha: 0.4),
            ),
            backgroundColor: colors.surfaceSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            doctor.isActiveAccount ? 'Deactivate' : 'Activate',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: doctor.isActiveAccount ? colors.error : colors.success,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: onRemoveDoctor,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.error,
            side: BorderSide(color: colors.error.withValues(alpha: 0.4)),
            backgroundColor: colors.errorTint,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded, size: 14, color: colors.error),
              const SizedBox(width: 5),
              Text(
                'Remove Doctor',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: colors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
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
