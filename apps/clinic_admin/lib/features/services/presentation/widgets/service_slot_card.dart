import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_ui_kit.dart';

class ServiceSlotCard extends StatelessWidget {
  final bool isLimitReached;
  final bool isUnlimited;
  final int availableSlots;
  final String planName;
  final VoidCallback onAdd;
  final VoidCallback onUpgrade;

  const ServiceSlotCard({
    super.key,
    required this.isLimitReached,
    required this.isUnlimited,
    required this.availableSlots,
    required this.planName,
    required this.onAdd,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final message = isLimitReached
        ? 'Your $planName has no open service slots. Upgrade to add more services.'
        : (isUnlimited
              ? 'Your plan supports unlimited clinical services.'
              : 'You have $availableSlots open service slot${availableSlots == 1 ? '' : 's'} remaining on your plan.');

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
              child: Icon(
                isLimitReached ? Icons.lock_outline_rounded : Icons.add_rounded,
                color: isLimitReached
                    ? ServiceColors.amber
                    : ServiceColors.blue,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isLimitReached
                  ? 'Service Limit Reached'
                  : 'Available Service Slot',
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
                message,
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
              label: isLimitReached
                  ? 'Upgrade Plan for More Services →'
                  : '+ Add Treatment Service',
              onPressed: isLimitReached ? onUpgrade : onAdd,
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
