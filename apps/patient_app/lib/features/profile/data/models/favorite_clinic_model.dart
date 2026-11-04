import '../../domain/entities/favorite_clinic_entity.dart';

class FavoriteClinicModel extends FavoriteClinicEntity {
  const FavoriteClinicModel({
    required super.id,
    required super.name,
    required super.department,
    required super.rating,
    required super.reviewsCount,
    required super.address,
    required super.initials,
    super.accentColorHex,
  });

  factory FavoriteClinicModel.fromJson(Map<String, dynamic> json) {
    return FavoriteClinicModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      department: json['department'] as String? ?? 'General Medicine',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.9,
      reviewsCount: json['reviewsCount'] as int? ?? 120,
      address: json['address'] as String? ?? '',
      initials: json['initials'] as String? ?? (json['name'] != null && (json['name'] as String).isNotEmpty ? (json['name'] as String)[0] : 'C'),
      accentColorHex: json['accentColorHex'] as int? ?? 0xFF2563EB,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'address': address,
      'initials': initials,
      'accentColorHex': accentColorHex,
    };
  }

  static List<FavoriteClinicModel> get defaultFavorites => const [];
}
