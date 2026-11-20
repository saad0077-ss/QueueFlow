import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';

class ServiceQueueStatusBadge extends StatelessWidget {
  final ClinicQueueItemEntity item;
  final int waitPos;

  const ServiceQueueStatusBadge({
    super.key,
    required this.item,
    this.waitPos = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (item.isCalled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF10B981)),
        ),
        child: Text(
          'SERVING NOW',
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF059669),
          ),
        ),
      );
    }
    if (item.isWaiting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF0284C7).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          waitPos > 0 ? 'WAITING (#$waitPos)' : 'WAITING',
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0284C7),
          ),
        ),
      );
    }
    if (item.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'COMPLETED',
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'SKIPPED',
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFD97706),
        ),
      ),
    );
  }
}
