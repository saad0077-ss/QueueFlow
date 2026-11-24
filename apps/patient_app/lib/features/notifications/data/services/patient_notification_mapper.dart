import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/patient_notification_entity.dart';

class PatientNotificationMapper {
  const PatientNotificationMapper._();

  static DateTime parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return DateTime.now();
  }

  static PatientNotificationEntity fromTicket(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    bool isRead,
  ) {
    final d = doc.data();
    final token = d['tokenNumber'] ?? d['token'] ?? '—';
    final isCalled = (d['status'] ?? '') == 'called';
    final clinic = d['clinicName'] ?? 'Clinic';

    return PatientNotificationEntity(
      id: 'ticket_${doc.id}',
      title: isCalled ? '🔔 Token #$token Called!' : 'Queue Spot: Token #$token',
      body: isCalled
          ? 'Please proceed to your consultation room at $clinic.'
          : 'You are in line for ${d['serviceName'] ?? 'Consultation'} at $clinic.',
      timestamp: parseDate(d['createdAt']),
      category: PatientNotificationCategory.queue,
      route: '/live_queue',
      isRead: isRead,
    );
  }

  static PatientNotificationEntity fromAppointment(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    bool isRead,
  ) {
    final d = doc.data();
    final doctor = d['doctor'] ?? d['doctorName'] ?? 'Doctor';
    final status = (d['status'] ?? 'Confirmed').toString();

    return PatientNotificationEntity(
      id: 'appt_${doc.id}',
      title: 'Appointment: Dr. $doctor ($status)',
      body: 'On ${d['date'] ?? 'Upcoming'} at ${d['time'] ?? ''} · ${d['clinicName'] ?? ''}',
      timestamp: parseDate(d['createdAt']),
      category: PatientNotificationCategory.booking,
      route: '/my_bookings',
      isRead: isRead,
    );
  }

  static PatientNotificationEntity fromSupport(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    bool isRead,
  ) {
    final d = doc.data();
    final num = d['ticketNumber'] ?? doc.id.substring(0, 5);

    return PatientNotificationEntity(
      id: 'supp_${doc.id}',
      title: 'Support Inquiry #$num Update',
      body: '${d['subject'] ?? 'Concern'}: Care desk status is ${d['status'] ?? 'active'}',
      timestamp: parseDate(d['createdAt']),
      category: PatientNotificationCategory.support,
      route: '/support_chat?ticketId=${doc.id}',
      isRead: isRead,
    );
  }
}
