import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';

import 'booking_history_card.dart';

class BookingHistoryList extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  final ValueChanged<String>? onBookAgain;
  final ValueChanged<AppointmentEntity>? onRateVisit;
  final VoidCallback? onTrackQueue;

  const BookingHistoryList({
    super.key,
    required this.appointments,
    this.onBookAgain,
    this.onRateVisit,
    this.onTrackQueue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isGrid = constraints.maxWidth >= 768;
        if (!isGrid) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) => _buildCard(appointments[idx]),
          );
        }

        final maxCols = constraints.maxWidth >= 1150 ? 3 : 2;
        final columns = appointments.length < maxCols
            ? math.max(1, appointments.length)
            : maxCols;
        final rows = <List<AppointmentEntity>>[];
        for (var i = 0; i < appointments.length; i += columns) {
          rows.add(
            appointments.sublist(
              i,
              (i + columns).clamp(0, appointments.length),
            ),
          );
        }

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var j = 0; j < columns; j++) ...[
                    if (j > 0) const SizedBox(width: 16),
                    Expanded(
                      child: j < row.length
                          ? _buildCard(row[j])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCard(AppointmentEntity apt) {
    return BookingHistoryCard(
      appointment: apt,
      onBookAgain:
          onBookAgain != null ? () => onBookAgain!(apt.clinicId) : null,
      onRateVisit: onRateVisit != null ? () => onRateVisit!(apt) : null,
      onTrackQueue: onTrackQueue,
    );
  }
}
