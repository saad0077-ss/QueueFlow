import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/appointment_entity.dart';
import 'my_bookings_empty_state.dart';
import 'my_bookings_list.dart';

class MyBookingsContent extends StatelessWidget {
  final bool isLoading;
  final List<AppointmentEntity> appointments;
  final int selectedFilterIndex;
  final VoidCallback? onExploreClinics;
  final ValueChanged<AppointmentEntity> onCancel;
  final VoidCallback? onTrackLiveQueue;

  const MyBookingsContent({
    super.key,
    required this.isLoading,
    required this.appointments,
    required this.selectedFilterIndex,
    required this.onExploreClinics,
    required this.onCancel,
    this.onTrackLiveQueue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    if (appointments.isEmpty) {
      return MyBookingsEmptyState(
        selectedFilterIndex: selectedFilterIndex,
        onExploreClinics: onExploreClinics,
      );
    }

    return MyBookingsList(
      appointments: appointments,
      onCancel: onCancel,
      onTrackLiveQueue: onTrackLiveQueue,
    );
  }
}
