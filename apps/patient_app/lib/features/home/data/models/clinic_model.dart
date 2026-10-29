import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_entity.dart';

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
    super.imageVersion = 0,
    super.departmentIds = const [],
    super.departments = const [],
  });

  factory ClinicModel.fromFirestore(DocumentSnapshot doc) {
    final map = (doc.data() as Map<String, dynamic>?) ?? {};
    final name = (map['name'] ?? 'Clinic').toString().trim();

    String initials = 'CL';
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    final rawDepts = (map['departments'] as List<dynamic>?) ?? [];
    final depts = rawDepts.map((e) => e.toString()).toList();
    final rawDeptIds = (map['departmentIds'] as List<dynamic>?) ?? [];
    final deptIds = rawDeptIds.map((e) => e.toString()).toList();

    String category = (map['category'] ?? '').toString().trim();
    if (category.isEmpty) category = depts.isNotEmpty ? depts.join(', ') : 'General Medicine';

    final statusStr = (map['status'] ?? 'ACTIVE').toString().toUpperCase();
    final queueStatusStr = (map['queueStatus'] ?? '').toString();
    final bool isOpen = (statusStr == 'ACTIVE' || statusStr == 'OPEN') &&
        !statusStr.contains('CLOSED') &&
        !statusStr.contains('SUSPENDED');

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

    int waiting = (map['waitingCount'] as num?)?.toInt() ?? 0;
    if (waiting == 0 && queueStatusStr.isNotEmpty) {
      final match = RegExp(r'(\d+)\s+in\s+line', caseSensitive: false).firstMatch(queueStatusStr);
      if (match != null) waiting = int.tryParse(match.group(1) ?? '0') ?? 0;
    }

    // Kept in sync from the reviews collection whenever a patient posts a review.
    final ratingVal = (map['rating'] as num?)?.toDouble() ?? 0;
    final reviews = (map['reviewCount'] as num?)?.toInt() ?? 0;

    return ClinicModel(
      id: doc.id,
      name: name,
      initials: (map['initials'] != null && map['initials'].toString().isNotEmpty) ? map['initials'].toString() : initials,
      category: category,
      rating: reviews > 0 ? ratingVal.clamp(0, 5).toDouble() : 0,
      reviewCount: reviews < 0 ? 0 : reviews,
      distance: (map['distance'] ?? '1.2 km').toString(),
      city: (map['city'] ?? 'Kochi').toString(),
      address: _parseAddress(map),
      phone: (map['phone'] ?? '+91 484 987 6543').toString(),
      consultationFee: (map['consultationFee'] ?? '₹500').toString(),
      openingHours: _parseHours(map),
      isOpen: isOpen,
      isQueueOpen: isQueueOpen,
      currentToken: (map['servingToken'] ?? map['currentToken'] ?? 'A-001').toString(),
      waitingCount: waiting,
      imageUrl: map['imageUrl'] as String? ?? map['image'] as String?,
      imageVersion: (map['imageVersion'] as num?)?.toInt() ?? 0,
      departmentIds: deptIds,
      departments: depts,
    );
  }

  static String _parseAddress(Map<String, dynamic> m) {
    if (m['address'] is String && (m['address'] as String).isNotEmpty) return m['address'] as String;
    if (m['location'] is Map) {
      final loc = m['location'] as Map;
      final parts = [loc['building'], loc['street'], loc['city']].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.join(', ');
    }
    return 'Main Road, Kerala';
  }

  static String _parseHours(Map<String, dynamic> m) {
    if (m['scheduleSummary'] is String && (m['scheduleSummary'] as String).isNotEmpty) return m['scheduleSummary'] as String;
    if (m['openingHours'] is String && (m['openingHours'] as String).isNotEmpty) return m['openingHours'] as String;
    final raw = m['operatingHours'];
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is Map) {
      final mon = raw['monday'];
      final sat = raw['saturday'];
      final sun = raw['sunday'];
      final monOpen = mon is Map && mon['isOpen'] == true;
      final satOpen = sat is Map && sat['isOpen'] == true;
      final sunOpen = sun is Map && sun['isOpen'] == true;
      final monStr = monOpen ? '${mon['openTime']} – ${mon['closeTime']}' : 'Closed';
      if (monOpen && satOpen && !sunOpen) return 'Mon–Sat: $monStr · Sun: Closed';
      if (monOpen && !satOpen && !sunOpen) return 'Mon–Fri: $monStr · Sun: Closed';
      return 'Standard OPD Schedule';
    }
    return 'Mon–Sat, 09:00 AM – 08:00 PM';
  }
}
