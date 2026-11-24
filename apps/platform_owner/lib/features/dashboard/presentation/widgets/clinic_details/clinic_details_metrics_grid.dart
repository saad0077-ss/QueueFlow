import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/tenant_clinic_entity.dart';

class ClinicDetailsMetricsGrid extends StatelessWidget {
  final TenantClinicEntity clinic;
  final ({String status, String detail})? queueSummary;
  final int appointmentsThisMonth;

  const ClinicDetailsMetricsGrid({
    super.key,
    required this.clinic,
    required this.queueSummary,
    required this.appointmentsThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = [
      AppMetricCard(
        tag: 'SUBSCRIPTION PLAN',
        tagColor: const Color(0xFF38BDF8),
        label: 'Subscription Plan',
        value: clinic.planName,
        icon: Icons.workspace_premium_rounded,
        iconColor: const Color(0xFF38BDF8),
        iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.35),
        borderColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
        bottomWidget: Text(
          '${clinic.billingCadence} • Auto-Renewing',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'LIVE QUEUE STATUS',
        tagColor: const Color(0xFF10B981),
        label: 'Queue Status',
        value: queueSummary?.status ?? 'No Queue Yet',
        icon: Icons.confirmation_number_outlined,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF065F46).withValues(alpha: 0.35),
        borderColor: const Color(0xFF059669).withValues(alpha: 0.4),
        bottomWidget: Text(
          queueSummary?.detail ?? 'Clinic has not opened a queue',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'DOCTORS ON ROSTER',
        tagColor: const Color(0xFFA855F7),
        label: 'Doctors on Roster',
        value:
            '${clinic.doctors.length} Doctor${clinic.doctors.length == 1 ? '' : 's'}',
        icon: Icons.medical_services_outlined,
        iconColor: const Color(0xFFC084FC),
        iconBgColor: const Color(0xFF581C87).withValues(alpha: 0.35),
        borderColor: const Color(0xFF7E22CE).withValues(alpha: 0.4),
        bottomWidget: Text(
          '${clinic.doctors.where((d) => d.isAvailable).length} available now',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      AppMetricCard(
        tag: 'PATIENT VOLUME',
        tagColor: const Color(0xFFF59E0B),
        label: 'Patient Volume',
        value:
            '$appointmentsThisMonth Appointment${appointmentsThisMonth == 1 ? '' : 's'}',
        icon: Icons.calendar_today_rounded,
        iconColor: const Color(0xFFFBBF24),
        iconBgColor: const Color(0xFF78350F).withValues(alpha: 0.35),
        borderColor: const Color(0xFFB45309).withValues(alpha: 0.4),
        bottomWidget: Text(
          'Queue tickets this month',
          style: GoogleFonts.inter(fontSize: 9.5, color: colors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final cardWidth = isWide
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((c) => SizedBox(width: cardWidth, child: c))
              .toList(),
        );
      },
    );
  }
}
