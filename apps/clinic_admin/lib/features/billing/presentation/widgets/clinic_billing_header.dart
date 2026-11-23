import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicBillingHeader extends StatelessWidget {
  final String? clinicName;
  final String? planName;
  final String? renewalDate;
  final VoidCallback? onChangePlan;

  const ClinicBillingHeader({
    super.key,
    this.clinicName,
    this.planName,
    this.renewalDate,
    this.onChangePlan,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clinic Subscription & Plan Billing',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your practice plan tier, quota limits, payment methods and official tax invoices',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }
}
