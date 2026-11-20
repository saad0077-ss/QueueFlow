import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueRadarEmptyView extends StatelessWidget {
  const QueueRadarEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Text('🏥', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              'No active queues available right now',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Clinics near you will appear here when their digital triage queue opens.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
