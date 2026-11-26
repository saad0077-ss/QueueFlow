import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../../queue/domain/entities/clinic_queue_item_entity.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';

/// Mutable aggregation bucket used during single-pass revenue grouping.
class RevenueAccumulatorBucket {
  final String subtitle;
  int count = 0;
  double amount = 0;

  RevenueAccumulatorBucket(this.subtitle);
}

/// Builds channel, service, doctor, and ledger breakdowns from parsed receipts.
class ClinicRevenueBreakdownBuilder {
  ClinicRevenueBreakdownBuilder._();

  static bool isWalkInOrCounterPayment(AppointmentPaymentEntity pay) {
    final text = '${pay.gateway} ${pay.method}'.toLowerCase();
    return text.contains('cash') ||
        text.contains('counter') ||
        text.contains('pos') ||
        text.contains('desk') ||
        text.contains('walk');
  }

  static List<RevenueChannelStat> buildChannels({
    required double razorpayRevenue,
    required int razorpayCount,
    required double walkInQueueRevenue,
    required int walkInQueueCount,
  }) {
    final total = razorpayRevenue + walkInQueueRevenue;
    double share(double v) => total > 0 ? (v / total) * 100 : 0.0;

    return [
      RevenueChannelStat(
        label: 'Razorpay Payments',
        amount: razorpayRevenue,
        count: razorpayCount,
        sharePercent: share(razorpayRevenue),
        isOnline: true,
      ),
      RevenueChannelStat(
        label: 'Walk-In Queue',
        amount: walkInQueueRevenue,
        count: walkInQueueCount,
        sharePercent: share(walkInQueueRevenue),
        isOnline: false,
      ),
    ];
  }

  static List<RevenueServiceStat> buildServices(
    Map<String, RevenueAccumulatorBucket> totals,
    double gross,
  ) {
    return totals.entries.map((e) {
      final share = gross > 0 ? (e.value.amount / gross) * 100 : 0.0;
      return RevenueServiceStat(
        serviceName: e.key,
        departmentName:
            e.value.subtitle.isNotEmpty ? e.value.subtitle : 'General Care',
        visits: e.value.count,
        revenue: e.value.amount,
        sharePercent: share,
      );
    }).toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  static List<RevenueDoctorStat> buildDoctors(
    Map<String, RevenueAccumulatorBucket> totals,
  ) {
    return totals.entries.map((e) {
      return RevenueDoctorStat(
        doctorName: e.key,
        specialty: e.value.subtitle.isNotEmpty
            ? e.value.subtitle
            : 'Consulting Specialist',
        consultations: e.value.count,
        revenue: e.value.amount,
      );
    }).toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  static RevenueLedgerEntry toLedger(
    ClinicAppointmentEntity appt, {
    required String status,
    required double gross,
    required double refund,
    required double net,
  }) {
    final p = appt.payment;
    final methodLabel = isWalkInOrCounterPayment(p)
        ? 'Walk-In Queue'
        : (p.method.isNotEmpty ? p.method : 'Razorpay Payments');
    return RevenueLedgerEntry(
      id: appt.id,
      bookingId: appt.bookingId,
      receiptNo: p.receiptNo.isNotEmpty ? p.receiptNo : appt.bookingId,
      patientName: appt.customerName,
      serviceName: appt.service,
      doctorName: appt.doctor,
      dateLabel: appt.dateTime.isNotEmpty ? appt.dateTime : appt.dateRaw,
      dateRaw: appt.dateRaw,
      method: methodLabel,
      status: status,
      grossAmount: gross,
      refundAmount: refund,
      netAmount: net,
    );
  }

  static RevenueLedgerEntry queueToLedger(
    ClinicQueueItemEntity item, {
    required String status,
    required double charge,
  }) {
    final d = item.joinedAt;
    final iso =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final label = item.joinedTime.isNotEmpty ? '$iso · ${item.joinedTime}' : iso;
    return RevenueLedgerEntry(
      id: item.id,
      bookingId: item.token,
      receiptNo: item.token,
      patientName: item.patientName,
      serviceName: item.serviceName.isEmpty ? 'Consultation' : item.serviceName,
      doctorName: item.doctorName.isEmpty ? 'Attending Doctor' : item.doctorName,
      dateLabel: label,
      dateRaw: iso,
      method: 'Walk-In Queue',
      status: status,
      grossAmount: charge,
      refundAmount: status == 'refunded' ? charge : 0,
      netAmount: status == 'paid' ? charge : 0,
    );
  }
}
