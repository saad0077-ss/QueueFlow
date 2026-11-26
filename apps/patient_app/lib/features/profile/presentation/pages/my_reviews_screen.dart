import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/patient_review_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../widgets/reviews/my_reviews_bloc.dart';
import '../widgets/reviews/my_reviews_dialog_helper.dart';
import '../widgets/reviews/my_reviews_empty_state.dart';
import '../widgets/reviews/my_reviews_filter_tabs.dart';
import '../widgets/reviews/my_reviews_header.dart';
import '../widgets/reviews/my_reviews_hero_banner.dart';
import '../widgets/reviews/my_reviews_list.dart';

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

  Widget _writeButton(BuildContext context, MyReviewsBloc bloc) {
    final colors = context.colors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => MyReviewsDialogHelper.openWriteReview(context, bloc),
            icon: const Text('⭐', style: TextStyle(fontSize: 14)),
            label: Text(
              'Write a New Clinic Review',
              style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocBuilder<MyReviewsBloc, MyReviewsState>(
        builder: (context, state) {
          final bloc = context.read<MyReviewsBloc>();
          final reviews = state.filteredReviews;

          return Column(
            children: [
              MyReviewsHeader(
                onBack: () => Navigator.of(context).pop(),
                onWriteReview: () => MyReviewsDialogHelper.openWriteReview(context, bloc),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isLaptop = constraints.maxWidth >= 800;
                          return RefreshIndicator(
                            onRefresh: () async => bloc.load(),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: isLaptop ? 32 : 16, vertical: 14),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: isLaptop ? 1280 : 640),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      MyReviewsHeroBanner(
                                        doctorsCount: state.doctorReviews.length,
                                        avgDoctorRating: state.avgDoctorRating,
                                        clinicsCount: state.clinicReviews.length,
                                        avgClinicRating: state.avgClinicRating,
                                      ),
                                      const SizedBox(height: 14),
                                      MyReviewsFilterTabs(
                                        activeFilter: state.activeFilter,
                                        onFilterSelected: bloc.setFilter,
                                        countAll: state.allReviews.length,
                                        countDoctors: state.doctorReviews.length,
                                        countClinics: state.clinicReviews.length,
                                        count5Star: state.fiveStarReviews.length,
                                      ),
                                      const SizedBox(height: 14),
                                      if (reviews.isEmpty)
                                        MyReviewsEmptyState(
                                          hasFilter: state.activeFilter != 'all',
                                          onWriteReview: () => MyReviewsDialogHelper.openWriteReview(context, bloc),
                                        )
                                      else
                                        MyReviewsList(reviews: reviews, bloc: bloc),
                                      const SizedBox(height: 20),
                                      _writeButton(context, bloc),
                                      const SizedBox(height: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
