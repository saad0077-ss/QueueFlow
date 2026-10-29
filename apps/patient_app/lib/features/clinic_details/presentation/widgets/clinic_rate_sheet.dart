import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

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
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: AppColors.darkInk,
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
                    color: AppColors.warning,
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
                  selectedColor: AppColors.primary.withValues(alpha: 0.25),
                  backgroundColor: AppColors.darkBgApp,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryLight : AppColors.darkInkMuted,
                  ),
                  onSelected: (_) => _toggleTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.darkInk, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Share details of your experience...',
                hintStyle: const TextStyle(color: AppColors.darkInkFaint, fontSize: 13),
                filled: true,
                fillColor: AppColors.darkBgApp,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
