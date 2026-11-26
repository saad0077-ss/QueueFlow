import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class FavoriteClinicActionsRow extends StatelessWidget {
  final bool hasPhone;
  final VoidCallback onBook;
  final VoidCallback onLiveQueue;
  final VoidCallback onCall;

  const FavoriteClinicActionsRow({
    super.key,
    required this.hasPhone,
    required this.onBook,
    required this.onLiveQueue,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onBook,
            icon: const Text('📅', style: TextStyle(fontSize: 13)),
            label: Text(
              'Book',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onLiveQueue,
            icon: const Text('🎟️', style: TextStyle(fontSize: 13)),
            label: Text(
              'Live Queue',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: colors.primaryTint,
              foregroundColor: colors.primary,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        if (hasPhone) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: onCall,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              alignment: Alignment.center,
              child: const Text('📞', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ],
    );
  }
}
