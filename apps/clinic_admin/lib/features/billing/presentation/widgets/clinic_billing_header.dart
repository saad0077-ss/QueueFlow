import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicBillingHeader extends StatelessWidget {
  final String clinicName;
  final String planName;
  final String renewalDate;
  final VoidCallback onDownloadReceipt;
  final VoidCallback onChangePlan;

  const ClinicBillingHeader({
    super.key,
    required this.clinicName,
    required this.planName,
    required this.renewalDate,
    required this.onDownloadReceipt,
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
                    '${planName.toUpperCase()} ACTIVE • AUTO-RENEWS $renewalDate',
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
                    'Manage your practice plan tier, quota limits, payment methods, GST details and official tax invoices',
                    style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Wrap(
              spacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onDownloadReceipt,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border),
                    backgroundColor: colors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 15),
                  label: Text('Latest Receipt', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton.icon(
                  onPressed: onChangePlan,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.upgrade_rounded, size: 16),
                  label: Text('Change / Upgrade Plan', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
