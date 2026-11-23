import 'package:equatable/equatable.dart';

class PlatformRevenueEntity extends Equatable {
  final int mrr;
  final int arr;
  final int grossRevenue;
  final int arpu;
  final int activeClinicsCount;
  final int enterpriseCount;
  final int enterpriseMrr;
  final int multiCount;
  final int multiMrr;
  final int soloCount;
  final int soloMrr;
  final List<Map<String, dynamic>> clinicRevenueItems;
  final List<Map<String, dynamic>> recentInvoices;

  const PlatformRevenueEntity({
    required this.mrr,
    required this.arr,
    required this.grossRevenue,
    required this.arpu,
    required this.activeClinicsCount,
    required this.enterpriseCount,
    required this.enterpriseMrr,
    required this.multiCount,
    required this.multiMrr,
    required this.soloCount,
    required this.soloMrr,
    required this.clinicRevenueItems,
    required this.recentInvoices,
  });

  @override
  List<Object?> get props => [
    mrr,
    arr,
    grossRevenue,
    arpu,
    activeClinicsCount,
    enterpriseCount,
    enterpriseMrr,
    multiCount,
    multiMrr,
    soloCount,
    soloMrr,
    clinicRevenueItems,
    recentInvoices,
  ];
}
