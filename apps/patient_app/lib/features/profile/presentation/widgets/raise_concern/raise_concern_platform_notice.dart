import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class RaiseConcernPlatformNotice extends StatelessWidget {
  final AppColorsExtension colors;

  const RaiseConcernPlatformNotice({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2563EB),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌐', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                'Platform-Wide / Technical Inquiry',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'This inquiry is not tied to any clinic facility. It will be routed directly to QueueFlow Platform Operations & Engineering Team.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: colors.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
