import 'dart:async';
import '../../domain/entities/clinic_appointment_entity.dart';
import '../../domain/repositories/clinic_appointments_repository.dart';

class ClinicAppointmentsRepositoryImpl implements ClinicAppointmentsRepository {
  final List<ClinicAppointmentEntity> _appointments = [];
  final StreamController<List<ClinicAppointmentEntity>> _controller =
      StreamController<List<ClinicAppointmentEntity>>.broadcast();

  ClinicAppointmentsRepositoryImpl({
    List<ClinicAppointmentEntity>? initialData,
  }) {
    if (initialData != null) _appointments.addAll(initialData);
  }

  @override
  Stream<List<ClinicAppointmentEntity>> watchAppointments() async* {
    yield List.unmodifiable(_appointments);
    yield* _controller.stream;
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_appointments));
    }
  }

  @override
  Future<void> addAppointment(ClinicAppointmentEntity appointment) async {
    _appointments.insert(0, appointment);
    _emit();
  }

  @override
  Future<void> checkInAppointment(String id) async {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final current = _appointments[idx];
      _appointments[idx] = current.copyWith(status: 'checkedin');
      _emit();
    }
  }

  @override
  Future<void> completeAppointment(String id) async {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final current = _appointments[idx];
      _appointments[idx] = current.copyWith(status: 'completed');
      _emit();
    }
  }

  @override
  Future<void> rescheduleAppointment(
    String id,
    String newDate,
    String newTime,
  ) async {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final current = _appointments[idx];
      _appointments[idx] = current.copyWith(
        dateRaw: newDate,
        timeRaw: newTime,
        dateTime: '$newDate · $newTime',
        status: 'confirmed',
      );
      _emit();
    }
  }

  @override
  Future<void> cancelAppointment(
    String id, {
    String? reason,
    double? refundAmount,
  }) async {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final current = _appointments[idx];
      final pay = current.payment;
      // Only a paid booking has money to refund. Already-refunded stays as is;
      // unpaid (due) bookings are simply voided.
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
        _simulateRefundSettlement(id);
      } else if (pay.isRefunded) {
        updatedPayment = pay;
      } else {
        updatedPayment = pay.copyWith(status: 'void');
      }
      _appointments[idx] = current.copyWith(
        status: 'cancelled',
        notes: reason != null
            ? '${current.notes} [Cancellation Reason: $reason]'
            : current.notes,
        payment: updatedPayment,
      );
      _emit();
    }
  }

  /// Mock of the gateway webhook that confirms a refund was processed.
  void _simulateRefundSettlement(String id) {
    Future.delayed(const Duration(seconds: 4), () {
      final idx = _appointments.indexWhere((a) => a.id == id);
      if (idx == -1) return;
      final current = _appointments[idx];
      if (current.payment.refundStatus != 'pending') return;
      _appointments[idx] = current.copyWith(
        payment: current.payment.copyWith(
          refundStatus: 'processed',
          refundedAt: 'Processed to source account',
        ),
      );
      _emit();
    });
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

  void dispose() {
    _controller.close();
  }
}
