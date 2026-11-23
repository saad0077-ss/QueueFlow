import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PatientSearchEmptyState extends StatelessWidget {
  final VoidCallback onReset;
  final AppColorsExtension colors;

  const PatientSearchEmptyState({
    super.key,
    required this.onReset,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              alignment: Alignment.center,
              child: const Text('🔍', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 14),
            Text(
              'No clinics found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'We couldn\'t find matches for your search or filters. Try adjusting keywords.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: colors.textMuted),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onReset,
              style: TextButton.styleFrom(
                backgroundColor: colors.surfaceSecondary,
                side: BorderSide(color: colors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Reset filters & search',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
