import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class HoursActionFooter extends StatelessWidget {
  final VoidCallback onRevert;
  final VoidCallback onSave;

  const HoursActionFooter({
    super.key,
    required this.onRevert,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: colors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All changes will sync live to the Patient Mobile App and queue management engine immediately upon saving.',
                    style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              OutlinedButton(
                onPressed: onRevert,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textMuted,
                  side: BorderSide(color: colors.border),
                  backgroundColor: colors.surfaceSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Revert Changes', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                  shadowColor: colors.primary.withAlpha(120),
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 16),
                label: Text('Save Operating Hours', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
