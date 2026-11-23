import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../services/domain/entities/clinic_service_entity.dart';

class ServiceQueueCardHeader extends StatelessWidget {
  final ClinicServiceEntity service;
  final bool isQueueOpen;
  final bool isServing;
  final int waitingCount;

  const ServiceQueueCardHeader({
    super.key,
    required this.service,
    required this.isQueueOpen,
    required this.isServing,
    required this.waitingCount,
  });

  Widget _pill({required String label, required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context) {
    if (!isQueueOpen) {
      return _pill(
        label: 'PAUSED',
        bg: const Color(0xFFF59E0B).withValues(alpha: 0.15),
        fg: const Color(0xFFD97706),
      );
    }
    if (isServing) {
      return _pill(
        label: '● SERVING',
        bg: const Color(0xFF10B981).withValues(alpha: 0.15),
        fg: const Color(0xFF059669),
      );
    }
    if (waitingCount > 0) {
      return _pill(
        label: '● $waitingCount WAITING',
        bg: context.colors.primaryTint,
        fg: context.colors.primary,
      );
    }
    return _pill(
      label: '● READY',
      bg: const Color(0xFF10B981).withValues(alpha: 0.15),
      fg: const Color(0xFF10B981),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${service.duration} mins · ₹${service.price}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusPill(context),
      ],
    );
  }
}
