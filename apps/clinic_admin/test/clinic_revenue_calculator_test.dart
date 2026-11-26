import 'package:clinic_admin/features/appointments/domain/entities/clinic_appointment_entity.dart';
import 'package:clinic_admin/features/queue/domain/entities/clinic_queue_item_entity.dart';
import 'package:clinic_admin/features/revenue/data/calculators/clinic_revenue_calculator.dart';
import 'package:clinic_admin/features/revenue/domain/entities/clinic_revenue_summary.dart';
import 'package:clinic_admin/features/revenue/domain/repositories/clinic_revenue_repository.dart';
import 'package:clinic_admin/features/revenue/presentation/bloc/clinic_revenue_bloc.dart';
import 'package:clinic_admin/features/revenue/presentation/bloc/clinic_revenue_event.dart';
import 'package:clinic_admin/features/services/domain/entities/clinic_service_entity.dart';
import 'package:flutter_test/flutter_test.dart';

ClinicAppointmentEntity _appt({
  required String id,
  required String dateRaw,
  required String paymentStatus,
  double paymentAmount = 0,
  double servicePrice = 0,
  String gateway = 'Razorpay (Online UPI)',
  String method = 'UPI (Google Pay)',
  String service = 'General Consultation',
  String doctor = 'Dr. Priya',
  String status = 'completed',
  double? refundAmount,
}) {
  return ClinicAppointmentEntity(
    id: id,
    bookingId: 'QF-$id',
    customerName: 'Patient $id',
    phone: '9876543210',
    email: 'p$id@example.com',
    service: service,
    serviceCategory: 'General Medicine',
    departmentName: 'General Medicine',
    serviceDuration: '20 mins',
    servicePrice: servicePrice,
    serviceDescription: '',
    doctor: doctor,
    doctorRole: 'General Physician',
    dateTime: '$dateRaw · 10:00 AM',
    dateRaw: dateRaw,
    timeRaw: '10:00 AM',
    status: status,
    notes: '',
    type: 'In-Person',
    room: 'Suite 1',
    payment: AppointmentPaymentEntity(
      status: paymentStatus,
      amount: paymentAmount,
      gateway: gateway,
      method: method,
      receiptNo: 'REC-$id',
      refundAmount: refundAmount,
    ),
  );
}

void main() {
  final anchor = DateTime(2026, 11, 25, 14, 0);

  test('combines Razorpay appointments and deduplicated walk-in queue earnings', () {
    final summary = ClinicRevenueCalculator.compute(
      clinicName: 'Green Heaven Clinic',
      period: ClinicRevenuePeriod.month,
      anchor: anchor,
      services: const [
        ClinicServiceEntity(id: 's1', name: 'Dental Checkup', price: 750),
      ],
      appointments: [
        _appt(id: '1', dateRaw: '2026-11-25', paymentStatus: 'paid', paymentAmount: 600),
        _appt(
          id: '4', dateRaw: '2026-11-18', paymentStatus: 'refunded',
          paymentAmount: 500, refundAmount: 500, status: 'cancelled',
        ),
        _appt(id: '5', dateRaw: '2026-11-10', paymentStatus: 'void', paymentAmount: 900, status: 'cancelled'),
      ],
      queueItems: [
        ClinicQueueItemEntity(
          id: 'q-walkin-1', token: 'GH-DC-001', clinicId: 'c1',
          patientName: 'Walk-In Patient', serviceName: 'Dental Checkup',
          doctorName: 'Dr. Anand', joinedAt: DateTime(2026, 11, 25, 11, 0),
          joinedTime: '11:00 AM', status: 'completed', paymentStatus: 'paid',
        ),
        ClinicQueueItemEntity(
          id: '1', token: 'QF-1', clinicId: 'c1',
          patientName: 'Duplicate Booked Patient', serviceName: 'Dental Checkup',
          doctorName: 'Dr. Priya', joinedAt: DateTime(2026, 11, 25, 10, 0),
          status: 'waiting', paymentStatus: 'paid',
        ),
      ],
    );

    expect(summary.grossCollected, 1350);
    expect(summary.razorpayRevenue, 600);
    expect(summary.walkInQueueRevenue, 750);
    expect(summary.refundedTotal, 500);
    expect(summary.netRevenue, 850);
    expect(summary.razorpayCount, 1);
    expect(summary.walkInQueueCount, 1);
    expect(summary.channelStats.map((c) => c.label).toList(), [
      'Razorpay Payments',
      'Walk-In Queue',
    ]);
    expect(summary.serviceBreakdown.first.serviceName, 'Dental Checkup');
    expect(summary.doctorLeaderboard.first.doctorName, 'Dr. Anand');
  });

  test('includes historical bookings when period is all time', () {
    final summary = ClinicRevenueCalculator.compute(
      clinicName: 'Green Heaven Clinic',
      period: ClinicRevenuePeriod.all,
      anchor: anchor,
      services: const [],
      appointments: [_appt(id: 'old', dateRaw: '2026-06-15', paymentStatus: 'paid', paymentAmount: 1200)],
    );
    expect(summary.grossCollected, 1200);
    expect(summary.trendPoints.length, 6);
  });

  test('ClinicRevenueBloc switches period and resubscribes cleanly', () async {
    ClinicRevenuePeriod? observed;
    final repo = _CallbackRepo((p) {
      observed = p;
      return Stream.value(ClinicRevenueCalculator.compute(
        clinicName: 'Clinic', period: p, appointments: const [], services: const [],
      ));
    });
    final bloc = ClinicRevenueBloc(repository: repo)..add(const ClinicRevenueStarted());
    await Future<void>.delayed(Duration.zero);
    expect(observed, ClinicRevenuePeriod.month);
    bloc.add(const ClinicRevenuePeriodChanged(ClinicRevenuePeriod.week));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(observed, ClinicRevenuePeriod.week);
    await bloc.close();
  });
}

class _CallbackRepo implements ClinicRevenueRepository {
  final Stream<ClinicRevenueSummary> Function(ClinicRevenuePeriod) builder;
  _CallbackRepo(this.builder);
  @override
  Stream<ClinicRevenueSummary> watchRevenue({ClinicRevenuePeriod period = ClinicRevenuePeriod.month}) =>
      builder(period);
}
