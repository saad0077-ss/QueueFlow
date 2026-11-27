import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';

import 'booking_queue_time_helpers.dart';

class BookingQueueAccessResult {
  final bool isEnabled;
  final String reason;

  const BookingQueueAccessResult({
    required this.isEnabled,
    this.reason = '',
  });
}

/// Determines whether `Join / Track Queue` should be enabled for a booking:
/// active only on the consultation date while the clinic is open inside its
/// operating hours and the clinic admin has not paused or closed the queue.
class BookingQueueAccessEvaluator {
  const BookingQueueAccessEvaluator._();

  static BookingQueueAccessResult evaluate({
    required AppointmentEntity appointment,
    required ClinicEntity? clinic,
    Map<String, dynamic>? queueDoc,
    DateTime? currentTime,
  }) {
    if (!appointment.isUpcoming) {
      return const BookingQueueAccessResult(isEnabled: false);
    }

    final now = currentTime ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final consultDate = BookingQueueTimeHelpers.parseDateOnly(
      appointment.dateRaw,
    );

    if (consultDate != null) {
      if (consultDate.isAfter(todayDate)) {
        return BookingQueueAccessResult(
          isEnabled: false,
          reason:
              'Opens on ${BookingQueueTimeHelpers.formatShortDate(consultDate)}',
        );
      }
      if (consultDate.isBefore(todayDate)) {
        return const BookingQueueAccessResult(
          isEnabled: false,
          reason: 'Booking date passed',
        );
      }
    } else if (!appointment.dateTime.toLowerCase().startsWith('today')) {
      return const BookingQueueAccessResult(
        isEnabled: false,
        reason: 'Opens on visit date',
      );
    }

    if (clinic == null) {
      return const BookingQueueAccessResult(
        isEnabled: false,
        reason: 'Waiting for clinic',
      );
    }
    if (!clinic.isOpen) {
      return const BookingQueueAccessResult(
        isEnabled: false,
        reason: 'Clinic closed today',
      );
    }
    if (!clinic.isOpenAt(now)) {
      return BookingQueueAccessResult(
        isEnabled: false,
        reason: BookingQueueTimeHelpers.closedHoursReason(clinic, now),
      );
    }

    final breakEnd = clinic.breakEndsAt(now);
    if (breakEnd != null) {
      return BookingQueueAccessResult(
        isEnabled: false,
        reason: 'Break till ${BookingQueueTimeHelpers.formatBreakEnd(breakEnd)}',
      );
    }

    final queueError = queueUnavailableReason(queueDoc);
    if (queueError != null) {
      return BookingQueueAccessResult(isEnabled: false, reason: queueError);
    }

    if (_isServiceClosedToday(queueDoc, appointment.serviceName, now)) {
      return const BookingQueueAccessResult(
        isEnabled: false,
        reason: 'Service closed today',
      );
    }

    return const BookingQueueAccessResult(isEnabled: true);
  }

  /// Returns a user-facing reason when [queueDoc] marks the queue unavailable.
  static String? queueUnavailableReason(Map<String, dynamic>? queueDoc) {
    final qStatus = (queueDoc?['status'] ?? '').toString().trim().toLowerCase();
    if (qStatus == 'paused' || queueDoc?['isPaused'] == true) {
      return 'Queue paused';
    }
    if (qStatus == 'closed' ||
        qStatus == 'not_started' ||
        qStatus == 'inactive' ||
        queueDoc?['isQueueOpen'] == false) {
      return 'Queue not started';
    }
    return null;
  }

  static bool _isServiceClosedToday(
    Map<String, dynamic>? queueDoc,
    String serviceName,
    DateTime now,
  ) {
    final closedRaw = queueDoc?['closedServices'];
    final svcKey = serviceName.trim().toLowerCase();
    if (closedRaw is! Map || svcKey.isEmpty) return false;
    final todayIso =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return closedRaw.entries.any(
      (e) =>
          e.key.toString().trim().toLowerCase() == svcKey &&
          e.value.toString() == todayIso,
    );
  }
}
