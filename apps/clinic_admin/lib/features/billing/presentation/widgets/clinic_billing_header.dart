import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.apartment_rounded, size: 13, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 6),
                  Text(
                    '${clinicName.toUpperCase()} • ACCOUNT & SUBSCRIPTION',
                    style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B).withAlpha(150),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF059669)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(
                    '${planName.toUpperCase()} ACTIVE • AUTO-RENEWS $renewalDate',
                    style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF34D399), letterSpacing: 0.4),
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
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your practice plan tier, quota limits, payment methods, GST details and official tax invoices',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
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
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF1E293B)),
                    backgroundColor: const Color(0xFF0F172A),
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
                    backgroundColor: const Color(0xFF2563EB),
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
