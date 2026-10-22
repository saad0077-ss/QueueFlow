import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/clinic_service_entity.dart';
import 'service_card_actions.dart';
import 'service_doctor_assignment_box.dart';
import 'service_ui_kit.dart';

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
    final isPending = service.isPending;
    final isRejected = service.isRejected;
    final borderColor = isPending
        ? ServiceColors.amber
        : (isRejected ? ServiceColors.red : ServiceColors.border);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ServiceColors.surface,
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              _buildStatusPill(isPending, isRejected),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            service.name,
            style: GoogleFonts.inter(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            service.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFFCBD5E1),
              height: 1.45,
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ServiceColors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ServiceColors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '⏳ Awaiting Super Admin review: Will activate once approved.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: ServiceColors.amber,
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
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${service.duration} min',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
              Text(
                '₹${service.price}',
                style: GoogleFonts.spaceMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ServiceColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ServiceDoctorAssignmentBox(assignedStaff: service.assignedStaff),
          const Spacer(),
          const Divider(height: 32, color: ServiceColors.border),
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

  Widget _buildStatusPill(bool isPending, bool isRejected) {
    final text = isPending
        ? '⏳ PENDING'
        : (isRejected ? '❌ REJECTED' : service.status.toUpperCase());
    final color = isPending
        ? ServiceColors.amber
        : (isRejected
              ? ServiceColors.red
              : (service.isActive ? ServiceColors.green : ServiceColors.muted));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
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
