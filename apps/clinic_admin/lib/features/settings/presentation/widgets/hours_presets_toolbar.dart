import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HoursPresetsToolbar extends StatelessWidget {
  final ValueChanged<String> onApplyPreset;
  final VoidCallback onCopyMonday;

  const HoursPresetsToolbar({
    super.key,
    required this.onApplyPreset,
    required this.onCopyMonday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              '⚡ QUICK PRESETS: ',
              style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
            ),
            const SizedBox(width: 8),
            _btn('Standard (Mon–Sat 9–8)', () => onApplyPreset('standard')),
            const SizedBox(width: 8),
            _btn('All 7 Days (9–9)', () => onApplyPreset('seven_days')),
            const SizedBox(width: 8),
            _btn('Weekdays (8–5)', () => onApplyPreset('weekdays')),
            const SizedBox(width: 8),
            _btn('Split Shift (Lunch Break)', () => onApplyPreset('split')),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onCopyMonday,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF60A5FA),
                side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                backgroundColor: const Color(0xFF1E3A8A).withAlpha(40),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('📋 Copy Mon to Weekdays', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF1E293B)),
        backgroundColor: const Color(0xFF0F172A),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w500)),
    );
  }
}
