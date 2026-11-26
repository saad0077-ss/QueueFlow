import 'package:equatable/equatable.dart';

import '../../../../core/services/user_location_service.dart';

class ClinicEntity extends Equatable {
  final String id;
  final String name;
  final String initials;
  final String category;
  final double rating;
  final int reviewCount;
  final String distance;

  /// Clinic GPS coordinates saved by the clinic admin (null when not set).
  final double? latitude;
  final double? longitude;
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

  /// Weekly schedule set by the clinic admin: `{monday: {isOpen, openTime, closeTime}, ...}`.
  final Map<String, dynamic> schedule;

  const ClinicEntity({
    required this.id,
    required this.name,
    required this.initials,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    this.latitude,
    this.longitude,
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
    this.schedule = const {},
  });

  /// Open right now: the clinic is active AND the current time falls inside
  /// today's operating hours set by the clinic admin. Without saved
  /// operating hours the clinic shows as closed.
  bool get isOpenNow => isOpenAt(DateTime.now());

  bool isOpenAt(DateTime now) {
    if (!isOpen) return false;
    // Fall back to openingHours if structured weekly schedule is empty.
    if (schedule.isEmpty) {
      if (openingHours.isNotEmpty) {
        final match = RegExp(
          r'(\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)?)\s*[-–—]\s*(\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)?)',
        ).firstMatch(openingHours);
        if (match != null) {
          final open = _minutes(match.group(1));
          final close = _minutes(match.group(2));
          if (open != null && close != null) {
            final cur = now.hour * 60 + now.minute;
            return close > open
                ? (cur >= open && cur < close)
                : (cur >= open || cur < close);
          }
        }
      }
      return false;
    }
    const keys = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final day = schedule[keys[now.weekday - 1]];
    if (day is! Map || day['isOpen'] != true) return false;
    final open = _minutes(day['openTime']);
    final close = _minutes(day['closeTime']);
    if (open == null || close == null) return false;
    final cur = now.hour * 60 + now.minute;
    return close > open
        ? (cur >= open && cur < close)
        : (cur >= open || cur < close);
  }

  /// When the clinic is inside today's configured break (e.g. lunch), returns
  /// the time the break ends ("14:00"); otherwise null.
  String? breakEndsAt(DateTime now) {
    const keys = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final day = schedule[keys[now.weekday - 1]];
    if (day is! Map || day['isOpen'] != true || day['hasBreak'] != true) {
      return null;
    }
    final start = _minutes(day['breakStart']);
    final end = _minutes(day['breakEnd']);
    if (start == null || end == null || end <= start) return null;
    final cur = now.hour * 60 + now.minute;
    if (cur >= start && cur < end) return day['breakEnd'].toString();
    return null;
  }

  static int? _minutes(dynamic v) {
    final m = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*([AaPp][Mm])?\s*$')
        .firstMatch('$v');
    if (m == null) return null;
    var h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final ap = m.group(3)?.toLowerCase();
    if (ap == 'pm' && h < 12) h += 12;
    if (ap == 'am' && h == 12) h = 0;
    return h * 60 + min;
  }

  /// Real distance from the patient's current position, e.g. "850 m" or
  /// "3.4 km". Empty until both the clinic GPS and the patient position are known.
  String get distanceLabel =>
      UserLocationService.distanceLabel(latitude, longitude);

  /// Distance in km, or null when unknown.
  double? get distanceKm => UserLocationService.distanceKm(latitude, longitude);

  /// True when at least one patient has rated this clinic.
  bool get hasRatings => reviewCount > 0 && rating > 0;

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
      latitude: latitude,
      longitude: longitude,
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
      schedule: schedule,
    );
  }

  /// True ONLY if the clinic is within operating hours, a live queue is open AND there is an active queue present
  bool get hasLiveQueue => isOpenNow && isQueueOpen && waitingCount > 0;

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
    latitude,
    longitude,
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
    schedule,
  ];
}
