import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/patient_review_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../widgets/reviews/my_review_card.dart';
import '../widgets/reviews/my_reviews_bloc.dart';
import '../widgets/reviews/my_reviews_dialog_helper.dart';
import '../widgets/reviews/my_reviews_empty_state.dart';
import '../widgets/reviews/my_reviews_filter_tabs.dart';
import '../widgets/reviews/my_reviews_header.dart';
import '../widgets/reviews/my_reviews_hero_banner.dart';

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
          create: (_) => MyReviewsBloc(
            repository: repo,
            initialReviews: initialReviews,
            onDeleteCallback: onDeleteCallback,
          ),
          child: const MyReviewsScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocBuilder<MyReviewsBloc, MyReviewsState>(
        builder: (context, state) {
          final bloc = context.read<MyReviewsBloc>();
          final reviews = state.filteredReviews;

          return Column(
            children: [
              MyReviewsHeader(
                onBack: () => Navigator.of(context).pop(),
                onWriteReview: () =>
                    MyReviewsDialogHelper.openWriteReview(context, bloc),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () async => bloc.load(),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                          children: [
                            MyReviewsHeroBanner(
                              doctorsCount: state.doctorReviews.length,
                              avgDoctorRating: state.avgDoctorRating,
                              clinicsCount: state.allReviews.length,
                              avgClinicRating: state.avgClinicRating,
                            ),
                            const SizedBox(height: 14),
                            MyReviewsFilterTabs(
                              activeFilter: state.activeFilter,
                              onFilterSelected: bloc.setFilter,
                              countAll: state.allReviews.length,
                              countDoctors: state.doctorReviews.length,
                              countClinics: state.allReviews.length,
                              count5Star: state.fiveStarReviews.length,
                            ),
                            const SizedBox(height: 14),
                            if (reviews.isEmpty)
                              MyReviewsEmptyState(
                                hasFilter: state.activeFilter != 'all',
                                onWriteReview: () =>
                                    MyReviewsDialogHelper.openWriteReview(
                                      context,
                                      bloc,
                                    ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reviews.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final review = reviews[index];
                                  return MyReviewCard(
                                    review: review,
                                    onEdit: () =>
                                        MyReviewsDialogHelper.openWriteReview(
                                          context,
                                          bloc,
                                          review: review,
                                        ),
                                    onDelete: () =>
                                        MyReviewsDialogHelper.confirmDelete(
                                          context,
                                          bloc,
                                          review,
                                        ),
                                  );
                                },
                              ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  MyReviewsDialogHelper.openWriteReview(
                                    context,
                                    bloc,
                                  ),
                              icon: const Text(
                                '⭐',
                                style: TextStyle(fontSize: 14),
                              ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
