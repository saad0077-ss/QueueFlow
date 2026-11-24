import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/patient_review_entity.dart';
import 'reviews/my_review_card.dart';
import 'reviews/my_reviews_bloc.dart';

/// "My Ratings & Reviews" dialog.
class MyReviewsSheet extends StatelessWidget {
  final List<PatientReviewEntity> reviews;
  final ValueChanged<String> onDeleteReview;

  const MyReviewsSheet({
    super.key,
    required this.reviews,
    required this.onDeleteReview,
  });

  static Future<void> show(
    BuildContext context, {
    required List<PatientReviewEntity> reviews,
    required ValueChanged<String> onDeleteReview,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) =>
          MyReviewsSheet(reviews: reviews, onDeleteReview: onDeleteReview),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (_) => MyReviewsBloc(
        repository: ProfileRepositoryImpl(),
        initialReviews: reviews,
        onDeleteCallback: onDeleteReview,
      ),
      child: BlocBuilder<MyReviewsBloc, MyReviewsState>(
        builder: (context, state) {
          final bloc = context.read<MyReviewsBloc>();

          return Dialog(
            backgroundColor: colors.surfaceElevated,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: colors.border),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 520,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Ratings & Reviews',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "Reviews you've shared across clinics",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.surfaceSecondary,
                              border: Border.all(color: colors.border),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: state.reviews.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.rate_review_outlined,
                                    size: 40,
                                    color: colors.textSubtle,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No reviews yet',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Share your feedback after your clinic visits!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: state.reviews.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) => MyReviewCard(
                                review: state.reviews[i],
                                onEdit: () {},
                                onDelete: () =>
                                    bloc.delete(state.reviews[i].id),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
