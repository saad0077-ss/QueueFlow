import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_subscription_entity.dart';

class BillingQuotasCard extends StatelessWidget {
  final ClinicSubscriptionEntity subscription;

  const BillingQuotasCard({super.key, required this.subscription});

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: colors.surfaceSecondary, borderRadius: BorderRadius.circular(20)),
                child: Text('Resets in 26 days', style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted, fontWeight: FontWeight.w600)),
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
          const SizedBox(height: 12),
          _meterBox(
            colors: colors,
            icon: Icons.checklist_rounded,
            title: 'Clinical Services Quota',
            // Services are unlimited on every plan.
            value: '${subscription.activeServices} Active (Unlimited Capacity)',
            subtext: 'All plans • Unlimited Services Allowed',
            ratio: 0.3,
            color: colors.accent,
          ),
          const SizedBox(height: 12),
          _meterBox(
            colors: colors,
            icon: Icons.meeting_room_outlined,
            title: 'Consultation Rooms',
            value: isDocUnlim ? 'Unlimited Consultation Rooms' : '${subscription.activeDoctors} Active Consultation Room',
            subtext: 'Dr. Priya • Consultation Room 1',
            ratio: 1.0,
            color: colors.primary,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.primary.withAlpha(80), style: BorderStyle.solid),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: colors.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'QueueFlow Active: Full live queue management, doctor calling, walk-ins, and digital queue displays are active.',
                    style: GoogleFonts.inter(fontSize: 12, color: colors.textPrimary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
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
