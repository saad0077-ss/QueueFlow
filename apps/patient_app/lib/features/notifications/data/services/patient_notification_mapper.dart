import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/patient_notification_entity.dart';
import 'patient_notification_broadcast_mapper.dart';

class PatientNotificationMapper {
  const PatientNotificationMapper._();

  static DateTime parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  static String _formatDoctorName(String raw) {
    final clean = raw.trim();
    if (clean.isEmpty) return 'Doctor';
    return clean.toLowerCase().startsWith('dr') ? clean : 'Dr. $clean';
  }

  static PatientNotificationEntity fromTicket(
    DocumentSnapshot<Map<String, dynamic>> doc,
    bool isRead,
  ) {
    final d = doc.data() ?? const {};
    final token = (d['tokenNumber'] ?? d['token'] ?? d['queueToken'] ?? '—').toString();
    final status = (d['status'] ?? 'waiting').toString().trim().toLowerCase();
    final clinic = (d['clinicName'] ?? 'Clinic').toString().trim();
    final service = (d['serviceName'] ?? 'Consultation').toString().trim();
    final doctor = (d['doctorName'] ?? d['doctor'] ?? '').toString().trim();
    final docSuffix = doctor.isNotEmpty && doctor.toLowerCase() != 'attending doctor'
        ? ' with ${_formatDoctorName(doctor)}'
        : '';

    final (title, body, badge, urgent) = switch (status) {
      'called' => (
        '🔔 Token #$token Called!',
        'Please proceed to your consultation room at $clinic ($service)$docSuffix.',
        'Now Serving',
        true,
      ),
      'completed' => (
        '✅ Token #$token Completed',
        'Your $service queue visit at $clinic is completed.',
        'Served',
        false,
      ),
      'cancelled' || 'canceled' => (
        'Token #$token Cancelled',
        'Your queue spot for $service at $clinic was cancelled.',
        'Cancelled',
        false,
      ),
      _ => (
        '⏳ Queue Spot: Token #$token',
        'Waiting in line for $service at $clinic$docSuffix.',
        'Token #$token',
        false,
      ),
    };

    return PatientNotificationEntity(
      id: 'ticket_${doc.id}',
      title: title,
      body: body,
      timestamp: parseDate(d['calledAt'] ?? d['updatedAt'] ?? d['joinedAt'] ?? d['createdAt']),
      category: PatientNotificationCategory.queue,
      route: '/live_queue',
      isRead: isRead,
      clinicName: clinic,
      badgeLabel: badge,
      isUrgent: urgent,
    );
  }

  static PatientNotificationEntity fromAppointment(
    DocumentSnapshot<Map<String, dynamic>> doc,
    bool isRead,
  ) {
    final d = doc.data() ?? const {};
    final doctor = _formatDoctorName((d['doctorName'] ?? d['doctor'] ?? 'Doctor').toString());
    final clinic = (d['clinicName'] ?? 'Clinic').toString().trim();
    final statusRaw = (d['status'] ?? 'confirmed').toString().trim();
    final status = statusRaw.toLowerCase();
    final date = (d['dateRaw'] ?? d['date'] ?? d['appointmentDate'] ?? '').toString().trim();
    final time = (d['timeRaw'] ?? d['time'] ?? d['appointmentTime'] ?? '').toString().trim();
    final when = (d['dateTime'] ?? '').toString().trim().isNotEmpty
        ? d['dateTime'].toString().trim()
        : (date.isNotEmpty ? '$date${time.isNotEmpty ? ' at $time' : ''}' : 'Upcoming slot');
    final capStatus = statusRaw.isNotEmpty
        ? '${statusRaw[0].toUpperCase()}${statusRaw.substring(1)}'
        : 'Updated';

    return PatientNotificationEntity(
      id: 'appt_${doc.id}',
      title: status == 'confirmed'
          ? '✅ Appointment Confirmed · $doctor'
          : (status == 'cancelled' || status == 'canceled')
              ? '⚠️ Appointment Cancelled · $doctor'
              : 'Appointment: $doctor ($capStatus)',
      body: '$when · $clinic',
      timestamp: parseDate(d['updatedAt'] ?? d['createdAt']),
      category: PatientNotificationCategory.booking,
      route: '/my_bookings',
      isRead: isRead,
      clinicName: clinic,
      badgeLabel: capStatus,
      isUrgent: status == 'confirmed' || status == 'cancelled' || status == 'called',
    );
  }

  static PatientNotificationEntity fromSupport(
    DocumentSnapshot<Map<String, dynamic>> doc,
    bool isRead,
  ) {
    final d = doc.data() ?? const {};
    final shortId = doc.id.length > 5 ? doc.id.substring(0, 5) : doc.id;
    final num = (d['ticketNumber'] ?? shortId).toString();
    final clinic = (d['clinicName'] ?? 'Support Team').toString().trim();
    final status = (d['status'] ?? 'open').toString().trim();
    final msgs = d['messages'];
    var preview = '${d['subject'] ?? 'Concern'}: Care desk status is $status';
    if (msgs is List && msgs.isNotEmpty && msgs.last is Map) {
      final last = Map<String, dynamic>.from(msgs.last as Map);
      final text = (last['text'] ?? last['message'] ?? '').toString().trim();
      final sender = (last['sender'] ?? 'Care Desk').toString().trim();
      if (text.isNotEmpty) preview = '$sender: $text';
    }
    return PatientNotificationEntity(
      id: 'supp_${doc.id}', title: '💬 Support Ticket #$num', body: preview,
      timestamp: parseDate(d['updatedAt'] ?? d['createdAt']),
      category: PatientNotificationCategory.support,
      route: '/support_chat?ticketId=${doc.id}', isRead: isRead,
      clinicName: clinic, badgeLabel: status.toUpperCase(),
      isUrgent: status.toLowerCase() == 'in_progress',
    );
  }

  static PatientNotificationEntity fromBroadcast(
    DocumentSnapshot<Map<String, dynamic>> doc, bool isRead,
  ) => PatientNotificationBroadcastMapper.fromBroadcast(doc, isRead);

  static PatientNotificationEntity fromPushMap(
    Map<String, dynamic> m, bool isRead,
  ) => PatientNotificationBroadcastMapper.fromPushMap(m, isRead);
}
