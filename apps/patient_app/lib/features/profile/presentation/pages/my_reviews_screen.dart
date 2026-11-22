import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/patient_review_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../widgets/reviews/my_review_card.dart';
import '../widgets/reviews/my_reviews_cubit.dart';
import '../widgets/reviews/my_reviews_empty_state.dart';
import '../widgets/reviews/my_reviews_filter_tabs.dart';
import '../widgets/reviews/my_reviews_header.dart';
import '../widgets/reviews/my_reviews_hero_banner.dart';
import '../widgets/reviews/write_review_dialog.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  static Future<void> open(
    BuildContext context, {
    ProfileRepository? repository,
    List<PatientReviewEntity>? initialReviews,
    void Function(String id)? onDeleteCallback,
  }) {
    final repo = repository ?? ProfileRepositoryImpl();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => MyReviewsCubit(
            repository: repo,
            initialReviews: initialReviews,
            onDeleteCallback: onDeleteCallback,
          ),
          child: const MyReviewsScreen(),
        ),
      ),
    );
  }

  void _openWriteReview(BuildContext context, {PatientReviewEntity? review}) {
    final cubit = context.read<MyReviewsCubit>();
    WriteReviewDialog.show(
      context,
      initialReview: review,
      onSubmit: ({
        required clinicId,
        required clinicName,
        required doctorName,
        required service,
        required rating,
        required tags,
        required comment,
        required isAnonymous,
      }) async {
        await cubit.addReview(
          clinicId: clinicId,
          clinicName: clinicName,
          doctorName: doctorName,
          service: service,
          rating: rating,
          tags: tags,
          comment: comment,
          isAnonymous: isAnonymous,
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, PatientReviewEntity review) {
    final colors = context.colors;
    final cubit = context.read<MyReviewsCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Review?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: colors.textPrimary),
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
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              cubit.delete(review.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review removed successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocBuilder<MyReviewsCubit, MyReviewsState>(
        builder: (context, state) {
          final cubit = context.read<MyReviewsCubit>();
          final reviews = state.filteredReviews;

          return Column(
            children: [
              MyReviewsHeader(
                onBack: () => Navigator.of(context).pop(),
                onWriteReview: () => _openWriteReview(context),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => cubit.load(),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                          children: [
                            // Hero KPI banner
                            MyReviewsHeroBanner(
                              doctorsCount: state.doctorReviews.length,
                              avgDoctorRating: state.avgDoctorRating,
                              clinicsCount: state.allReviews.length,
                              avgClinicRating: state.avgClinicRating,
                            ),
                            const SizedBox(height: 14),

                            // Filter Tabs
                            MyReviewsFilterTabs(
                              activeFilter: state.activeFilter,
                              onFilterSelected: cubit.setFilter,
                              countAll: state.allReviews.length,
                              countDoctors: state.doctorReviews.length,
                              countClinics: state.allReviews.length,
                              count5Star: state.fiveStarReviews.length,
                            ),
                            const SizedBox(height: 14),

                            // Reviews List or Empty State
                            if (reviews.isEmpty)
                              MyReviewsEmptyState(
                                hasFilter: state.activeFilter != 'all',
                                onWriteReview: () => _openWriteReview(context),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reviews.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final review = reviews[index];
                                  return MyReviewCard(
                                    review: review,
                                    onEdit: () => _openWriteReview(context, review: review),
                                    onDelete: () => _confirmDelete(context, review),
                                  );
                                },
                              ),

                            // Bottom Action CTA
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _openWriteReview(context),
                              icon: const Text('⭐', style: TextStyle(fontSize: 14)),
                              label: Text(
                                'Write a New Clinic Review',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
