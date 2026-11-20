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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (ctx, idx) {
        final apt = appointments[idx];
        return BookingHistoryCard(
          appointment: apt,
          onBookAgain: onBookAgain != null ? () => onBookAgain!(apt.clinicId) : null,
          onRateVisit: onRateVisit != null ? () => onRateVisit!(apt) : null,
          onTrackQueue: onTrackQueue,
        );
      },
    );
  }
}
