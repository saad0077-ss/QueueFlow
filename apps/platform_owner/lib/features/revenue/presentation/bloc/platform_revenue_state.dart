import 'package:equatable/equatable.dart';

class PlatformRevenueState extends Equatable {
  final String timeframe;
  final bool isLoading;
  final String grossRevenue;
  final String mrrAmount;
  final String arrAmount;
  final String arpuAmount;
  final int activeClinicsCount;
  final List<Map<String, dynamic>> clinicRevenueItems;
  final List<Map<String, dynamic>> recentInvoices;
  final String totalMrr;
  final String enterpriseAmount;
  final String enterpriseCount;
  final String multiAmount;
  final String multiCount;
  final String soloAmount;
  final String soloCount;

  const PlatformRevenueState({
    this.timeframe = 'current_month',
    this.isLoading = false,
    this.grossRevenue = '₹0',
    this.mrrAmount = '₹0',
    this.arrAmount = '₹0',
    this.arpuAmount = '₹0',
    this.activeClinicsCount = 0,
    this.clinicRevenueItems = const [],
    this.recentInvoices = const [],
    this.totalMrr = '₹0 / mo',
    this.enterpriseAmount = '₹0/mo',
    this.enterpriseCount = '0 Clinics (0.0%)',
    this.multiAmount = '₹0/mo',
    this.multiCount = '0 Clinics (0.0%)',
    this.soloAmount = '₹0/mo',
    this.soloCount = '0 Clinics (0.0%)',
  });

  PlatformRevenueState copyWith({
    String? timeframe,
    bool? isLoading,
    String? grossRevenue,
    String? mrrAmount,
    String? arrAmount,
    String? arpuAmount,
    int? activeClinicsCount,
    List<Map<String, dynamic>>? clinicRevenueItems,
    List<Map<String, dynamic>>? recentInvoices,
    String? totalMrr,
    String? enterpriseAmount,
    String? enterpriseCount,
    String? multiAmount,
    String? multiCount,
    String? soloAmount,
    String? soloCount,
  }) {
    return PlatformRevenueState(
      timeframe: timeframe ?? this.timeframe,
      isLoading: isLoading ?? this.isLoading,
      grossRevenue: grossRevenue ?? this.grossRevenue,
      mrrAmount: mrrAmount ?? this.mrrAmount,
      arrAmount: arrAmount ?? this.arrAmount,
      arpuAmount: arpuAmount ?? this.arpuAmount,
      activeClinicsCount: activeClinicsCount ?? this.activeClinicsCount,
      clinicRevenueItems: clinicRevenueItems ?? this.clinicRevenueItems,
      recentInvoices: recentInvoices ?? this.recentInvoices,
      totalMrr: totalMrr ?? this.totalMrr,
      enterpriseAmount: enterpriseAmount ?? this.enterpriseAmount,
      enterpriseCount: enterpriseCount ?? this.enterpriseCount,
      multiAmount: multiAmount ?? this.multiAmount,
      multiCount: multiCount ?? this.multiCount,
      soloAmount: soloAmount ?? this.soloAmount,
      soloCount: soloCount ?? this.soloCount,
    );
  }

  @override
  List<Object?> get props => [
    timeframe,
    isLoading,
    grossRevenue,
    mrrAmount,
    arrAmount,
    arpuAmount,
    activeClinicsCount,
    clinicRevenueItems,
    recentInvoices,
    totalMrr,
    enterpriseAmount,
    enterpriseCount,
    multiAmount,
    multiCount,
    soloAmount,
    soloCount,
  ];
}
