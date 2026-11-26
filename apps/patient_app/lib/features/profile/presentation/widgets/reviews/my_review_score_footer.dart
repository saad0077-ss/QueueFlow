import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/patient_review_entity.dart';

class MyReviewScoreFooter extends StatelessWidget {
  final PatientReviewEntity review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyReviewScoreFooter({
    super.key,
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _scoreCol(AppColorsExtension colors, String title, double val, String sub) {
    final stars = val.clamp(1.0, 5.0).round();
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: colors.textMuted)),
              Text('${val.toStringAsFixed(1)} ★', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w900, color: const Color(0xFFF59E0B))),
            ],
          ),
          const SizedBox(height: 1),
          Text('${'★' * stars}${'☆' * (5 - stars)} $sub', style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted)),
        ],
      ),
    );
  }

  Widget _actionChip({required Color bg, required Color border, required Color fg, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
        child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasDoctor = review.doctorName.isNotEmpty;
    final docRating = (review.doctorRating > 0 ? review.doctorRating : review.rating).toDouble();
    final clnRating = (review.clinicRating > 0 ? review.clinicRating : review.rating).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              if (hasDoctor) ...[
                _scoreCol(colors, '👨‍⚕️ Doctor Care', docRating, 'Bedside Manner'),
                Container(width: 1, height: 28, color: colors.border, margin: const EdgeInsets.symmetric(horizontal: 8)),
              ],
              _scoreCol(colors, '🏥 Clinic Facility', clnRating, 'Hygiene & Triage'),
            ],
          ),
        ),
        if (review.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final t in review.tags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text('✓ $t', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: colors.textMuted)),
                ),
            ],
          ),
        ],
        if (review.comment.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: Color(0xFFF59E0B), width: 3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              '"${review.comment}"',
              style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, height: 1.45, color: colors.textPrimary),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('👍', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text('${review.helpfulCount} patients found this helpful', style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted)),
              ],
            ),
            Row(
              children: [
                _actionChip(bg: colors.surfaceSecondary, border: colors.border, fg: colors.textPrimary, label: '✏️ Edit', onTap: onEdit),
                const SizedBox(width: 8),
                _actionChip(
                  bg: const Color(0xFFEF4444).withValues(alpha: 0.08),
                  border: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  fg: const Color(0xFFEF4444),
                  label: '🗑️ Delete',
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
