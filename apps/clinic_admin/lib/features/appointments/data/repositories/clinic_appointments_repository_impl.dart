import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/current_clinic_resolver.dart';
import '../../domain/entities/clinic_appointment_entity.dart';
import '../../domain/repositories/clinic_appointments_repository.dart';

/// Reads and writes the shared `appointments` collection, so everything the
/// clinic does (check-in, complete, cancel, reschedule) shows up instantly in
/// the patient app, and every patient booking shows up here.
class ClinicAppointmentsRepositoryImpl implements ClinicAppointmentsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  List<ClinicAppointmentEntity> _appointments = [];
  DocumentSnapshot<Map<String, dynamic>>? _clinicDoc;

  ClinicAppointmentsRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('appointments');

  Future<DocumentSnapshot<Map<String, dynamic>>> _clinic() async {
    return _clinicDoc ??= await CurrentClinicResolver.require(
      auth: _auth,
      firestore: _firestore,
    );
  }

  // ───────────────────────── Reads ─────────────────────────

  @override
  Stream<List<ClinicAppointmentEntity>> watchAppointments() async* {
    final DocumentSnapshot<Map<String, dynamic>> clinic;
    try {
      clinic = await _clinic();
    } catch (_) {
      _appointments = [];
      yield const [];
      return;
    }
    yield* _col.where('clinicId', isEqualTo: clinic.id).snapshots().asyncMap((snap) async {
      final docs = snap.docs.toList()
        ..sort((a, b) => _createdMillis(b.data()).compareTo(_createdMillis(a.data())));
      final list = <ClinicAppointmentEntity>[];
      for (final d in docs) {
        var appt = _fromDoc(d.id, d.data());
        if (appt.customerPhoto.isEmpty) {
          final photo = await _patientPhoto(d.data());
          if (photo.isNotEmpty) appt = appt.copyWith(customerPhoto: photo);
        }
        list.add(appt);
      }
      _appointments = list;
      return List<ClinicAppointmentEntity>.unmodifiable(list);
    });
  }

  final Map<String, String> _photoCache = {};

  /// Older bookings have no photo stored; look it up from the patient's profile.
  Future<String> _patientPhoto(Map<String, dynamic> m) async {
    final uid = _s(m['customerId'] ?? m['patientId'] ?? m['userId']);
    final email = _s(m['customerEmail'] ?? m['email']).toLowerCase();
    final key = uid.isNotEmpty ? 'uid:$uid' : 'mail:$email';
    if (key == 'mail:') return '';
    final cached = _photoCache[key];
    if (cached != null) return cached;
    var photo = '';
    try {
      Map<String, dynamic>? data;
      if (uid.isNotEmpty) {
        data = (await _firestore.collection('users').doc(uid).get()).data();
      } else {
        final q = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        data = q.docs.firstOrNull?.data();
      }
      photo = _s(data?['photoBase64'] ?? data?['photoUrl']);
    } catch (_) {}
    return _photoCache[key] = photo;
  }

  static int _createdMillis(Map<String, dynamic> m) {
    final v = m['createdAt'];
    if (v is Timestamp) return v.millisecondsSinceEpoch;
    if (v is String) return DateTime.tryParse(v)?.millisecondsSinceEpoch ?? 0;
    return 0;
  }

  static String _s(Object? v, [String fallback = '']) {
    final t = (v ?? '').toString().trim();
    return t.isEmpty ? fallback : t;
  }

  static ClinicAppointmentEntity _fromDoc(String id, Map<String, dynamic> m) {
    final price = (m['servicePrice'] as num?)?.toDouble() ??
        (m['price'] as num?)?.toDouble() ??
        0.0;
    final duration = m['serviceDuration'];
    final payMap = m['payment'] is Map
        ? Map<String, dynamic>.from(m['payment'] as Map)
        : <String, dynamic>{};
    final paymentStatus = _s(payMap['status'], payMap.isEmpty ? 'pending' : 'paid');

    return ClinicAppointmentEntity(
      id: id,
      bookingId: _s(m['bookingRef'] ?? m['bookingId'], id),
      customerName: _s(m['customerName'] ?? m['patientName'] ?? m['customer'], 'Patient'),
      customerPhoto: _s(m['customerPhoto']),
      phone: _s(m['customerPhone'] ?? m['phone']),
      email: _s(m['customerEmail'] ?? m['email']),
      service: _s(m['serviceName'] ?? m['service'], 'Consultation'),
      serviceCategory: _s(m['doctorSpecialty'] ?? m['specialty'], 'General Medicine'),
      departmentName: _s(m['departmentName'] ?? m['doctorSpecialty'] ?? m['specialty'], 'General Medicine'),
      serviceDuration: duration is num ? '${duration.toInt()} mins' : _s(duration, '20 mins'),
      servicePrice: price,
      serviceDescription: _s(m['serviceDescription']),
      doctor: _s(m['doctorName'] ?? m['doctor'], 'Doctor'),
      doctorRole: _s(m['doctorSpecialty'] ?? m['specialty'], 'Consulting Physician'),
      dateTime: _s(m['dateTime']),
      dateRaw: _s(m['dateRaw'] ?? m['date']),
      timeRaw: _s(m['timeRaw'] ?? m['time'] ?? m['timeSlot']),
      status: _s(m['status'], 'confirmed').toLowerCase(),
      notes: _s(m['notes']),
      type: _s(m['type'], 'In-Person Consultation'),
      room: _s(m['room'], 'Consultation Room'),
      payment: AppointmentPaymentEntity(
        status: paymentStatus,
        amount: (payMap['amount'] as num?)?.toDouble() ?? price,
        currency: _s(payMap['currency'], 'INR'),
        gateway: _s(payMap['gateway'], 'Razorpay (Online UPI)'),
        method: _s(payMap['method'], 'Online'),
        paymentId: _s(payMap['paymentId']),
        orderId: _s(payMap['orderId']),
        receiptNo: _s(payMap['receiptNo'], 'REC-${_s(m['bookingRef'] ?? m['bookingId'], id).replaceAll('QF-', '')}'),
        paidAt: _s(payMap['paidAt']),
        refundAmount: (payMap['refundAmount'] as num?)?.toDouble(),
        refundId: payMap['refundId']?.toString(),
        refundedAt: payMap['refundedAt']?.toString(),
        refundNote: payMap['refundNote']?.toString(),
        refundStatus: payMap['refundStatus']?.toString(),
      ),
    );
  }

  static Map<String, dynamic> _paymentToMap(AppointmentPaymentEntity p) => {
        'status': p.status,
        'amount': p.amount,
        'currency': p.currency,
        'gateway': p.gateway,
        'method': p.method,
        'paymentId': p.paymentId,
        'orderId': p.orderId,
        'receiptNo': p.receiptNo,
        'paidAt': p.paidAt,
        if (p.refundAmount != null) 'refundAmount': p.refundAmount,
        if (p.refundId != null) 'refundId': p.refundId,
        if (p.refundedAt != null) 'refundedAt': p.refundedAt,
        if (p.refundNote != null) 'refundNote': p.refundNote,
        if (p.refundStatus != null) 'refundStatus': p.refundStatus,
      };

  // ───────────────────────── Writes ─────────────────────────

  @override
  Future<void> addAppointment(ClinicAppointmentEntity a) async {
    final clinic = await _clinic();
    final clinicName = _s(clinic.data()?['name'], 'Clinic');
    final minutes = int.tryParse(RegExp(r'\d+').firstMatch(a.serviceDuration)?.group(0) ?? '') ?? 20;
    await _col.add({
      'bookingRef': a.bookingId,
      'bookingId': a.bookingId,
      'clinicId': clinic.id,
      'clinicName': clinicName,
      'customerId': '',
      'customerName': a.customerName,
      'customer': a.customerName,
      'patientName': a.customerName,
      'customerPhone': a.phone,
      'customerEmail': a.email.trim().toLowerCase(),
      'doctorId': '',
      'doctorName': a.doctor,
      'doctor': a.doctor,
      'doctorSpecialty': a.departmentName,
      'departmentName': a.departmentName,
      'serviceId': '',
      'serviceName': a.service,
      'service': a.service,
      'serviceDuration': minutes,
      'servicePrice': a.servicePrice,
      'price': a.servicePrice,
      'dateRaw': a.dateRaw,
      'date': a.dateRaw,
      'timeRaw': a.timeRaw,
      'time': a.timeRaw,
      'timeSlot': a.timeRaw,
      'dateTime': a.dateTime,
      'status': a.status,
      'notes': a.notes,
      'payment': _paymentToMap(a.payment),
      'createdBy': 'clinic',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates the appointment and notifies the patient in the patient app.
  Future<void> _update(
    String id,
    Map<String, dynamic> fields, {
    required String notifyTitle,
    required String Function(Map<String, dynamic> appt) notifyBody,
  }) async {
    final ref = _col.doc(id);
    final before = (await ref.get()).data() ?? const <String, dynamic>{};
    await ref.update(fields);
    try {
      await _firestore.collection('notifications').add({
        'title': notifyTitle,
        'desc': notifyBody(before),
        'userId': before['customerId'] ?? '',
        'userEmail': before['customerEmail'] ?? '',
        'clinicId': before['clinicId'] ?? '',
        'bookingRef': before['bookingRef'] ?? before['bookingId'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'unread': true,
      });
    } catch (_) {}
  }

  static String _what(Map<String, dynamic> m) =>
      '${_s(m['serviceName'] ?? m['service'], 'appointment')} at ${_s(m['clinicName'], 'the clinic')}';

  @override
  Future<void> checkInAppointment(String id) => _update(
        id,
        {'status': 'checkedin', 'checkedInAt': FieldValue.serverTimestamp()},
        notifyTitle: 'Checked In',
        notifyBody: (m) => 'You have been checked in for ${_what(m)}. Please wait to be called.',
      );

  @override
  Future<void> completeAppointment(String id) => _update(
        id,
        {
          'status': 'completed',
          'isCompleted': true,
          'completedAt': FieldValue.serverTimestamp(),
        },
        notifyTitle: 'Appointment Completed',
        notifyBody: (m) => 'Your visit for ${_what(m)} is complete. Thank you!',
      );

  @override
  Future<void> rescheduleAppointment(
    String id,
    String newDate,
    String newTime,
  ) =>
      _update(
        id,
        {
          'dateRaw': newDate,
          'date': newDate,
          'timeRaw': newTime,
          'time': newTime,
          'timeSlot': newTime,
          'dateTime': '$newDate · $newTime',
          'status': 'confirmed',
        },
        notifyTitle: 'Appointment Rescheduled',
        notifyBody: (m) => 'Your ${_what(m)} has moved to $newDate · $newTime.',
      );

  @override
  Future<void> cancelAppointment(
    String id, {
    String? reason,
    double? refundAmount,
  }) async {
    final current = _appointments.where((a) => a.id == id).firstOrNull ??
        _fromDoc(id, (await _col.doc(id).get()).data() ?? const {});
    final pay = current.payment;
    final AppointmentPaymentEntity updatedPayment;
    if (pay.isPaid) {
      final amount = (refundAmount ?? pay.amount).clamp(0, pay.amount);
      updatedPayment = pay.copyWith(
        status: 'refunded',
        refundAmount: amount.toDouble(),
        refundId: 'rfnd_${DateTime.now().millisecondsSinceEpoch}',
        refundedAt: 'Initiated just now · arrives in 5-7 working days',
        refundNote: reason ?? 'Cancelled by Clinic Administration desk.',
        refundStatus: 'pending',
      );
    } else if (pay.isRefunded) {
      updatedPayment = pay;
    } else {
      updatedPayment = pay.copyWith(status: 'void');
    }
    await _update(
      id,
      {
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': 'clinic',
        if (reason != null) 'notes': '${current.notes} [Cancellation Reason: $reason]'.trim(),
        'payment': _paymentToMap(updatedPayment),
      },
      notifyTitle: 'Appointment Cancelled',
      notifyBody: (m) =>
          'Your ${_what(m)} was cancelled by the clinic.${reason != null ? ' Reason: $reason' : ''}',
    );
  }

  @override
  Future<String> exportAppointmentsCsv() async {
    final buffer = StringBuffer();
    buffer.writeln(
      'Booking Ref,Patient Name,Phone,Email,Service,Department,Doctor,Date,Time,Status,Payment Status,Amount,Gateway,Transaction ID,Receipt No',
    );
    for (final a in _appointments) {
      buffer.writeln(
        '${_esc(a.bookingId)},${_esc(a.customerName)},${_esc(a.phone)},${_esc(a.email)},${_esc(a.service)},${_esc(a.departmentName)},${_esc(a.doctor)},${_esc(a.dateRaw)},${_esc(a.timeRaw)},${_esc(a.status)},${_esc(a.payment.status)},${a.payment.amount},${_esc(a.payment.gateway)},${_esc(a.payment.paymentId)},${_esc(a.payment.receiptNo)}',
      );
    }
    return buffer.toString();
  }

  String _esc(String input) {
    if (input.contains(',') || input.contains('"') || input.contains('\n')) {
      return '"${input.replaceAll('"', '""')}"';
    }
    return input;
  }

  void dispose() {}
}
