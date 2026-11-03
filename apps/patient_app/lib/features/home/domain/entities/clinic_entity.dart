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
  /// Bumped on every photo upload; 0 when the clinic has no photo in `clinic_images`.
  final int imageVersion;
  final List<String> departmentIds;
  final List<String> departments;

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
    this.imageVersion = 0,
    this.departmentIds = const [],
    this.departments = const [],
  });

  /// True when at least one patient has rated this clinic.
  bool get hasRatings => reviewCount > 0;

  /// Copy with a recomputed rating summary.
  ClinicEntity withRating({required double rating, required int reviewCount}) {
    return ClinicEntity(
      id: id,
      name: name,
      initials: initials,
      category: category,
      rating: rating,
      reviewCount: reviewCount,
      distance: distance,
      city: city,
      address: address,
      phone: phone,
      consultationFee: consultationFee,
      openingHours: openingHours,
      isOpen: isOpen,
      isQueueOpen: isQueueOpen,
      currentToken: currentToken,
      waitingCount: waitingCount,
      imageUrl: imageUrl,
      imageVersion: imageVersion,
      departmentIds: departmentIds,
      departments: departments,
    );
  }

  /// True ONLY if a live queue is open AND there is an active queue present
  bool get hasLiveQueue => isQueueOpen && waitingCount > 0;

  List<String> get departmentList {
    if (departments.isNotEmpty) return departments;
    if (category.contains(',')) {
      return category
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [category];
  }

  String get primaryCategory {
    final list = departmentList;
    return list.isNotEmpty ? list.first : category;
  }

  bool get hasMultipleDepartments => departmentList.length >= 2;
  int get departmentCount => departmentList.length;

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
        imageVersion,
        departmentIds,
        departments,
      ];
}
