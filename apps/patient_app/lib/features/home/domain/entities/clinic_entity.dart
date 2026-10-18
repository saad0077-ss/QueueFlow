import 'package:equatable/equatable.dart';

class ClinicEntity extends Equatable {
  final String id;
  final String name;
  final String initials;
  final String category;
  final double rating;
  final int reviewCount;
  final String distance;
  final String city;
  final String address;
  final String phone;
  final String consultationFee;
  final String openingHours;
  final bool isOpen;
  final String currentToken;
  final int waitingCount;

  const ClinicEntity({
    required this.id,
    required this.name,
    required this.initials,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.city,
    required this.address,
    required this.phone,
    required this.consultationFee,
    required this.openingHours,
    this.isOpen = true,
    this.currentToken = 'A-021',
    this.waitingCount = 3,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        initials,
        category,
        rating,
        reviewCount,
        distance,
        city,
        address,
        phone,
        consultationFee,
        openingHours,
        isOpen,
        currentToken,
        waitingCount,
      ];
}
