import 'package:equatable/equatable.dart';

import 'clinic_ranking_entity.dart';

class PlatformReportEntity extends Equatable {
  final int totalPatients;
  final double patientsGrowthPercentage;
  final int connectedClinics;
  final double avgWaitMinutes;
  final double waitReductionMinutes;
  final double completionRatePercentage;
  final int activeDoctors;
  final int totalDoctorSlots;
  final int mrrAmount;
  final double mrrGrowthPercentage;
  final List<ClinicRankingEntity> rankedClinics;
  final int unlimitedTierCount;
  final int multiTierCount;
  final int soloTierCount;

  const PlatformReportEntity({
    required this.totalPatients,
    required this.patientsGrowthPercentage,
    required this.connectedClinics,
    required this.avgWaitMinutes,
    required this.waitReductionMinutes,
    required this.completionRatePercentage,
    required this.activeDoctors,
    required this.totalDoctorSlots,
    required this.mrrAmount,
    required this.mrrGrowthPercentage,
    required this.rankedClinics,
    required this.unlimitedTierCount,
    required this.multiTierCount,
    required this.soloTierCount,
  });

  @override
  List<Object?> get props => [
    totalPatients,
    patientsGrowthPercentage,
    connectedClinics,
    avgWaitMinutes,
    waitReductionMinutes,
    completionRatePercentage,
    activeDoctors,
    totalDoctorSlots,
    mrrAmount,
    mrrGrowthPercentage,
    rankedClinics,
    unlimitedTierCount,
    multiTierCount,
    soloTierCount,
  ];
}
