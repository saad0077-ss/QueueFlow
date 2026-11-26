import 'package:equatable/equatable.dart';
import 'clinic_revenue_breakdown.dart';

/// Timeframes supported by the Clinic Revenue analytics view.
enum ClinicRevenuePeriod {
  today('Today', 'Today'),
  week('7 Days', '7D'),
  month('30 Days', '30D'),
  quarter('90 Days', '90D'),
  all('All Time', 'All');

  final String label;
  final String shortLabel;

  const ClinicRevenuePeriod(this.label, this.shortLabel);
}

/// Aggregated clinic financial & settlement snapshot for a reporting period.
class ClinicRevenueSummary extends Equatable {
  final String clinicName;
  final ClinicRevenuePeriod period;
  final double netRevenue;
  final double grossCollected;
  final double pendingCollections;
  final double refundedTotal;
  final double razorpayRevenue;
  final double walkInQueueRevenue;
  final int razorpayCount;
  final int walkInQueueCount;
  final double avgTicketValue;
  final int paidCount;
  final int pendingCount;
  final int refundedCount;
  final List<DailyRevenuePoint> trendPoints;
  final List<RevenueChannelStat> channelStats;
  final List<RevenueServiceStat> serviceBreakdown;
  final List<RevenueDoctorStat> doctorLeaderboard;
  final List<RevenueLedgerEntry> recentTransactions;

  const ClinicRevenueSummary({
    required this.clinicName,
    required this.period,
    required this.netRevenue,
    required this.grossCollected,
    required this.pendingCollections,
    required this.refundedTotal,
    required this.razorpayRevenue,
    required this.walkInQueueRevenue,
    required this.razorpayCount,
    required this.walkInQueueCount,
    required this.avgTicketValue,
    required this.paidCount,
    required this.pendingCount,
    required this.refundedCount,
    required this.trendPoints,
    required this.channelStats,
    required this.serviceBreakdown,
    required this.doctorLeaderboard,
    required this.recentTransactions,
  });

  /// Collection efficiency against billable (collected + pending) charges.
  double get collectionRate {
    final billable = grossCollected + pendingCollections;
    return billable > 0 ? (grossCollected / billable) * 100 : 0.0;
  }

  @override
  List<Object?> get props => [
    clinicName,
    period,
    netRevenue,
    grossCollected,
    pendingCollections,
    refundedTotal,
    razorpayRevenue,
    walkInQueueRevenue,
    razorpayCount,
    walkInQueueCount,
    avgTicketValue,
    paidCount,
    pendingCount,
    refundedCount,
    trendPoints,
    channelStats,
    serviceBreakdown,
    doctorLeaderboard,
    recentTransactions,
  ];
}
