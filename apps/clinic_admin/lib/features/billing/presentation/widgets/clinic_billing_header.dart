import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicBillingHeader extends StatelessWidget {
  final String clinicName;
  final String planName;
  final String renewalDate;
  final VoidCallback onChangePlan;

  const ClinicBillingHeader({
    super.key,
    required this.clinicName,
    required this.planName,
    required this.renewalDate,
    required this.onChangePlan,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.apartment_rounded, size: 13, color: colors.primaryLight),
                  const SizedBox(width: 6),
                  Text(
                    '${clinicName.toUpperCase()} • ACCOUNT & SUBSCRIPTION',
                    style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: colors.textMuted, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.badgeOpenBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.success),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: colors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(
                    renewalDate.isEmpty ? '${planName.toUpperCase()} ACTIVE' : '${planName.toUpperCase()} ACTIVE • VALID TILL $renewalDate',
                    style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: colors.badgeOpenText, letterSpacing: 0.4),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clinic Subscription & Plan Billing',
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your practice plan tier, quota limits, payment methods and official tax invoices',
                    style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
