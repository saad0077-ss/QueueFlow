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
  final String? imageUrl;
  final int imageVersion;
  final String topDoctorPhotoUrl;

  const FavoriteClinicEntity({
    required this.id,
    required this.name,
    required this.department,
    required this.rating,
    required this.reviewsCount,
    required this.address,
    required this.initials,
    this.accentColorHex = 0xFF2563EB,
    this.distance = '',
    this.waitingCount = 0,
    this.estWaitTime = '',
    this.openHours = '',
    this.topDoctor = '',
    this.phone = '',
    this.iconEmoji = '🏥',
    this.imageUrl,
    this.imageVersion = 0,
    this.topDoctorPhotoUrl = '',
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
    imageUrl,
    imageVersion,
    topDoctorPhotoUrl,
  ];
}
