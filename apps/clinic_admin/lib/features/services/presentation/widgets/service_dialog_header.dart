import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_ui_kit.dart';

class ServiceDialogHeader extends StatelessWidget {
  final bool isEdit;
  final VoidCallback onClose;

  const ServiceDialogHeader({
    super.key,
    required this.isEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Treatment Service' : 'Add Treatment Service',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select from standardized medical departments or request a new catalog procedure',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: ServiceColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onClose,
          tooltip: 'Close',
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.close_rounded, color: Colors.white),
        ),
      ],
    );
  }
}
