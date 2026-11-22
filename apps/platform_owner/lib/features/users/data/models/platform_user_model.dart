import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/platform_user_entity.dart';

class PlatformUserModel extends PlatformUserEntity {
  const PlatformUserModel({
    required super.id,
    required super.name,
    required super.initials,
    required super.email,
    required super.phone,
    required super.healthId,
    super.bloodGroup,
    super.photoBase64,
    super.homeClinicId,
    super.homeClinicName,
    super.activeQueueToken,
    super.activeQueueStatus,
    super.memberSince,
    super.totalBookings,
    super.isVerified,
    super.status,
    super.createdAt,
  });

  factory PlatformUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? clinicName,
    String? tokenCode,
    String? tokenStatus,
    int? totalBookings,
  }) {
    final data = doc.data() ?? {};
    final rawName = (data['name'] ?? data['fullName'] ?? '').toString().trim();
    final name = rawName.isNotEmpty ? rawName : 'Patient User';

    String initials = '';
    final parts = name.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isNotEmpty) {
      if (parts.length > 1) {
        initials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      } else {
        initials = parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    final rawDate = data['createdAt'];
    DateTime? createdAt;
    if (rawDate is Timestamp) {
      createdAt = rawDate.toDate();
    } else if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate);
    }

    final memberSince = data['memberSince'] as String? ??
        (createdAt != null
            ? '${_monthName(createdAt.month)} ${createdAt.year}'
            : 'Jan 2026');

    final bool isVerified = data['isVerified'] as bool? ??
        (data['phone'] != null && data['phone'].toString().trim().isNotEmpty);

    var status = 'active';
    if (tokenCode != null && tokenCode.isNotEmpty) {
      status = 'in-queue';
    } else if (data['status'] != null) {
      status = data['status'].toString();
    }

    return PlatformUserModel(
      id: doc.id,
      name: name,
      initials: initials,
      email: (data['email'] ?? '').toString(),
      phone: (data['phone'] ?? data['phoneNumber'] ?? '').toString(),
      healthId: (data['healthId'] ??
              'QF-${doc.id.substring(0, doc.id.length >= 6 ? 6 : doc.id.length).toUpperCase()}')
          .toString(),
      bloodGroup: data['bloodGroup'] as String?,
      photoBase64: data['photoBase64'] as String?,
      homeClinicId: (data['clinicId'] ?? data['homeClinicId'] ?? '').toString(),
      homeClinicName: clinicName ??
          (data['clinicName'] ?? data['homeClinicName'] ?? 'Sunrise Health Clinic')
              .toString(),
      activeQueueToken: tokenCode,
      activeQueueStatus: tokenStatus,
      memberSince: memberSince,
      totalBookings: totalBookings ?? (data['visitsCount'] as int? ?? 0),
      isVerified: isVerified,
      status: status,
      createdAt: createdAt,
    );
  }

  static String _monthName(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? m[month - 1] : 'Jan';
  }
}
