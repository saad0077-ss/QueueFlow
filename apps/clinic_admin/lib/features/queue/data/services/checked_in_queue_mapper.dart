import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';

typedef QueueTicketEntry = ({
  String id,
  String appointmentId,
  ClinicQueueItemEntity? item,
});

typedef CheckedInAppointmentEntry = ({String id, Map<String, dynamic> data});

/// Maps checked-in `appointments` docs and merges them into Live Queue items.
class CheckedInQueueMapper {
  const CheckedInQueueMapper._();

  static const _statusOrder = {
    'called': 0,
    'waiting': 1,
    'skipped': 2,
    'completed': 3,
  };

  /// Returns true when an appointment status indicates the patient is checked in.
  static bool isCheckedInStatus(Object? raw) {
    final s = (raw ?? '').toString().trim().toLowerCase();
    return s == 'checkedin' || s == 'checked-in';
  }

  /// Converts an appointment Firestore map into a waiting [ClinicQueueItemEntity].
  static ClinicQueueItemEntity fromAppointmentMap(
    String id,
    Map<String, dynamic> d,
  ) {
    final joinedAt = _parseDate(
      d['checkedInAt'] ?? d['joinedAt'] ?? d['createdAt'],
    );
    final pay = d['payment'] is Map
        ? Map<String, dynamic>.from(d['payment'] as Map)
        : const <String, dynamic>{};
    return ClinicQueueItemEntity(
      id: id,
      token: _first([
        d['token'],
        d['queueToken'],
        d['bookingRef'],
        d['bookingId'],
      ], 'APT'),
      clinicId: _s(d['clinicId']),
      patientName: _first([
        d['customerName'],
        d['patientName'],
        d['customer'],
      ], 'Patient'),
      serviceName: _first([
        d['serviceName'],
        d['service'],
      ], 'General Consultation'),
      doctorName: _first([d['doctorName'], d['doctor']], 'Attending Doctor'),
      phone: _first([d['customerPhone'], d['phone'], d['patientPhone']]),
      email: _first([d['customerEmail'], d['email'], d['patientEmail']]),
      joinedTime: _first([d['joinedTime']], _formatTime(joinedAt)),
      joinedAt: joinedAt,
      estDuration: _duration(d['estDuration'] ?? d['serviceDuration']),
      status: 'waiting',
      note: _first([d['note'], d['notes']]),
      paymentStatus: _first([
        d['paymentStatus'],
        pay['status'],
      ], 'pending').toLowerCase(),
      fee: _num(d['servicePrice'] ?? d['price'] ?? d['fee'] ?? pay['amount']),
    );
  }

  /// Merges active `tickets` with checked-in `appointments` that lack a ticket.
  static List<ClinicQueueItemEntity> mergeEntries({
    required Iterable<QueueTicketEntry> ticketEntries,
    required Iterable<CheckedInAppointmentEntry> checkedInAppts,
    void Function(String apptId, Map<String, dynamic> data)? onMissingTicket,
  }) {
    final represented = <String>{};
    final items = <ClinicQueueItemEntity>[];

    for (final entry in ticketEntries) {
      if (entry.id.isNotEmpty) represented.add(entry.id);
      if (entry.appointmentId.isNotEmpty) represented.add(entry.appointmentId);
      final item = entry.item;
      if (item != null && item.status != 'cancelled') {
        items.add(item);
      }
    }

    for (final appt in checkedInAppts) {
      if (appt.id.isEmpty || represented.contains(appt.id)) continue;
      represented.add(appt.id);
      items.add(fromAppointmentMap(appt.id, appt.data));
      onMissingTicket?.call(appt.id, appt.data);
    }

    items.sort((a, b) {
      final w = (_statusOrder[a.status] ?? 4).compareTo(
        _statusOrder[b.status] ?? 4,
      );
      return w != 0 ? w : a.joinedAt.compareTo(b.joinedAt);
    });
    return items;
  }

  static String _s(Object? v) => (v ?? '').toString().trim();

  static String _first(List<Object?> values, [String fallback = '']) {
    for (final v in values) {
      final t = _s(v);
      if (t.isNotEmpty) return t;
    }
    return fallback;
  }

  static double _num(Object? v) => v is num ? v.toDouble() : 0.0;

  static String _duration(Object? v) {
    if (v is num && v > 0) return '${v.toInt()} min';
    final s = _s(v);
    return s.isEmpty ? '20 min' : s;
  }

  static DateTime _parseDate(Object? v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  static String _formatTime(DateTime dt) {
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h12:$m ${dt.hour >= 12 ? 'PM' : 'AM'}';
  }
}
