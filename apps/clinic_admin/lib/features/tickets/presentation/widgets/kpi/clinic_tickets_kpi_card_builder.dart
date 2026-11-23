import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'clinic_tickets_kpi_card_item.dart';

class ClinicTicketsKpiCardBuilder {
  static List<Widget> buildCards({
    required BuildContext context,
    required int totalCount,
    required int openCount,
    required int inProgressCount,
    required int resolvedCount,
  }) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return [
      ClinicTicketsKpiCardItem(
        tag: "TODAY'S VOLUME",
        tagColor: isDark ? const Color(0xFF94A3B8) : colors.textMuted,
        label: 'Clinic Inquiries',
        value: '$totalCount',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Patient Desk',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Patient requests today',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  color: colors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        icon: Icons.confirmation_number_outlined,
        iconColor: const Color(0xFF60A5FA),
        iconBgColor: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
        borderColor: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
      ),
      ClinicTicketsKpiCardItem(
        tag: 'LOBBY TRIAGE',
        tagColor: const Color(0xFFEF4444),
        hasRedDot: true,
        label: 'Needs Triage / Waiting',
        value: '$openCount',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 9.5)),
            const SizedBox(width: 3),
            Text(
              'Queue Priority',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF87171),
              ),
            ),
          ],
        ),
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFF87171),
        iconBgColor: const Color(0xFF7F1D1D).withValues(alpha: 0.35),
        borderColor: const Color(0xFF7F1D1D).withValues(alpha: 0.4),
      ),
      ClinicTicketsKpiCardItem(
        tag: 'ACTIVE HANDLING',
        tagColor: const Color(0xFFF59E0B),
        label: 'Under Staff Care',
        value: '$inProgressCount',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            const Text('🔄', style: TextStyle(fontSize: 9.5)),
            const SizedBox(width: 3),
            Text(
              'Staff responding',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFFD97706),
              ),
            ),
          ],
        ),
        icon: Icons.sync_rounded,
        iconColor: const Color(0xFFFBBF24),
        iconBgColor: const Color(0xFF78350F).withValues(alpha: 0.35),
        borderColor: const Color(0xFF78350F).withValues(alpha: 0.35),
      ),
      ClinicTicketsKpiCardItem(
        tag: 'RESOLVED TODAY',
        tagColor: const Color(0xFF10B981),
        label: 'Addressed & Closed',
        value: '$resolvedCount',
        valueColor: colors.textPrimary,
        bottomWidget: Row(
          children: [
            const Text('✅', style: TextStyle(fontSize: 9.5)),
            const SizedBox(width: 3),
            Text(
              'Closed within SLA',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF34D399)
                    : const Color(0xFF059669),
              ),
            ),
          ],
        ),
        icon: Icons.task_alt_rounded,
        iconColor: const Color(0xFF34D399),
        iconBgColor: const Color(0xFF064E3B).withValues(alpha: 0.35),
        borderColor: const Color(0xFF064E3B).withValues(alpha: 0.35),
      ),
    ];
  }
}
