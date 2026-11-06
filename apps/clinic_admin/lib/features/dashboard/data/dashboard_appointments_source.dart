import 'package:cloud_firestore/cloud_firestore.dart';
import '../../appointments/domain/entities/clinic_appointment_entity.dart';

/// Streams the clinic's real bookings (written by the patient app) from
/// Firestore and maps them to [ClinicAppointmentEntity].
class DashboardAppointmentsSource {
  final FirebaseFirestore _firestore;

  DashboardAppointmentsSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// [departmentOfService] maps a service id / name to its department name.
  Stream<List<ClinicAppointmentEntity>> watch({
    required String clinicId,
    required String Function(String serviceId, String serviceName, String specialty)
    departmentOfService,
  }) {
    return _firestore
        .collection('appointments')
        .where('clinicId', isEqualTo: clinicId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _map(d.id, d.data(), departmentOfService))
              .toList(),
        );
  }

  static String _s(Map<String, dynamic> m, String k) =>
      (m[k] ?? '').toString().trim();

  static ClinicAppointmentEntity _map(
    String id,
    Map<String, dynamic> m,
    String Function(String, String, String) departmentOfService,
  ) {
    final pay = m['payment'] is Map
        ? Map<String, dynamic>.from(m['payment'] as Map)
        : <String, dynamic>{};
    final serviceName = _s(m, 'serviceName').isNotEmpty
        ? _s(m, 'serviceName')
        : _s(m, 'service');
    final price = (m['servicePrice'] as num?)?.toDouble() ??
        (pay['amount'] as num?)?.toDouble() ??
        0.0;
    final status = _s(m, 'status').toLowerCase();

    return ClinicAppointmentEntity(
      id: id,
      bookingId: _s(m, 'bookingRef').isNotEmpty ? _s(m, 'bookingRef') : id,
      customerName: _s(m, 'customerName'),
      phone: _s(m, 'customerPhone'),
      email: _s(m, 'customerEmail'),
      service: serviceName,
      departmentName: departmentOfService(
        _s(m, 'serviceId'),
        serviceName,
        _s(m, 'doctorSpecialty'),
      ),
      serviceDuration: _s(m, 'serviceDuration'),
      servicePrice: price,
      doctor: _s(m, 'doctorName'),
      doctorRole: _s(m, 'doctorSpecialty'),
      dateTime: _s(m, 'dateTime'),
      dateRaw: _s(m, 'dateRaw'),
      timeRaw: _s(m, 'timeRaw'),
      status: status.isEmpty ? 'confirmed' : status,
      notes: _s(m, 'notes'),
      payment: AppointmentPaymentEntity(
        status: _s(pay, 'status').isEmpty ? 'pending' : _s(pay, 'status'),
        amount: (pay['amount'] as num?)?.toDouble() ?? price,
        gateway: _s(pay, 'gateway'),
        method: _s(pay, 'method'),
        paymentId: _s(pay, 'paymentId'),
        paidAt: _s(pay, 'paidAt'),
      ),
    );
  }
}
