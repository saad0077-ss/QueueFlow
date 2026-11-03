import 'package:equatable/equatable.dart';

class PlatformPlanTierEntity extends Equatable {
  final String id;
  final String name;
  final String tagline;
  final int monthlyPrice;
  final int annualPrice;
  final String badge;
  final bool isPopular;
  final int doctorLimit;
  final int serviceLimit;
  final int staffLimit;
  final String description;
  final List<String> features;

  const PlatformPlanTierEntity({
    required this.id,
    required this.name,
    required this.tagline,
    required this.monthlyPrice,
    required this.annualPrice,
    this.badge = '',
    this.isPopular = false,
    this.doctorLimit = 1,
    this.serviceLimit = 1,
    this.staffLimit = 1,
    this.description = '',
    this.features = const [],
  });

  bool get isUnlimited => doctorLimit >= 999;

  @override
  List<Object?> get props => [
    id,
    name,
    tagline,
    monthlyPrice,
    annualPrice,
    badge,
    isPopular,
    doctorLimit,
    serviceLimit,
    staffLimit,
    description,
    features,
  ];
}
