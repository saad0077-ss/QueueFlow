import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicDetailsActionButtons extends StatelessWidget {
  final VoidCallback onToggleSuspension;
  final VoidCallback onChangeSubscription;
  final VoidCallback onDone;
  final bool isInvited;
  final bool isActive;

  const ClinicDetailsActionButtons({
    super.key,
    required this.onToggleSuspension,
    required this.onChangeSubscription,
    required this.onDone,
    this.isInvited = false,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row( 
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: isInvited ? null : onToggleSuspension,
              style: OutlinedButton.styleFrom(
                backgroundColor: isInvited ? colors.surface : colors.surfaceSecondary,
                foregroundColor: isInvited ? colors.textMuted : colors.textPrimary,
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                isInvited
                    ? 'Invite\nPending'
                    : (isActive ? 'Pause\nClinic' : 'Activate\nClinic'),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: onChangeSubscription,
              style: OutlinedButton.styleFrom(
                backgroundColor: colors.surfaceSecondary,
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: EdgeInsets.zero,
              ),
              child: Text('Change\nSubscription', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.15)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF06B6D4)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: const Color(0xFF06B6D4).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text('Done', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }
}
