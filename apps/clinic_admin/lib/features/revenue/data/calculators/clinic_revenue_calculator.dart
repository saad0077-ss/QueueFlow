import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../../queue/domain/entities/clinic_queue_item_entity.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../domain/entities/clinic_revenue_summary.dart';
import 'clinic_revenue_accumulator.dart';
import 'clinic_revenue_breakdown_builder.dart';
import 'clinic_revenue_trend_helper.dart';

/// Computes real-time financial totals across booked Razorpay appointments and
/// deduplicated walk-in live queue patients.
class ClinicRevenueCalculator {
  ClinicRevenueCalculator._();

  static ClinicRevenueSummary compute({
    required String clinicName,
    required ClinicRevenuePeriod period,
    required List<ClinicAppointmentEntity> appointments,
    required List<ClinicServiceEntity> services,
    List<ClinicQueueItemEntity> queueItems = const [],
    DateTime? anchor,
  }) {
    final acc = ClinicRevenueAccumulator(
      priceMap: {
        for (final s in services) s.name.trim().toLowerCase(): s.price.toDouble(),
      },
      period: period,
      anchor: anchor,
    );

    final apptIds = appointments.map((a) => a.id).toSet();
    final apptRefs = appointments
        .map((a) => a.bookingId)
        .where((b) => b.isNotEmpty)
        .toSet();

    for (final a in appointments) {
      acc.addAppointment(a);
    }
    for (final q in queueItems) {
      if (apptIds.contains(q.id) || apptRefs.contains(q.token)) continue;
      acc.addQueueItem(q);
    }

    acc.ledger.sort((a, b) => b.dateRaw.compareTo(a.dateRaw));

    return ClinicRevenueSummary(
      clinicName: clinicName,
      period: period,
      netRevenue: (acc.gross - acc.refunded).clamp(0.0, acc.gross),
      grossCollected: acc.gross,
      pendingCollections: acc.pending,
      refundedTotal: acc.refunded,
      razorpayRevenue: acc.razorpay,
      walkInQueueRevenue: acc.walkIn,
      razorpayCount: acc.razorpayCount,
      walkInQueueCount: acc.walkInCount,
      avgTicketValue: acc.paidCount > 0 ? acc.gross / acc.paidCount : 0.0,
      paidCount: acc.paidCount,
      pendingCount: acc.pendingCount,
      refundedCount: acc.refundedCount,
      trendPoints: ClinicRevenueTrendHelper.buildTrend(
        items: acc.trendItems,
        period: period,
        anchor: anchor,
      ),
      channelStats: ClinicRevenueBreakdownBuilder.buildChannels(
        razorpayRevenue: acc.razorpay,
        razorpayCount: acc.razorpayCount,
        walkInQueueRevenue: acc.walkIn,
        walkInQueueCount: acc.walkInCount,
      ),
      serviceBreakdown:
          ClinicRevenueBreakdownBuilder.buildServices(acc.svcTotals, acc.gross),
      doctorLeaderboard: ClinicRevenueBreakdownBuilder.buildDoctors(acc.docTotals),
      recentTransactions: acc.ledger,
    );
  }
}
