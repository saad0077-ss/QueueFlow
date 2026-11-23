import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';

import 'booking_history_status_pill.dart';

class BookingHistoryCardHeader extends StatelessWidget {
  final AppointmentEntity appointment;

  const BookingHistoryCardHeader({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPaid = appointment.isPaid;
    final payAmount = appointment.payment?.amount ?? appointment.servicePrice;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.clinicName,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                appointment.serviceName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '🩺 ${appointment.doctorSpecialty.isNotEmpty ? appointment.doctorSpecialty : 'General Care'}',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '⏱️ ${appointment.serviceDuration} min',
                    style: TextStyle(fontSize: 11, color: colors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BookingHistoryStatusPill(
              isUpcoming: appointment.isUpcoming,
              isCompleted: appointment.isCompleted,
              isCancelled: appointment.isCancelled,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isPaid
                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${isPaid ? '✓ PAID' : '⏳ DUE'} · ₹${payAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isPaid
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
