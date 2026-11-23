import '../../domain/entities/platform_report_entity.dart';
import 'clinic_ranking_model.dart';

class PlatformReportModel extends PlatformReportEntity {
  const PlatformReportModel({
    required super.totalPatients,
    required super.patientsGrowthPercentage,
    required super.connectedClinics,
    required super.avgWaitMinutes,
    required super.waitReductionMinutes,
    required super.completionRatePercentage,
    required super.activeDoctors,
    required super.totalDoctorSlots,
    required super.mrrAmount,
    required super.mrrGrowthPercentage,
    required super.rankedClinics,
    required super.unlimitedTierCount,
    required super.multiTierCount,
    required super.soloTierCount,
  });

  factory PlatformReportModel.fromData({
    required int totalPatients,
    required double avgWaitMinutes,
    required int activeDoctors,
    required int totalDoctorSlots,
    required int mrrAmount,
    required List<ClinicRankingModel> rankedClinics,
    required int unlimitedTierCount,
    required int multiTierCount,
    required int soloTierCount,
  }) {
    return PlatformReportModel(
      totalPatients: totalPatients,
      patientsGrowthPercentage: 18.4,
      connectedClinics: rankedClinics.length,
      avgWaitMinutes: avgWaitMinutes,
      waitReductionMinutes: 3.2,
      completionRatePercentage: 96.4,
      activeDoctors: activeDoctors,
      totalDoctorSlots: totalDoctorSlots,
      mrrAmount: mrrAmount,
      mrrGrowthPercentage: 14.2,
      rankedClinics: rankedClinics,
      unlimitedTierCount: unlimitedTierCount,
      multiTierCount: multiTierCount,
      soloTierCount: soloTierCount,
    );
  }
}
