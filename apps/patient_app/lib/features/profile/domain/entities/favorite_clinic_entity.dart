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
  final String distance;
  final int waitingCount;
  final String estWaitTime;
  final String openHours;
  final String topDoctor;
  final String phone;
  final String iconEmoji;

  const FavoriteClinicEntity({
    required this.id,
    required this.name,
    required this.department,
    required this.rating,
    required this.reviewsCount,
    required this.address,
    required this.initials,
    this.accentColorHex = 0xFF2563EB,
    this.distance = '1.2 km',
    this.waitingCount = 3,
    this.estWaitTime = '15 min',
    this.openHours = 'Open 09:00 AM – 08:00 PM',
    this.topDoctor = 'Dr. Priya Sharma',
    this.phone = '+91 98450 11234',
    this.iconEmoji = '🏥',
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
    distance,
    waitingCount,
    estWaitTime,
    openHours,
    topDoctor,
    phone,
    iconEmoji,
  ];
}
