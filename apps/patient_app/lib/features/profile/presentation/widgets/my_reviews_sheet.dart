import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/patient_review_entity.dart';

/// "My Ratings & Reviews" dialog.
class MyReviewsSheet extends StatefulWidget {
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
      builder: (_) => MyReviewsSheet(
        reviews: reviews,
        onDeleteReview: onDeleteReview,
      ),
    );
  }

  @override
  State<MyReviewsSheet> createState() => _MyReviewsSheetState();
}

class _MyReviewsSheetState extends State<MyReviewsSheet> {
  late List<PatientReviewEntity> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = List.of(widget.reviews);
  }

  void _delete(String id) {
    widget.onDeleteReview(id);
    setState(() => _reviews.removeWhere((r) => r.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.surfaceElevated,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.border),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 14),
              Flexible(
                child: _reviews.isEmpty
                    ? _buildEmpty(context)
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _reviews.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _buildReviewCard(context, _reviews[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;

    return Row(
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
                'Reviews you\'ve shared across clinics',
                style: TextStyle(fontSize: 12, color: colors.textMuted),
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
            child: Icon(Icons.close_rounded,
                size: 18, color: colors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rate_review_outlined,
              size: 40, color: colors.textSubtle),
          const SizedBox(height: 10),
          Text(
            'No reviews yet',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Share your feedback after your clinic visits!',
            style: TextStyle(fontSize: 12, color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, PatientReviewEntity rev) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clinic name / date  |  stars / verified badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rev.clinicName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rev.date,
                      style: TextStyle(
                          fontSize: 11, color: colors.textSubtle),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < rev.rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14,
                        color: colors.ratingGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Verified Patient',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: colors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tags
          if (rev.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: rev.tags
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.primaryTint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          // Comment
          if (rev.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              rev.comment,
              style: TextStyle(
                fontSize: 12.5,
                color: colors.textPrimary,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Footer: helpful count / delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('👍', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 5),
                  Text(
                    '0 patients found this helpful',
                    style: TextStyle(
                        fontSize: 11, color: colors.textMuted),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _delete(rev.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: colors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
