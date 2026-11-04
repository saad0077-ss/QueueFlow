import 'package:equatable/equatable.dart';

class FavoriteClinicEntity extends Equatable {
  final String id;
  final String name;
  final String department;
  final double rating;
  final int reviewsCount;
  final String address;
  final String initials;
  final int accentColorHex;

  const FavoriteClinicEntity({
    required this.id,
    required this.name,
    required this.department,
    required this.rating,
    required this.reviewsCount,
    required this.address,
    required this.initials,
    this.accentColorHex = 0xFF2563EB,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        department,
        rating,
        reviewsCount,
        address,
        initials,
        accentColorHex,
      ];
}
