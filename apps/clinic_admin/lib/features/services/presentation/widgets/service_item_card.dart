import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_service_entity.dart';
import 'service_card_actions.dart';
import 'service_doctor_assignment_box.dart';

class ServiceItemCard extends StatelessWidget {
  final ClinicServiceEntity service;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ServiceItemCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPending = service.isPending;
    final isRejected = service.isRejected;
    final borderColor = isPending
        ? colors.warning
        : (isRejected ? colors.error : colors.border);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isPending || isRejected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.badgeOpenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_services_outlined,
                  color: colors.badgeOpenText,
                  size: 22,
                ),
              ),
              _buildStatusPill(context, isPending, isRejected),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            service.name,
            style: GoogleFonts.inter(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            service.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colors.textMuted,
              height: 1.45,
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.warningTint,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '⏳ Awaiting Super Admin review: Will activate once approved.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: colors.warning,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${service.duration} min',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${service.price}',
                style: GoogleFonts.spaceMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ServiceDoctorAssignmentBox(assignedStaff: service.assignedStaff),
          const Spacer(),
          Divider(height: 32, color: colors.border),
          ServiceCardActions(
            isPending: isPending,
            isActive: service.isActive,
            onEdit: onEdit,
            onToggle: onToggle,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, bool isPending, bool isRejected) {
    final colors = context.colors;
    final text = isPending
        ? '⏳ PENDING'
        : (isRejected ? '❌ REJECTED' : service.status.toUpperCase());
    final Color color;
    final Color bg;

    if (isPending) {
      color = colors.warning;
      bg = colors.warningTint;
    } else if (isRejected) {
      color = colors.error;
      bg = colors.errorTint;
    } else if (service.isActive) {
      color = colors.badgeOpenText;
      bg = colors.badgeOpenBg;
    } else {
      color = colors.textMuted;
      bg = colors.surfaceSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
