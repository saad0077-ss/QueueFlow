import 'package:equatable/equatable.dart';

class PlatformBillingKpis extends Equatable {
  final String totalMrr;
  final String mrrTrend;
  final int activeSubscriptions;
  final String retentionRate;
  final int overdueCount;
  final String overdueAmount;
  final String arpu;
  final String churnRate;
  final String collectionRate;

  const PlatformBillingKpis({
    this.totalMrr = '₹2,40,000',
    this.mrrTrend = '↑ 14.2% MoM',
    this.activeSubscriptions = 5,
    this.retentionRate = '100% Retained',
    this.overdueCount = 2,
    this.overdueAmount = '₹16,000 pending',
    this.arpu = '₹8,200',
    this.churnRate = '2.1% Churn',
    this.collectionRate = '94.2% On Time',
  });

  @override
  List<Object?> get props => [
    totalMrr,
    mrrTrend,
    activeSubscriptions,
    retentionRate,
    overdueCount,
    overdueAmount,
    arpu,
    churnRate,
    collectionRate,
  ];
}
