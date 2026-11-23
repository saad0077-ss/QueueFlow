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
    super.age,
    super.gender,
    super.emergencyContact,
    super.homeClinicId,
    super.homeClinicName,
    super.activeQueueToken,
    super.activeQueueStatus,
    super.activeQueueService,
    super.activeQueueDoctor,
    super.activeQueueJoinedAt,
    super.memberSince,
    super.totalBookings,
    super.totalQueues,
    super.isVerified,
    super.status,
    super.userType,
    super.createdAt,
    super.city,
    super.notes,
    super.lastActive,
  });

  factory PlatformUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? clinicName,
    String? tokenCode,
    String? tokenStatus,
    String? tokenService,
    String? tokenDoctor,
    String? tokenJoinedAt,
    int? totalBookings,
    int? totalQueues,
  }) {
    final data = doc.data() ?? {};
    final rawName = (data['name'] ?? data['fullName'] ?? '').toString().trim();
    final name = rawName.isNotEmpty ? rawName : 'Patient User';

    String initials = '';
    final parts = name
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isNotEmpty) {
      if (parts.length > 1) {
        initials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      } else {
        initials = parts.first
            .substring(0, parts.first.length >= 2 ? 2 : 1)
            .toUpperCase();
      }
    }

    final rawDate =
        data['createdAt'] ?? data['registeredAt'] ?? data['joinedAt'];
    DateTime? createdAt;
    if (rawDate is Timestamp) {
      createdAt = rawDate.toDate();
    } else if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate);
    }

    final String memberSince;
    if (createdAt != null) {
      final hour = createdAt.hour % 12 == 0 ? 12 : createdAt.hour % 12;
      final minute = createdAt.minute.toString().padLeft(2, '0');
      final period = createdAt.hour >= 12 ? 'PM' : 'AM';
      memberSince =
          '${createdAt.day.toString().padLeft(2, '0')} ${_monthName(createdAt.month)} ${createdAt.year}, $hour:$minute $period';
    } else if (data['memberSince'] != null &&
        data['memberSince'].toString().trim().isNotEmpty) {
      memberSince = data['memberSince'].toString();
    } else {
      final now = DateTime.now();
      final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
      final minute = now.minute.toString().padLeft(2, '0');
      final period = now.hour >= 12 ? 'PM' : 'AM';
      memberSince =
          '${now.day.toString().padLeft(2, '0')} ${_monthName(now.month)} ${now.year}, $hour:$minute $period';
    }

    final rawUserType = (data['userType'] ?? data['type'] ?? '')
        .toString()
        .toLowerCase();
    final bool isWalkIn =
        rawUserType == 'walk-in' ||
        (data['isWalkIn'] == true) ||
        name.toLowerCase().contains('walk-in');
    final String userType = isWalkIn ? 'walk-in' : 'platform_user';

    final bool isVerified =
        data['isVerified'] as bool? ??
        (data['phone'] != null && data['phone'].toString().trim().isNotEmpty);

    var rawStatus = (data['status'] ?? 'active').toString().toLowerCase();
    String finalStatus = rawStatus;
    if (rawStatus == 'suspended') {
      finalStatus = 'suspended';
    } else if (tokenCode != null && tokenCode.isNotEmpty) {
      finalStatus = 'in-queue';
    } else if (isVerified) {
      finalStatus = 'active';
    }

    // Emergency contact formatting
    String? emergencyContact;
    if (data['emergencyContact'] is Map) {
      final emMap = data['emergencyContact'] as Map;
      final emName = (emMap['name'] ?? '').toString().trim();
      final emPhone = (emMap['phone'] ?? '').toString().trim();
      if (emName.isNotEmpty || emPhone.isNotEmpty) {
        emergencyContact = emPhone.isNotEmpty ? '$emName ($emPhone)' : emName;
      }
    } else if (data['emergencyContact'] != null &&
        data['emergencyContact'].toString().trim().isNotEmpty) {
      emergencyContact = data['emergencyContact'].toString().trim();
    } else if (data['emergencyContactPhone'] != null ||
        data['emergencyContactName'] != null) {
      final emName = (data['emergencyContactName'] ?? '').toString().trim();
      final emPhone = (data['emergencyContactPhone'] ?? '').toString().trim();
      if (emName.isNotEmpty || emPhone.isNotEmpty) {
        emergencyContact = emPhone.isNotEmpty ? '$emName ($emPhone)' : emName;
      }
    }

    final rawClinicName =
        clinicName ??
        (data['clinicName'] ?? data['homeClinicName'] ?? '').toString().trim();
    final effectiveClinicName = rawClinicName.isNotEmpty
        ? rawClinicName
        : 'Unassigned';

    // Last active formatting
    String? lastActive = data['lastActive']?.toString();
    if (lastActive == null || lastActive.isEmpty) {
      final updatedRaw = data['updatedAt'] ?? data['lastActiveAt'];
      if (updatedRaw is Timestamp) {
        final d = updatedRaw.toDate();
        lastActive = '${d.day} ${_monthName(d.month)} ${d.year}';
      } else if (updatedRaw is String) {
        final d = DateTime.tryParse(updatedRaw);
        if (d != null) {
          lastActive = '${d.day} ${_monthName(d.month)} ${d.year}';
        }
      }
    }

    return PlatformUserModel(
      id: doc.id,
      name: name,
      initials: initials,
      email: (data['email'] ?? '').toString().trim(),
      phone: (data['phone'] ?? data['phoneNumber'] ?? '').toString().trim(),
      healthId:
          (data['healthId'] ??
                  'QF-${doc.id.substring(0, doc.id.length >= 6 ? 6 : doc.id.length).toUpperCase()}')
              .toString(),
      bloodGroup: data['bloodGroup']?.toString(),
      photoBase64: data['photoBase64'] as String?,
      age: data['age']?.toString(),
      gender: data['gender']?.toString(),
      emergencyContact: emergencyContact,
      homeClinicId: (data['clinicId'] ?? data['homeClinicId'] ?? '')
          .toString()
          .trim(),
      homeClinicName: effectiveClinicName,
      activeQueueToken: tokenCode,
      activeQueueStatus: tokenStatus,
      activeQueueService: tokenService,
      activeQueueDoctor: tokenDoctor,
      activeQueueJoinedAt: tokenJoinedAt,
      memberSince: memberSince,
      totalBookings: totalBookings ?? (data['visitsCount'] as int? ?? 0),
      totalQueues: totalQueues ?? (data['queuesCount'] as int? ?? 0),
      isVerified: isVerified,
      status: finalStatus,
      userType: userType,
      createdAt: createdAt,
      city: (data['city'] ?? data['region'] ?? '').toString().trim().isNotEmpty
          ? (data['city'] ?? data['region']).toString().trim()
          : null,
      notes:
          (data['notes'] ?? data['clinicalNotes'] ?? '')
              .toString()
              .trim()
              .isNotEmpty
          ? (data['notes'] ?? data['clinicalNotes']).toString().trim()
          : null,
      lastActive: lastActive,
    );
  }

  static String _monthName(int month) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return (month >= 1 && month <= 12) ? m[month - 1] : 'Jan';
  }
}
