import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/entities/patient_review_entity.dart';
import 'my_review_card.dart';
import 'my_reviews_bloc.dart';
import 'my_reviews_dialog_helper.dart';

class MyReviewsList extends StatelessWidget {
  final List<PatientReviewEntity> reviews;
  final MyReviewsBloc bloc;

  const MyReviewsList({super.key, required this.reviews, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) => _card(ctx, reviews[idx]),
          );
        }

        final maxCols = constraints.maxWidth >= 1150 ? 3 : 2;
        final cols = reviews.length < maxCols
            ? math.max(1, reviews.length)
            : maxCols;
        final rows = <List<PatientReviewEntity>>[
          for (var i = 0; i < reviews.length; i += cols)
            reviews.sublist(i, (i + cols).clamp(0, reviews.length)),
        ];

        return Column(
          children: [
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var j = 0; j < cols; j++) ...[
                      if (j > 0) const SizedBox(width: 16),
                      Expanded(
                        child: j < row.length
                            ? _card(context, row[j])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _card(BuildContext context, PatientReviewEntity review) {
    return MyReviewCard(
      review: review,
      onEdit: () =>
          MyReviewsDialogHelper.openWriteReview(context, bloc, review: review),
      onDelete: () =>
          MyReviewsDialogHelper.confirmDelete(context, bloc, review),
    );
  }
}
