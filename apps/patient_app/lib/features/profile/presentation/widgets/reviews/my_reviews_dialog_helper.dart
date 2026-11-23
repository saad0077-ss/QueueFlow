import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';

import '../../../domain/entities/patient_review_entity.dart';
import 'my_reviews_bloc.dart';
import 'write_review_dialog.dart';

class MyReviewsDialogHelper {
  static void openWriteReview(
    BuildContext context,
    MyReviewsBloc bloc, {
    PatientReviewEntity? review,
  }) {
    WriteReviewDialog.show(
      context,
      initialReview: review,
      onSubmit:
          ({
            required clinicId,
            required clinicName,
            required doctorName,
            required service,
            required rating,
            required tags,
            required comment,
            required isAnonymous,
          }) async {
            bloc.add(
              AddMyReviewEvent(
                clinicId: clinicId,
                clinicName: clinicName,
                doctorName: doctorName,
                service: service,
                rating: rating,
                tags: tags,
                comment: comment,
                isAnonymous: isAnonymous,
              ),
            );
          },
    );
  }

  static void confirmDelete(
    BuildContext context,
    MyReviewsBloc bloc,
    PatientReviewEntity review,
  ) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Review?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this verified clinic & doctor review? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              bloc.delete(review.id);
              AppSnackBar.showSuccess(
                context,
                title: 'Review Removed',
                message: 'Your review was deleted successfully.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
