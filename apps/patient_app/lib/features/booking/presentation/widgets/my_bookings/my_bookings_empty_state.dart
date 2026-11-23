import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class MyBookingsEmptyState extends StatelessWidget {
  final int selectedFilterIndex;
  final VoidCallback? onExploreClinics;

  const MyBookingsEmptyState({
    super.key,
    required this.selectedFilterIndex,
    this.onExploreClinics,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = selectedFilterIndex == 0
        ? 'No Upcoming Visits'
        : selectedFilterIndex == 1
        ? 'No Past Visits'
        : 'No Cancelled Visits';
    final desc = selectedFilterIndex == 0
        ? 'Book an appointment with your favorite clinics to see upcoming visits here.'
        : 'Your history of completed and cancelled clinic appointments will appear here.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_note_rounded,
                size: 30,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: colors.textMuted,
                height: 1.4,
              ),
            ),
            if (selectedFilterIndex == 0 && onExploreClinics != null) ...[
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: TextButton.icon(
                  onPressed: onExploreClinics,
                  icon: const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Explore Clinics',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
