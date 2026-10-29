import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_ui_kit.dart';

class ServiceSlotCard extends StatelessWidget {
  final VoidCallback onAdd;

  const ServiceSlotCard({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {

    return DashedBorderBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1526),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: ServiceColors.blue,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add a New Service',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            // Padding (not a max-width box) keeps the intrinsic height used
            // by the grid rows in sync with the real wrapped text height.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Every plan includes unlimited clinical services. Add as many treatments as your clinic offers.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: const Color(0xFFCBD5E1),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 18),
            ServiceGradientButton(
              label: '+ Add Treatment Service',
              onPressed: onAdd,
              height: 36,
              fontSize: 13,
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
          ],
        ),
      ),
    );
  }
}
