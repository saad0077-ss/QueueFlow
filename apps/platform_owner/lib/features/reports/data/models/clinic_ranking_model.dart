import '../../domain/entities/clinic_ranking_entity.dart';

class ClinicRankingModel extends ClinicRankingEntity {
  const ClinicRankingModel({
    required super.rank,
    required super.id,
    required super.name,
    required super.initials,
    required super.colorHex,
    required super.rating,
    required super.avgWaitMinutes,
    required super.appointments,
    required super.sharePercentage,
    required super.barWidthPercentage,
    required super.tierPlan,
  });

  factory ClinicRankingModel.fromMap(Map<String, dynamic> map, int rank) {
    return ClinicRankingModel(
      rank: rank,
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unnamed Clinic',
      initials: map['initials'] as String? ?? 'CL',
      colorHex: (map['colorHex'] as num?)?.toInt() ?? 0xFF0284C7,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      avgWaitMinutes: (map['avgWaitMinutes'] as num?)?.toInt() ?? 12,
      appointments: (map['appointments'] as num?)?.toInt() ?? 0,
      sharePercentage: (map['sharePercentage'] as num?)?.toDouble() ?? 0.0,
      barWidthPercentage: (map['barWidthPercentage'] as num?)?.toInt() ?? 10,
      tierPlan: map['tierPlan'] as String? ?? 'multi',
    );
  }
}
