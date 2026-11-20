import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class WalkInActionsFooter extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const WalkInActionsFooter({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            backgroundColor: colors.surfaceSecondary,
            side: BorderSide(color: colors.border),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Add to Queue',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
