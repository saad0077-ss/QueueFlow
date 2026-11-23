import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../services/domain/entities/clinic_service_entity.dart';
import '../../../../services/domain/entities/service_department_entity.dart';

class ServiceQueueDetailHeroInfo extends StatelessWidget {
  final ClinicServiceEntity service;
  final ServiceDepartmentEntity? department;

  const ServiceQueueDetailHeroInfo({
    super.key,
    required this.service,
    this.department,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colors.primaryTint,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            department?.icon.isNotEmpty == true ? department!.icon : '🩺',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryTint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (department?.name ?? 'GENERAL MEDICINE').toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${service.duration} mins per patient',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                  ),
                  Text(
                    '•  ₹${service.price} Fee',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                service.name,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                service.description.isNotEmpty
                    ? service.description
                    : 'Comprehensive clinical care and consultation.',
                style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
