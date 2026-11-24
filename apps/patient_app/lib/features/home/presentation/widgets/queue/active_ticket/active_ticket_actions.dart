import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ActiveTicketActions extends StatelessWidget {
  final VoidCallback onGetDirections;
  final VoidCallback onCancelSpot;
  final VoidCallback? onRaiseConcern;

  const ActiveTicketActions({
    super.key,
    required this.onGetDirections,
    required this.onCancelSpot,
    this.onRaiseConcern,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onGetDirections,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Get Directions',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onCancelSpot,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.error, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                backgroundColor: colors.error.withValues(alpha: 0.04),
              ),
              child: Text(
                'Leave / Cancel Spot',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.error,
                ),
              ),
            ),
            if (onRaiseConcern != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRaiseConcern,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  backgroundColor: colors.primary.withValues(alpha: 0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Delay or Concern? Raise Inquiry',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
