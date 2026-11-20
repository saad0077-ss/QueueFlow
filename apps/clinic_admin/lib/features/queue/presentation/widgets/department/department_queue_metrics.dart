import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/clinic_queue_item_entity.dart';

class DepartmentQueueMetrics extends StatelessWidget {
  final int servicesCount;
  final List<ClinicQueueItemEntity> deptServing;
  final List<ClinicQueueItemEntity> deptWaiting;
  final bool isQueueOpen;
  final bool isCollapsed;

  const DepartmentQueueMetrics({
    super.key,
    required this.servicesCount,
    required this.deptServing,
    required this.deptWaiting,
    required this.isQueueOpen,
    required this.isCollapsed,
  });

  Widget _metricPill(
    BuildContext context, {
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    if (!isQueueOpen) {
      return _metricPill(
        context,
        label: 'Paused',
        bg: const Color(0xFFF59E0B).withValues(alpha: 0.15),
        fg: const Color(0xFFD97706),
      );
    }
    if (deptWaiting.length > 8) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'High Load (${deptWaiting.length} W)',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFDC2626),
          ),
        ),
      );
    }
    if (deptWaiting.isEmpty && deptServing.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'All Clear',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Active',
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF059669),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _metricPill(
          context,
          label: '$servicesCount Services',
          bg: colors.surfaceSecondary,
          fg: colors.textPrimary,
        ),
        if (deptServing.isNotEmpty)
          _metricPill(
            context,
            label: '👨‍⚕️ ${deptServing.length} Serving: ${deptServing.take(2).map((s) => s.token).join(", ")}',
            bg: const Color(0xFF10B981).withValues(alpha: 0.14),
            fg: const Color(0xFF059669),
          ),
        _metricPill(
          context,
          label: '⏳ ${deptWaiting.length} Waiting',
          bg: deptWaiting.isNotEmpty
              ? const Color(0xFFF59E0B).withValues(alpha: 0.14)
              : colors.surfaceSecondary,
          fg: deptWaiting.isNotEmpty ? const Color(0xFFD97706) : colors.textMuted,
        ),
        _buildStatusBadge(context),
        AnimatedRotation(
          turns: isCollapsed ? 0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted, size: 22),
        ),
      ],
    );
  }
}
