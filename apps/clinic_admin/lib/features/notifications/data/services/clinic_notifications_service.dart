import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/clinic_notification_item.dart';

class ClinicNotificationsService {
  static final ClinicNotificationsService instance =
      ClinicNotificationsService._();
  ClinicNotificationsService._();

  static const String _kReadIdsKey = 'clinic_admin_read_notifications';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      final list = (prefs.getStringList(_kReadIdsKey) ?? []).toSet()..add(id);
      await prefs.setStringList(_kReadIdsKey, list.toList());
    } catch (_) {}
  }

  Future<void> markAllAsRead(List<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = (prefs.getStringList(_kReadIdsKey) ?? []).toSet()..addAll(ids);
      await prefs.setStringList(_kReadIdsKey, list.toList());
    } catch (_) {}
  }

  Stream<List<ClinicNotificationItem>> watchNotifications(String clinicId) async* {
    if (clinicId.isEmpty) {
      yield [];
      return;
    }

    final readIds = await _getReadIds();

    final ticketsStream = _firestore
        .collection('tickets')
        .where('clinicId', isEqualTo: clinicId)
        .limit(15)
        .snapshots();

    await for (final tSnap in ticketsStream) {
      final appts = await _firestore
          .collection('appointments')
          .where('clinicId', isEqualTo: clinicId)
          .limit(15)
          .get();
      final sSnap = await _firestore
          .collection('support_tickets')
          .where('clinicId', isEqualTo: clinicId)
          .limit(15)
          .get();

      final items = <ClinicNotificationItem>[];

      for (final doc in tSnap.docs) {
        final d = doc.data();
        final id = 'ticket_${doc.id}';
        final token = d['tokenNumber'] ?? d['token'] ?? 'T';
        final service = d['serviceName'] ?? 'Consultation';
        final status = (d['status'] ?? 'waiting').toString();
        items.add(
          ClinicNotificationItem(
            id: id,
            title: 'Token #$token ($status)',
            body: '${d['customerName'] ?? d['patientName'] ?? 'Walk-in'} joined $service',
            timestamp: _parseDate(d['createdAt']),
            type: ClinicNotificationType.queue,
            routeNav: 'Live Queue',
            isRead: readIds.contains(id),
          ),
        );
      }

      for (final doc in appts.docs) {
        final d = doc.data();
        final id = 'appt_${doc.id}';
        final name = d['customerName'] ?? d['patientName'] ?? 'Patient';
        final doctor = d['doctor'] ?? d['doctorName'] ?? 'Doctor';
        final status = (d['status'] ?? 'Scheduled').toString().toUpperCase();
        items.add(
          ClinicNotificationItem(
            id: id,
            title: 'Appointment: $name ($status)',
            body: 'With Dr. $doctor on ${d['date'] ?? 'Today'} at ${d['time'] ?? 'Scheduled'}',
            timestamp: _parseDate(d['createdAt']),
            type: ClinicNotificationType.appointment,
            routeNav: 'Appointments',
            isRead: readIds.contains(id),
          ),
        );
      }

      for (final doc in sSnap.docs) {
        final d = doc.data();
        final id = 'supp_${doc.id}';
        final subject = d['subject'] ?? 'Patient inquiry';
        final category = d['category'] ?? 'Support';
        items.add(
          ClinicNotificationItem(
            id: id,
            title: 'Support Inquiry: $category',
            body: '${d['patientName'] ?? 'Patient'}: $subject',
            timestamp: _parseDate(d['createdAt']),
            type: ClinicNotificationType.support,
            routeNav: 'Patient Tickets',
            isRead: readIds.contains(id),
          ),
        );
      }

      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      yield items;
    }
  }

  DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return DateTime.now();
  }
}
