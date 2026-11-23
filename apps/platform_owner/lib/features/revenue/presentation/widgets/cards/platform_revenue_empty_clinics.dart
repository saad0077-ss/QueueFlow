import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../dashboard/presentation/pages/platform_clinics_page.dart';

class PlatformRevenueEmptyClinics extends StatelessWidget {
  const PlatformRevenueEmptyClinics({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.domain_disabled_rounded,
              size: 36,
              color: colors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'No active clinic subscriptions found',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add partner practices from the Clinics directory to track real subscription revenue.',
              style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => const PlatformClinicsPage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
              icon: const Icon(Icons.add_business_rounded, size: 14),
              label: Text(
                'Open Clinics Directory',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
