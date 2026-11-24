import 'package:equatable/equatable.dart';

/// Performance, utilization and revenue metric for a clinical service.
class ServiceRevenueMetric extends Equatable {
  final String serviceId;
  final String serviceName;
  final String icon;
  final double fee;
  final int visits;
  final double sharePercentage;
  final double revenue;

  const ServiceRevenueMetric({
    required this.serviceId,
    required this.serviceName,
    required this.icon,
    required this.fee,
    required this.visits,
    required this.sharePercentage,
    required this.revenue,
  });

  @override
  List<Object?> get props => [
    serviceId,
    serviceName,
    icon,
    fee,
    visits,
    sharePercentage,
    revenue,
  ];
}
