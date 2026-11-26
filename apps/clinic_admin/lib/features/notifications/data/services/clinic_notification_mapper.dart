import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/clinic_notification_item.dart';

/// Maps Firestore tickets, appointments, and support docs into [ClinicNotificationItem]s.
class ClinicNotificationMapper {
  const ClinicNotificationMapper._();

  static List<ClinicNotificationItem> buildList({
    required Set<String> readIds,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> tkts,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> apts,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> supps,
  }) {
    final items = <ClinicNotificationItem>[
      for (final doc in tkts) _mapTicket(doc, readIds.contains('ticket_${doc.id}')),
      for (final doc in apts) _mapAppointment(doc, readIds.contains('appt_${doc.id}')),
      for (final doc in supps) _mapSupport(doc, readIds.contains('supp_${doc.id}')),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  static ClinicNotificationItem _mapTicket(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    bool isRead,
  ) {
    final d = doc.data();
    final token = d['tokenNumber'] ?? d['token'] ?? 'T';
    final service = d['serviceName'] ?? 'Consultation';
    final status = (d['status'] ?? 'waiting').toString();
    return ClinicNotificationItem(
      id: 'ticket_${doc.id}',
      title: 'Token #$token ($status)',
      body: '${d['customerName'] ?? d['patientName'] ?? 'Walk-in'} joined $service',
      timestamp: _parseDate(d['createdAt']),
      type: ClinicNotificationType.queue,
      routeNav: 'Live Queue',
      isRead: isRead,
    );
  }

  static ClinicNotificationItem _mapAppointment(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    bool isRead,
  ) {
    final d = doc.data();
    final name = d['customerName'] ?? d['patientName'] ?? 'Patient';
    final doctor = d['doctor'] ?? d['doctorName'] ?? 'Doctor';
    final status = (d['status'] ?? 'Scheduled').toString().toUpperCase();
    return ClinicNotificationItem(
      id: 'appt_${doc.id}',
      title: 'Appointment: $name ($status)',
      body: 'With Dr. $doctor on ${d['date'] ?? 'Today'} at ${d['time'] ?? 'Scheduled'}',
      timestamp: _parseDate(d['createdAt']),
      type: ClinicNotificationType.appointment,
      routeNav: 'Appointments',
      isRead: isRead,
    );
  }

  static ClinicNotificationItem _mapSupport(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    bool isRead,
  ) {
    final d = doc.data();
    return ClinicNotificationItem(
      id: 'supp_${doc.id}',
      title: 'Support Inquiry: ${d['category'] ?? 'Support'}',
      body: '${d['patientName'] ?? 'Patient'}: ${d['subject'] ?? 'Patient inquiry'}',
      timestamp: _parseDate(d['createdAt']),
      type: ClinicNotificationType.support,
      routeNav: 'Patient Tickets',
      isRead: isRead,
    );
  }

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return DateTime.now();
  }
}
