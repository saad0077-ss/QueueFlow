import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor_ui_kit.dart';

class DoctorDetailBackBar extends StatelessWidget {
  final String doctorName;
  final VoidCallback onBack;

  const DoctorDetailBackBar({
    super.key,
    required this.doctorName,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
          OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF334155)),
              backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_rounded, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Back to Doctors',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Doctors',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: DoctorColors.muted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: DoctorColors.subtle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                doctorName,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      );
  }
}
