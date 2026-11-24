import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/patient_notification_entity.dart';
import 'patient_notification_mapper.dart';

class PatientNotificationsService {
  static final PatientNotificationsService instance =
      PatientNotificationsService._();
  PatientNotificationsService._();

  static const String _kReadIdsKey = 'patient_read_notification_ids';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Set<String>> _getReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_kReadIdsKey) ?? []).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final set = (prefs.getStringList(_kReadIdsKey) ?? []).toSet()..add(id);
      await prefs.setStringList(_kReadIdsKey, set.toList());
    } catch (_) {}
  }

  Future<void> markAllAsRead(List<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final set = (prefs.getStringList(_kReadIdsKey) ?? []).toSet()..addAll(ids);
      await prefs.setStringList(_kReadIdsKey, set.toList());
    } catch (_) {}
  }

  Stream<List<PatientNotificationEntity>> watchNotifications() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    final uid = user.uid;
    final email = user.email ?? '';
    final readIds = await _getReadIds();

    final ticketsSnap = _firestore
        .collection('tickets')
        .where('customerId', isEqualTo: uid)
        .limit(10)
        .snapshots();

    await for (final tSnap in ticketsSnap) {
      final appts = await _firestore
          .collection('appointments')
          .where('customerId', isEqualTo: uid)
          .limit(10)
          .get();

      final support = await _firestore
          .collection('support_tickets')
          .where('patientId', isEqualTo: uid)
          .limit(10)
          .get();

      final broadcasts = await _firestore
          .collection('notifications')
          .limit(10)
          .get();

      final items = <PatientNotificationEntity>[
        for (final doc in tSnap.docs)
          PatientNotificationMapper.fromTicket(doc, readIds.contains('ticket_${doc.id}')),
        for (final doc in appts.docs)
          PatientNotificationMapper.fromAppointment(doc, readIds.contains('appt_${doc.id}')),
        for (final doc in support.docs)
          PatientNotificationMapper.fromSupport(doc, readIds.contains('supp_${doc.id}')),
      ];

      for (final doc in broadcasts.docs) {
        final d = doc.data();
        final id = 'broad_${doc.id}';
        final target = (d['target'] ?? '').toString();
        final pId = d['patientId'] ?? d['userId'] ?? '';
        if (target != 'all' && pId != uid && d['userEmail'] != email) continue;

        items.add(
          PatientNotificationEntity(
            id: id,
            title: d['title'] ?? 'QueueFlow Announcement',
            body: d['message'] ?? d['body'] ?? '',
            timestamp: PatientNotificationMapper.parseDate(d['createdAt']),
            category: PatientNotificationCategory.broadcast,
            route: d['route'] ?? '/home',
            isRead: readIds.contains(id),
          ),
        );
      }

      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      yield items;
    }
  }
}
