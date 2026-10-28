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
  final bool isQueueOpen;
  final String currentToken;
  final int waitingCount;
  final String? imageUrl;

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
    this.isQueueOpen = false,
    this.currentToken = 'A-001',
    this.waitingCount = 0,
    this.imageUrl,
  });

  /// True ONLY if a live queue is open AND there is an active queue present
  bool get hasLiveQueue => isQueueOpen && waitingCount > 0;

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
        isQueueOpen,
        currentToken,
        waitingCount,
        imageUrl,
      ];
}
