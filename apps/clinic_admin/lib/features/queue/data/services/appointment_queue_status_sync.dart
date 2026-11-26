import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors terminal queue/appointment states (`completed`, `cancelled`) across
/// `appointments` and `tickets` so both tabs stay consistent.
class AppointmentQueueStatusSync {
  const AppointmentQueueStatusSync._();

  static Future<void> syncTicketFromAppointment(
    FirebaseFirestore fs,
    String apptId, {
    required String status,
  }) async {
    try {
      final ts = FieldValue.serverTimestamp();
      final payload = <String, dynamic>{
        'status': status,
        if (status == 'completed') 'completedAt': ts,
        if (status == 'cancelled') 'cancelledAt': ts,
      };
      final direct = fs.collection('tickets').doc(apptId);
      if ((await direct.get()).exists) await direct.update(payload);
      final linked = await fs
          .collection('tickets')
          .where('appointmentId', isEqualTo: apptId)
          .get();
      for (final d in linked.docs) {
        if (d.id != apptId) await d.reference.update(payload);
      }
    } catch (_) {}
  }

  static Future<void> syncAppointmentFromTicket(
    FirebaseFirestore fs,
    DocumentSnapshot<Map<String, dynamic>> ticketDoc, {
    required String status,
  }) async {
    try {
      final d = ticketDoc.data() ?? const <String, dynamic>{};
      final raw = (d['appointmentId'] ?? '').toString().trim();
      final apptId = raw.isNotEmpty
          ? raw
          : (d['source'] == 'appointment' ? ticketDoc.id : '');
      if (apptId.isEmpty) return;
      final ts = FieldValue.serverTimestamp();
      await fs.collection('appointments').doc(apptId).update({
        'status': status,
        if (status == 'completed') ...{'isCompleted': true, 'completedAt': ts},
        if (status == 'cancelled') ...{'cancelledAt': ts, 'cancelledBy': 'clinic'},
      });
    } catch (_) {}
  }
}
