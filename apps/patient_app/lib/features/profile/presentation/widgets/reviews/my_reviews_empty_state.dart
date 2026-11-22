import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class MyReviewsEmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onWriteReview;

  const MyReviewsEmptyState({
    super.key,
    required this.hasFilter,
    required this.onWriteReview,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 42)),
          const SizedBox(height: 12),
          Text(
            hasFilter ? 'No Reviews in this Filter' : 'No Reviews Yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? "No reviews match this specific filter. Switch to 'All' to see all your reviews."
                : "You haven't submitted any clinic or doctor reviews yet. Share your experience after visits!",
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: colors.textMuted,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onWriteReview,
            icon: const Text('⭐', style: TextStyle(fontSize: 13)),
            label: Text(
              'Rate Doctor & Clinic',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
