import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_entity.dart';

/// Clinic data model extending the domain entity ClinicEntity.
class ClinicModel extends ClinicEntity {
  const ClinicModel({
    required super.id,
    required super.name,
    required super.initials,
    required super.category,
    required super.rating,
    required super.reviewCount,
    required super.distance,
    required super.city,
    required super.address,
    required super.phone,
    required super.consultationFee,
    required super.openingHours,
    super.isOpen = true,
    super.isQueueOpen = false,
    super.currentToken = 'A-001',
    super.waitingCount = 0,
    super.imageUrl,
  });

  /// Factory creating ClinicModel directly from a live Firestore DocumentSnapshot.
  factory ClinicModel.fromFirestore(DocumentSnapshot doc) {
    final map = (doc.data() as Map<String, dynamic>?) ?? {};
    final name = (map['name'] ?? 'Clinic').toString().trim();

    // Extract clean initials (up to 2 letters)
    String initials = 'CL';
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    final rawDepts = (map['departments'] as List<dynamic>?) ?? [];
    final depts = rawDepts.map((e) => e.toString()).toList();

    String category = (map['category'] ?? '').toString().trim();
    if (category.isEmpty) {
      if (depts.isNotEmpty) {
        category = depts.join(', ');
      } else {
        category = 'General Medicine';
      }
    }

    final statusStr = (map['status'] ?? 'ACTIVE').toString().toUpperCase();
    final queueStatusStr = (map['queueStatus'] ?? '').toString();

    // Check if clinic is open
    final bool isOpen = (statusStr == 'ACTIVE' || statusStr == 'OPEN') &&
        !statusStr.contains('CLOSED') &&
        !statusStr.contains('SUSPENDED');

    // Live queue is open ONLY if explicitly configured or queueStatus specifies it
    bool isQueueOpen = false;
    if (map['isQueueOpen'] is bool) {
      isQueueOpen = map['isQueueOpen'] as bool;
    } else if (map['hasLiveQueue'] is bool) {
      isQueueOpen = map['hasLiveQueue'] as bool;
    } else if (queueStatusStr.isNotEmpty) {
      final qLower = queueStatusStr.toLowerCase();
      isQueueOpen = qLower.contains('queue open') ||
          (qLower.contains('open') && !qLower.contains('closed') && !qLower.contains('paused'));
    }

    // Waiting count from queueStatus (e.g. "Queue Open (2 in line)") or numeric field
    int waiting = (map['waitingCount'] as num?)?.toInt() ?? 0;
    if (waiting == 0 && queueStatusStr.isNotEmpty) {
      final match = RegExp(r'(\d+)\s+in\s+line', caseSensitive: false).firstMatch(queueStatusStr);
      if (match != null) {
        waiting = int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }

    final ratingVal = (map['rating'] as num?)?.toDouble() ?? 5.0;
    final reviews = (map['reviewCount'] as num?)?.toInt() ??
        (map['monthlyVisits'] as num?)?.toInt() ??
        24;

    return ClinicModel(
      id: doc.id,
      name: name,
      initials: (map['initials'] != null && map['initials'].toString().isNotEmpty)
          ? map['initials'].toString()
          : initials,
      category: category,
      rating: ratingVal <= 0 ? 5.0 : ratingVal,
      reviewCount: reviews <= 0 ? 12 : reviews,
      distance: (map['distance'] ?? '1.2 km').toString(),
      city: (map['city'] ?? 'Kochi').toString(),
      address: (map['address'] ?? 'Main Road, Kerala').toString(),
      phone: (map['phone'] ?? '+91 484 987 6543').toString(),
      consultationFee: (map['consultationFee'] ?? '₹500').toString(),
      openingHours: (map['operatingHours'] ?? map['openingHours'] ?? 'Mon–Sat, 09:00 AM – 08:00 PM').toString(),
      isOpen: isOpen,
      isQueueOpen: isQueueOpen,
      currentToken: (map['servingToken'] ?? map['currentToken'] ?? 'A-001').toString(),
      waitingCount: waiting,
      imageUrl: map['imageUrl'] as String? ?? map['image'] as String?,
    );
  }

  /// Factory from Map / JSON representation
  factory ClinicModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ClinicModel(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      initials: map['initials'] ?? 'CL',
      category: map['category'] ?? 'General',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 100,
      distance: map['distance'] ?? '1.0 km',
      city: map['city'] ?? 'Kochi',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      consultationFee: map['consultationFee'] ?? '₹500',
      openingHours: map['openingHours'] ?? 'Mon–Sat, 09:00 AM – 08:00 PM',
      isOpen: map['isOpen'] ?? true,
      isQueueOpen: map['isQueueOpen'] ?? false,
      currentToken: map['currentToken'] ?? 'A-001',
      waitingCount: (map['waitingCount'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] ?? map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'initials': initials,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'distance': distance,
      'city': city,
      'address': address,
      'phone': phone,
      'consultationFee': consultationFee,
      'openingHours': openingHours,
      'isOpen': isOpen,
      'isQueueOpen': isQueueOpen,
      'currentToken': currentToken,
      'waitingCount': waitingCount,
      'imageUrl': imageUrl,
    };
  }
}
