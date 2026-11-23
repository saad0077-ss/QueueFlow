import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ServiceQueueCardActions extends StatelessWidget {
  final bool hasWaiting;
  final VoidCallback onViewQueue;
  final VoidCallback onCallNext;

  const ServiceQueueCardActions({
    super.key,
    required this.hasWaiting,
    required this.onViewQueue,
    required this.onCallNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(999),
            ),
            child: ElevatedButton(
              onPressed: onViewQueue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const StadiumBorder(),
              ),
              child: Text(
                'View Queue →',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: ElevatedButton(
            onPressed: hasWaiting ? onCallNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.background,
              foregroundColor: colors.textPrimary,
              disabledBackgroundColor: colors.background,
              disabledForegroundColor: colors.textMuted,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: StadiumBorder(side: BorderSide(color: colors.border)),
            ),
            child: Text(
              'Call Next',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
