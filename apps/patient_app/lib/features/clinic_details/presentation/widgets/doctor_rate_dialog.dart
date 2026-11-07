import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Dialog for rating a doctor: pick 1–5 stars and optionally leave a comment.
class DoctorRateDialog extends StatefulWidget {
  final String doctorName;
  final void Function(int rating, String comment) onSubmit;

  const DoctorRateDialog({
    super.key,
    required this.doctorName,
    required this.onSubmit,
  });

  @override
  State<DoctorRateDialog> createState() => _DoctorRateDialogState();
}

class _DoctorRateDialogState extends State<DoctorRateDialog> {
  int _rating = 0;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  static const _labels = ['Tap a star to rate', 'Poor', 'Fair', 'Good', 'Very good', 'Excellent'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AlertDialog(
      backgroundColor: colors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Rate ${widget.doctorName}',
        style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: colors.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _rating = star),
                  icon: Icon(
                    star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: colors.ratingGold,
                    size: 36,
                  ),
                );
              }),
            ),
            Text(_labels[_rating], style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted)),
            const SizedBox(height: 14),
            TextField(
              controller: _comment,
              maxLines: 3,
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)',
                hintStyle: TextStyle(color: colors.textMuted, fontSize: 13),
                filled: true,
                fillColor: colors.surfaceSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _rating == 0
              ? null
              : () {
                  widget.onSubmit(_rating, _comment.text.trim());
                  Navigator.pop(context);
                },
          child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
