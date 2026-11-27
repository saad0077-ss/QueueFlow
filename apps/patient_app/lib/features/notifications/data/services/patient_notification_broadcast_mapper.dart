import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/patient_notification_entity.dart';
import 'patient_notification_mapper.dart';

/// Maps platform/clinic `/notifications` broadcasts and stored FCM push payloads.
class PatientNotificationBroadcastMapper {
  const PatientNotificationBroadcastMapper._();

  static PatientNotificationEntity fromBroadcast(
    DocumentSnapshot<Map<String, dynamic>> doc,
    bool isRead,
  ) {
    final d = doc.data() ?? const {};
    final body = (d['message'] ?? d['body'] ?? d['desc'] ?? '').toString();
    final ref = (d['bookingRef'] ?? '').toString().trim();
    final rawRoute = (d['route'] ?? '').toString().trim();
    final isBooking = ref.isNotEmpty || rawRoute.startsWith('/my_bookings');
    final isQueue = rawRoute.startsWith('/live_queue');
    final category = isQueue
        ? PatientNotificationCategory.queue
        : (isBooking
              ? PatientNotificationCategory.booking
              : PatientNotificationCategory.broadcast);
    final route = rawRoute.isNotEmpty
        ? rawRoute
        : (isBooking ? '/my_bookings' : '/home');
    return PatientNotificationEntity(
      id: 'broad_${doc.id}',
      title: (d['title'] ?? 'QueueFlow Announcement').toString(),
      body: body,
      timestamp: PatientNotificationMapper.parseDate(d['createdAt']),
      category: category,
      route: route,
      isRead: isRead,
      clinicName: (d['clinicName'] ?? 'QueueFlow').toString().trim(),
      badgeLabel: ref.isNotEmpty ? ref : (isBooking ? 'Booking' : 'Announcement'),
      isUrgent: d['isBroadcast'] == true || isBooking,
    );
  }

  static ({List<PatientNotificationEntity> items, Set<String> personalDocIds}) collectBroadcasts({
    required List<DocumentSnapshot<Map<String, dynamic>>> docs,
    required String uid,
    required String email,
    required Set<String> readIds,
  }) {
    final items = <PatientNotificationEntity>[];
    final personalIds = <String>{};
    for (final d in docs) {
      final data = d.data() ?? const {};
      final target = (data['target'] ?? '').toString().trim().toLowerCase();
      final pId = (data['patientId'] ?? data['userId'] ?? data['customerId'] ?? '').toString();
      final dEmail = (data['userEmail'] ?? data['customerEmail'] ?? '').toString().trim().toLowerCase();
      final isGlobal = data['isBroadcast'] == true || target == 'all' || target == 'patients' || dEmail == 'all';
      final isForUser = pId == uid || (email.isNotEmpty && dEmail == email);
      if (!isGlobal && !isForUser) continue;
      if (isForUser && !isGlobal) personalIds.add(d.id);
      final read = readIds.contains('broad_${d.id}') || (isForUser && !isGlobal && data['unread'] == false);
      items.add(fromBroadcast(d, read));
    }
    return (items: items, personalDocIds: personalIds);
  }

  static PatientNotificationEntity fromPushMap(
    Map<String, dynamic> m,
    bool isRead,
  ) {
    final cat = switch ((m['category'] ?? 'broadcast').toString()) {
      'queue' => PatientNotificationCategory.queue,
      'booking' => PatientNotificationCategory.booking,
      'support' => PatientNotificationCategory.support,
      _ => PatientNotificationCategory.broadcast,
    };
    return PatientNotificationEntity(
      id: (m['id'] ?? '').toString(),
      title: (m['title'] ?? 'QueueFlow Push').toString(),
      body: (m['body'] ?? '').toString(),
      timestamp: PatientNotificationMapper.parseDate(m['timestampMs']),
      category: cat,
      route: (m['route'] ?? '/home').toString(),
      isRead: isRead,
      clinicName: (m['clinicName'] ?? '').toString(),
      badgeLabel: (m['badgeLabel'] ?? 'FCM Push').toString(),
      isUrgent: m['isUrgent'] == true,
      isPushReceived: true,
    );
  }
}
