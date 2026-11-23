import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/patient_review_entity.dart';

class WriteReviewDialog extends StatefulWidget {
  final PatientReviewEntity? initialReview;
  final String? initialClinicName;
  final String? initialDoctorName;
  final Future<void> Function({
    required String clinicId,
    required String clinicName,
    required String doctorName,
    required String service,
    required int rating,
    required List<String> tags,
    required String comment,
    required bool isAnonymous,
  })
  onSubmit;

  const WriteReviewDialog({
    super.key,
    this.initialReview,
    this.initialClinicName,
    this.initialDoctorName,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    PatientReviewEntity? initialReview,
    String? initialClinicName,
    String? initialDoctorName,
    required Future<void> Function({
      required String clinicId,
      required String clinicName,
      required String doctorName,
      required String service,
      required int rating,
      required List<String> tags,
      required String comment,
      required bool isAnonymous,
    })
    onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WriteReviewDialog(
        initialReview: initialReview,
        initialClinicName: initialClinicName,
        initialDoctorName: initialDoctorName,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog> {
  late final TextEditingController _clinicController;
  late final TextEditingController _doctorController;
  late final TextEditingController _commentController;

  int _rating = 5;
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  final List<String> _availableTags = [
    'Gentle Hand',
    'Painless Treatment',
    'Attentive Listener',
    'Clear Explanation',
    'Zero Wait',
    'Modern Equipment',
    'Polite Staff',
  ];
  late final Set<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    final r = widget.initialReview;
    _clinicController = TextEditingController(
      text: r?.clinicName ?? widget.initialClinicName ?? 'Smile Dental Clinic',
    );
    _doctorController = TextEditingController(
      text: r?.doctorName ?? widget.initialDoctorName ?? 'Dr. Rahul Sharma',
    );
    _commentController = TextEditingController(text: r?.comment ?? '');
    _rating = r?.rating ?? 5;
    _isAnonymous = r?.isAnonymous ?? false;
    _selectedTags = Set<String>.from(r?.tags ?? ['Gentle Hand', 'Zero Wait']);
  }

  @override
  void dispose() {
    _clinicController.dispose();
    _doctorController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _sentimentLabel(int val) {
    switch (val) {
      case 1:
        return '1.0 · Needs Improvement ⚠️';
      case 2:
        return '2.0 · Fair Care';
      case 3:
        return '3.0 · Average Consultation';
      case 4:
        return '4.0 · Attentive Care 👍';
      case 5:
      default:
        return '5.0 · Outstanding Care! ⭐';
    }
  }

  Future<void> _handleSubmit() async {
    final clinicName = _clinicController.text.trim();
    if (clinicName.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        clinicId: widget.initialReview?.clinicId ?? 'clinic-1',
        clinicName: clinicName,
        doctorName: _doctorController.text.trim(),
        service: widget.initialReview?.service ?? 'Consultation',
        rating: _rating,
        tags: _selectedTags.toList(),
        comment: _commentController.text.trim(),
        isAnonymous: _isAnonymous,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEditing = widget.initialReview != null;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Review' : 'Rate Doctor & Clinic',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  color: colors.textMuted,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Clinic Name Field
            Text(
              'Clinic Name',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _clinicController,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceSecondary,
                hintText: 'Enter clinic name',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Doctor Name Field
            Text(
              'Doctor Name',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _doctorController,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceSecondary,
                hintText: 'e.g. Dr. Rahul Sharma',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Rating Stars Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Overall Rating',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  _sentimentLabel(_rating),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starVal = index + 1;
                return InkWell(
                  onTap: () => setState(() => _rating = starVal),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Icon(
                      starVal <= _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 34,
                      color: starVal <= _rating
                          ? const Color(0xFFF59E0B)
                          : colors.border,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),

            // Highlight Tags
            Text(
              'What went well?',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: colors.primary.withValues(alpha: 0.15),
                  checkmarkColor: colors.primary,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? colors.primary : colors.textPrimary,
                  ),
                  backgroundColor: colors.surfaceSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? colors.primary : colors.border,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Comments
            Text(
              'Detailed Feedback',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceSecondary,
                hintText: 'Share more about doctor consultation, wait time, or clinic environment...',
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Anonymous checkbox
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (val) =>
                      setState(() => _isAnonymous = val ?? false),
                  activeColor: colors.primary,
                ),
                Text(
                  'Post anonymously (hides your name)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isEditing ? 'Update Review' : 'Submit Review',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
