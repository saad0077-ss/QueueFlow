import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/tenant_clinic_entity.dart';

class ClinicDetailsKpiGrid extends StatelessWidget {
  final TenantClinicEntity clinic;
  final ({String status, String detail})? queueSummary;
  final int appointmentsThisMonth;

  const ClinicDetailsKpiGrid({
    super.key,
    required this.clinic,
    required this.queueSummary,
    required this.appointmentsThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final cardWidth = isWide
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _kpiCard(
                colors,
                icon: Icons.workspace_premium_rounded,
                color: const Color(0xFF38BDF8),
                title: 'SUBSCRIPTION PLAN',
                value: clinic.planName,
                subtitle: '${clinic.billingCadence} • Auto-Renewing',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _kpiCard(
                colors,
                icon: Icons.confirmation_number_outlined,
                color: const Color(0xFF10B981),
                title: 'LIVE QUEUE STATUS',
                value: queueSummary?.status ?? 'No Queue Yet',
                subtitle:
                    queueSummary?.detail ?? 'Clinic has not opened a queue',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _kpiCard(
                colors,
                icon: Icons.medical_services_outlined,
                color: const Color(0xFFA855F7),
                title: 'DOCTORS ON ROSTER',
                value:
                    '${clinic.doctors.length} Doctor${clinic.doctors.length == 1 ? '' : 's'}',
                subtitle:
                    '${clinic.doctors.where((d) => d.isAvailable).length} available now',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _kpiCard(
                colors,
                icon: Icons.calendar_today_rounded,
                color: const Color(0xFFF59E0B),
                title: 'PATIENT VOLUME',
                value:
                    '$appointmentsThisMonth Appointment${appointmentsThisMonth == 1 ? '' : 's'}',
                subtitle: 'Queue tickets this month',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _kpiCard(
    AppColorsExtension colors, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: colors.textMuted,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: colors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
