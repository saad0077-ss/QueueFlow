import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConcernDetailSlaBox extends StatelessWidget {
  final bool isResolved;
  final String slaCountdown;

  const ConcernDetailSlaBox({
    super.key,
    required this.isResolved,
    required this.slaCountdown,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = slaCountdown.startsWith('-');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isResolved
            ? const Color(0xFF10B981).withValues(alpha: 0.08)
            : const Color(0xFFF59E0B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isResolved
              ? const Color(0xFF10B981).withValues(alpha: 0.25)
              : const Color(0xFFF59E0B).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isResolved) ...[
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  'Care Desk SLA: $slaCountdown remaining',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isOverdue
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFB45309),
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 6),
                Text(
                  'Resolved within SLA commitment',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF047857),
                  ),
                ),
              ],
            ],
          ),
          Text(
            isResolved
                ? '100% ON-TIME'
                : (isOverdue ? 'OVERDUE' : 'IN PROGRESS'),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isResolved
                  ? const Color(0xFF047857)
                  : (isOverdue
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFB45309)),
            ),
          ),
        ],
      ),
    );
  }
}
