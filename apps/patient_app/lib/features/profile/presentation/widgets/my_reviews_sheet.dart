import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);

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
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.darkBorder),
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
                    ? _buildEmpty()
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _reviews.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _buildReviewCard(_reviews[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Ratings & Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkInk,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Reviews you\'ve shared across clinics',
                style: TextStyle(fontSize: 12, color: AppColors.darkInkMuted),
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
              color: AppColors.darkBgApp,
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.darkInkMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rate_review_outlined,
              size: 40, color: AppColors.darkInkFaint),
          SizedBox(height: 10),
          Text(
            'No reviews yet',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkInk),
          ),
          SizedBox(height: 4),
          Text(
            'Share your feedback after your clinic visits!',
            style: TextStyle(fontSize: 12, color: AppColors.darkInkMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(PatientReviewEntity rev) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkBgApp,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rev.date,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.darkInkFaint),
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
                        color: _amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Verified Patient',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF22C55E),
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
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF60A5FA),
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
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.darkInk,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Footer: helpful count / delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('👍', style: TextStyle(fontSize: 11)),
                  SizedBox(width: 5),
                  Text(
                    '0 patients found this helpful',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.darkInkMuted),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _delete(rev.id),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _red,
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
