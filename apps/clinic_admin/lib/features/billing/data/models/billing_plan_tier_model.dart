import '../../domain/entities/billing_plan_tier_entity.dart';

class BillingPlanTierModel extends BillingPlanTierEntity {
  const BillingPlanTierModel({
    required super.id,
    required super.name,
    required super.tagline,
    required super.monthlyPrice,
    required super.annualPrice,
    super.badge,
    super.isPopular,
    super.doctorLimit,
    super.serviceLimit,
    super.staffLimit,
    super.description,
    super.features,
  });

  factory BillingPlanTierModel.fromMap(String id, Map<String, dynamic> data) {
    return BillingPlanTierModel(
      id: id,
      name: data['name'] as String? ?? 'Custom Plan',
      tagline: data['tagline'] as String? ?? '',
      monthlyPrice: (data['monthlyPrice'] as num?)?.toInt() ?? 999,
      annualPrice: (data['annualPrice'] as num?)?.toInt() ?? 799,
      badge: data['badge'] as String? ?? '',
      isPopular: data['isPopular'] as bool? ?? false,
      doctorLimit: (data['doctorLimit'] as num?)?.toInt() ?? 1,
      serviceLimit: (data['serviceLimit'] as num?)?.toInt() ?? 1,
      staffLimit: (data['staffLimit'] as num?)?.toInt() ?? 1,
      description: data['description'] as String? ?? '',
      features: (data['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tagline': tagline,
      'monthlyPrice': monthlyPrice,
      'annualPrice': annualPrice,
      'badge': badge,
      'isPopular': isPopular,
      'doctorLimit': doctorLimit,
      'serviceLimit': serviceLimit,
      'staffLimit': staffLimit,
      'description': description,
      'features': features,
    };
  }
}
