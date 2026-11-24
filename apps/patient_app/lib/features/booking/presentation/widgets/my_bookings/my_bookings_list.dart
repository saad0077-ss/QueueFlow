import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/entities/appointment_entity.dart';
import 'my_booking_card.dart';

class MyBookingsList extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  final ValueChanged<AppointmentEntity> onCancel;
  final VoidCallback? onTrackLiveQueue;

  const MyBookingsList({
    super.key,
    required this.appointments,
    required this.onCancel,
    this.onTrackLiveQueue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isGrid = constraints.maxWidth >= 768;
        if (!isGrid) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: appointments.map((apt) {
              return MyBookingCard(
                apt: apt,
                onCancel: () => onCancel(apt),
                onTrackLiveQueue: onTrackLiveQueue,
              );
            }).toList(),
          );
        }

        final maxCols = constraints.maxWidth >= 1200 ? 3 : 2;
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
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var j = 0; j < columns; j++) ...[
                    if (j > 0) const SizedBox(width: 14),
                    Expanded(
                      child: j < row.length
                          ? MyBookingCard(
                              apt: row[j],
                              onCancel: () => onCancel(row[j]),
                              onTrackLiveQueue: onTrackLiveQueue,
                            )
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
}
