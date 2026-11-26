import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../../queue/domain/entities/clinic_queue_item_entity.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import '../../domain/entities/clinic_revenue_summary.dart';
import 'clinic_revenue_breakdown_builder.dart';
import 'clinic_revenue_trend_helper.dart';

/// Mutable aggregator accumulating appointment & walk-in revenue metrics.
class ClinicRevenueAccumulator {
  final Map<String, double> priceMap;
  final ClinicRevenuePeriod period;
  final DateTime? anchor;

  double gross = 0;
  double pending = 0;
  double refunded = 0;
  double razorpay = 0;
  double walkIn = 0;
  int paidCount = 0;
  int pendingCount = 0;
  int refundedCount = 0;
  int razorpayCount = 0;
  int walkInCount = 0;

  final svcTotals = <String, RevenueAccumulatorBucket>{};
  final docTotals = <String, RevenueAccumulatorBucket>{};
  final ledger = <RevenueLedgerEntry>[];
  final trendItems = <TrendRevenueItem>[];

  ClinicRevenueAccumulator({
    required this.priceMap,
    required this.period,
    this.anchor,
  });

  void addAppointment(ClinicAppointmentEntity a) {
    final date = ClinicRevenueTrendHelper.resolveDate(a, fallback: anchor);
    if (!ClinicRevenueTrendHelper.isDateInPeriod(date, period, anchor: anchor)) {
      return;
    }
    final charge = _apptCharge(a);
    final pay = a.payment;
    final hour = ClinicRevenueTrendHelper.resolveHour(a.timeRaw);

    if (pay.isRefunded) {
      final ref = (pay.refundAmount ?? charge).clamp(0.0, charge);
      final retained = (charge - ref).clamp(0.0, charge);
      refunded += ref;
      refundedCount++;
      trendItems.add(TrendRevenueItem(date: date, hour: hour, netAmount: retained));
      ledger.add(ClinicRevenueBreakdownBuilder.toLedger(
        a, status: 'refunded', gross: charge, refund: ref, net: retained,
      ));
      return;
    }
    if (pay.isVoid || a.status.toLowerCase() == 'cancelled') return;

    if (!pay.isPaid) {
      pending += charge;
      pendingCount++;
      ledger.add(ClinicRevenueBreakdownBuilder.toLedger(
        a, status: 'pending', gross: charge, refund: 0, net: 0,
      ));
      return;
    }

    gross += charge;
    paidCount++;
    if (ClinicRevenueBreakdownBuilder.isWalkInOrCounterPayment(pay)) {
      walkIn += charge;
      walkInCount++;
    } else {
      razorpay += charge;
      razorpayCount++;
    }
    _bucket(svcTotals, a.service.isEmpty ? 'Consultation' : a.service,
        a.departmentName, charge);
    _bucket(docTotals, a.doctor.isEmpty ? 'Attending Doctor' : a.doctor,
        a.doctorRole, charge);
    trendItems.add(TrendRevenueItem(date: date, hour: hour, netAmount: charge));
    ledger.add(ClinicRevenueBreakdownBuilder.toLedger(
      a, status: 'paid', gross: charge, refund: 0, net: charge,
    ));
  }

  void addQueueItem(ClinicQueueItemEntity q) {
    if (q.isCancelled) return;
    if (!ClinicRevenueTrendHelper.isDateInPeriod(q.joinedAt, period, anchor: anchor)) {
      return;
    }
    final charge = q.fee > 0
        ? q.fee
        : (priceMap[q.serviceName.trim().toLowerCase()] ?? 0.0);
    final payState = q.paymentStatus.toLowerCase();

    if (payState == 'refunded') {
      refunded += charge;
      refundedCount++;
      ledger.add(ClinicRevenueBreakdownBuilder.queueToLedger(
        q, status: 'refunded', charge: charge,
      ));
      return;
    }
    if (payState == 'pending' || payState == 'unpaid') {
      pending += charge;
      pendingCount++;
      ledger.add(ClinicRevenueBreakdownBuilder.queueToLedger(
        q, status: 'pending', charge: charge,
      ));
      return;
    }

    gross += charge;
    paidCount++;
    walkIn += charge;
    walkInCount++;
    _bucket(svcTotals, q.serviceName.isEmpty ? 'Consultation' : q.serviceName,
        'Walk-In Queue', charge);
    _bucket(docTotals, q.doctorName.isEmpty ? 'Attending Doctor' : q.doctorName,
        'Walk-In Care', charge);
    trendItems.add(TrendRevenueItem(
      date: q.joinedAt, hour: q.joinedAt.hour, netAmount: charge,
    ));
    ledger.add(ClinicRevenueBreakdownBuilder.queueToLedger(
      q, status: 'paid', charge: charge,
    ));
  }

  double _apptCharge(ClinicAppointmentEntity a) {
    if (a.payment.amount > 0) return a.payment.amount;
    if (a.servicePrice > 0) return a.servicePrice;
    return priceMap[a.service.trim().toLowerCase()] ?? 0.0;
  }

  void _bucket(
    Map<String, RevenueAccumulatorBucket> map,
    String key,
    String sub,
    double amount,
  ) {
    final b = map.putIfAbsent(key, () => RevenueAccumulatorBucket(sub));
    b.count++;
    b.amount += amount;
  }
}
