import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

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
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              '⚡ QUICK PRESETS: ',
              style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: colors.textMuted, letterSpacing: 0.5),
            ),
            const SizedBox(width: 8),
            _btn(context, 'Standard (Mon–Sat 9–8)', () => onApplyPreset('standard')),
            const SizedBox(width: 8),
            _btn(context, 'All 7 Days (9–9)', () => onApplyPreset('seven_days')),
            const SizedBox(width: 8),
            _btn(context, 'Weekdays (8–5)', () => onApplyPreset('weekdays')),
            const SizedBox(width: 8),
            _btn(context, 'Split Shift (Lunch Break)', () => onApplyPreset('split')),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onCopyMonday,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primaryLight,
                side: BorderSide(color: colors.primary, width: 1.2),
                backgroundColor: colors.primaryTint,
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

  Widget _btn(BuildContext context, String label, VoidCallback onTap) {
    final colors = context.colors;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border),
        backgroundColor: colors.surfaceSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600)),
    );
  }
}
