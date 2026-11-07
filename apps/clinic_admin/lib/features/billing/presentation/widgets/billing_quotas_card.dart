import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/billing_plan_tier_entity.dart';
import '../../domain/entities/clinic_subscription_entity.dart';

class BillingQuotasCard extends StatelessWidget {
  final ClinicSubscriptionEntity subscription;

  final BillingPlanTierEntity? currentTier;

  const BillingQuotasCard({super.key, required this.subscription, this.currentTier});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final docLimit = subscription.doctorLimit;
    final isDocUnlim = subscription.isDoctorUnlimited;

    final docRatio = isDocUnlim ? 0.3 : (subscription.activeDoctors / docLimit).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Capacity & Resource Quotas', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Real-time allocation against your current subscription limits', style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          _meterBox(
            colors: colors,
            icon: Icons.medical_services_outlined,
            title: 'Doctor Capacity',
            value: isDocUnlim ? '${subscription.activeDoctors} Active (Unlimited Capacity)' : '${subscription.activeDoctors} of $docLimit Active Practicing Doctors',
            subtext: isDocUnlim ? 'Enterprise Plan • Unlimited Doctors Allowed' : '${subscription.planName} • $docLimit Doctor Allowed',
            ratio: docRatio,
            color: colors.success,
          ),
          if (currentTier != null && currentTier!.features.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('INCLUDED IN YOUR PLAN', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: colors.textMuted, letterSpacing: 0.6)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final f in currentTier!.features)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: colors.success),
                        const SizedBox(width: 6),
                        Text(f, style: GoogleFonts.inter(fontSize: 11.5, color: colors.textPrimary)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _meterBox({
    required AppColorsExtension colors,
    required IconData icon,
    required String title,
    required String value,
    required String subtext,
    required double ratio,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.surfaceSecondary, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(children: [
                  Icon(icon, size: 15, color: color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Text(value, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: colors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: ratio, backgroundColor: colors.border, color: color, minHeight: 6),
          ),
          const SizedBox(height: 6),
          Text(subtext, style: GoogleFonts.inter(fontSize: 11, color: colors.textSubtle)),
        ],
      ),
    );
  }
}
