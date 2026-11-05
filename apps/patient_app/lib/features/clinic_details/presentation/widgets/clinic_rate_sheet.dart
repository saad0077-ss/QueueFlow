import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicRateSheet extends StatefulWidget {
  final String clinicName;
  final Function(int rating, String comment, List<String> tags) onSubmit;

  const ClinicRateSheet({
    super.key,
    required this.clinicName,
    required this.onSubmit,
  });

  @override
  State<ClinicRateSheet> createState() => _ClinicRateSheetState();
}

class _ClinicRateSheetState extends State<ClinicRateSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();
  final List<String> _selectedTags = [];

  static const _availableTags = [
    'Clean Facility',
    'Friendly Doctor',
    'Zero Wait Time',
    'Painless',
    'Good Parking',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate ${widget.clinicName}',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  icon: Icon(
                    star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: colors.ratingGold,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = star),
                );
              }),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag, style: const TextStyle(fontSize: 11)),
                  selected: isSelected,
                  selectedColor: colors.primaryTint,
                  backgroundColor: colors.surfaceSecondary,
                  side: BorderSide(color: isSelected ? colors.primary : colors.border),
                  labelStyle: TextStyle(
                    color: isSelected ? colors.primary : colors.textMuted,
                  ),
                  onSelected: (_) => _toggleTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Share details of your experience...',
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  widget.onSubmit(
                    _rating,
                    _commentController.text.trim(),
                    _selectedTags,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
