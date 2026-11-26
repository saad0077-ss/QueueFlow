import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';
import '../../domain/utils/clinic_token_generator.dart';
import 'checked_in_queue_mapper.dart';
import 'queue_token_allocator.dart';

/// Synchronizes checked-in `appointments` and `tickets` in Firestore.
class CheckedInAppointmentQueueSync {
  const CheckedInAppointmentQueueSync._();
  static final Map<String, Future<void>> _inFlight = {};

  static Future<void> ensureTicketForAppointment(
    FirebaseFirestore fs, {
    required String appointmentId,
    Map<String, dynamic>? apptData,
    String? clinicNameHint,
  }) => _inFlight[appointmentId] ??= _ensureImpl(
    fs,
    appointmentId: appointmentId,
    apptData: apptData,
    clinicNameHint: clinicNameHint,
  ).whenComplete(() => _inFlight.remove(appointmentId));

  static Future<void> _ensureImpl(
    FirebaseFirestore fs, {
    required String appointmentId,
    Map<String, dynamic>? apptData,
    String? clinicNameHint,
  }) async {
    final apptRef = fs.collection('appointments').doc(appointmentId);
    final data = apptData ?? (await apptRef.get()).data();
    if (data == null || !CheckedInQueueMapper.isCheckedInStatus(data['status'])) {
      return;
    }
    final ticketRef = fs.collection('tickets').doc(appointmentId);
    if ((await ticketRef.get()).exists) return;
    final linked = await fs
        .collection('tickets')
        .where('appointmentId', isEqualTo: appointmentId)
        .limit(1)
        .get();
    if (linked.docs.isNotEmpty) return;

    final item = CheckedInQueueMapper.fromAppointmentMap(appointmentId, data);
    if (item.clinicId.isEmpty) return;
    var clinicName = (data['clinicName'] ?? clinicNameHint ?? '').toString().trim();
    if (clinicName.isEmpty) {
      final cDoc = await fs.collection('clinics').doc(item.clinicId).get();
      clinicName = (cDoc.data()?['name'] ?? 'Clinic').toString();
    }
    final code = ClinicTokenGenerator.extractServiceCode(item.serviceName);
    final existing = (data['token'] ?? data['queueToken'] ?? '').toString().trim();
    final hasTok = existing.isNotEmpty && existing != 'APT' && existing != 'A-000';
    final fallbackMax = hasTok
        ? 0
        : await QueueTokenAllocator.maxSeqFromTickets(fs, item.clinicId, item.serviceName);

    await fs.runTransaction((tx) async {
      if ((await tx.get(ticketRef)).exists) return;
      final qRef = fs.collection('queues').doc(item.clinicId);
      final qSnap = await tx.get(qRef);
      final seq = hasTok
          ? ClinicTokenGenerator.parseSequenceNumber(existing)
          : QueueTokenAllocator.nextSeqFromQueueData(
              qSnap.data(),
              serviceCode: code,
              serviceName: item.serviceName,
              fallbackMax: fallbackMax,
            );
      final token = hasTok
          ? existing
          : ClinicTokenGenerator.generateToken(
              clinicName: clinicName,
              serviceName: item.serviceName,
              sequenceNumber: seq!,
            );
      tx.set(ticketRef, _buildTicketMap(appointmentId, data, item, clinicName, token));
      tx.set(apptRef, {'token': token, 'queueToken': token}, SetOptions(merge: true));
      tx.set(qRef, {
        if (!hasTok && seq != null) 'serviceCounters': {code: seq},
        'waitingCount': FieldValue.increment(1),
        'status': 'open',
        'lastIssuedToken': token,
      }, SetOptions(merge: true));
    });
  }

  static Map<String, dynamic> _buildTicketMap(
    String id,
    Map<String, dynamic> d,
    ClinicQueueItemEntity item,
    String clinicName,
    String token,
  ) {
    final pid = (d['customerId'] ?? d['patientId'] ?? d['userId'] ?? '').toString().trim();
    final sid = (d['serviceId'] ?? '').toString().trim();
    final did = (d['doctorId'] ?? '').toString().trim();
    final dept = (d['departmentName'] ?? '').toString().trim();
    return {
      'clinicId': item.clinicId,
      'clinicName': clinicName,
      'appointmentId': id,
      'source': 'appointment',
      'token': token,
      'queueToken': token,
      if (pid.isNotEmpty) ...{'patientId': pid, 'customerId': pid},
      'patientName': item.patientName,
      'customerName': item.patientName,
      'serviceName': item.serviceName,
      'service': item.serviceName,
      if (sid.isNotEmpty) 'serviceId': sid,
      if (dept.isNotEmpty) 'departmentName': dept,
      'doctorName': item.doctorName,
      if (did.isNotEmpty) 'doctorId': did,
      'phone': item.phone,
      'email': item.email.toLowerCase(),
      if (item.email.isNotEmpty) 'patientEmail': item.email.toLowerCase(),
      'joinedTime': item.joinedTime,
      'joinedAt': Timestamp.fromDate(item.joinedAt),
      'estDuration': item.estDuration,
      'status': 'waiting',
      'note': item.note,
      'paymentStatus': item.paymentStatus,
      'fee': item.fee,
      'servicePrice': item.fee,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
