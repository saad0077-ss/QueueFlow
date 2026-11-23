import 'package:equatable/equatable.dart';

class ClinicRankingEntity extends Equatable {
  final int rank;
  final String id;
  final String name;
  final String initials;
  final int colorHex;
  final double rating;
  final int avgWaitMinutes;
  final int appointments;
  final double sharePercentage;
  final int barWidthPercentage;
  final String tierPlan;

  const ClinicRankingEntity({
    required this.rank,
    required this.id,
    required this.name,
    required this.initials,
    required this.colorHex,
    required this.rating,
    required this.avgWaitMinutes,
    required this.appointments,
    required this.sharePercentage,
    required this.barWidthPercentage,
    required this.tierPlan,
  });

  @override
  List<Object?> get props => [
    rank,
    id,
    name,
    initials,
    colorHex,
    rating,
    avgWaitMinutes,
    appointments,
    sharePercentage,
    barWidthPercentage,
    tierPlan,
  ];
}
