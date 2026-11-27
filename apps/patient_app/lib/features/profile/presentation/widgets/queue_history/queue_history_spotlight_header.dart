import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/clinic_profile_avatar.dart';

import '../../../domain/entities/patient_queue_history_entity.dart';
import 'queue_history_doctor_row.dart';

class QueueHistorySpotlightHeader extends StatelessWidget {
  final PatientQueueHistoryEntity ticket;

  const QueueHistorySpotlightHeader({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'ACTIVE LIVE TOKEN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFA7F3D0),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ClinicProfileAvatar(
                    clinicId: ticket.clinicId,
                    clinicName: ticket.clinicName,
                    imageVersion: ticket.clinicImageVersion,
                    imageUrl: ticket.clinicImageUrl,
                    size: 40,
                    borderRadius: 11,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.clinicName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${ticket.departmentName} · ${ticket.serviceName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (ticket.doctorName.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                QueueHistoryDoctorRow(
                  doctorName: ticket.doctorName,
                  photoUrl: ticket.doctorPhotoUrl,
                  textColor: Colors.white.withValues(alpha: 0.92),
                  borderColor: Colors.white.withValues(alpha: 0.5),
                  radius: 10,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              ticket.token,
              style: GoogleFonts.robotoMono(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFDE047),
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Joined ${ticket.joinedTime}',
              style: TextStyle(
                fontSize: 10.5,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
