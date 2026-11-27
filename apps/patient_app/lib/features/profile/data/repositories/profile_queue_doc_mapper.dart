import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/patient_queue_history_entity.dart';

class ProfileQueueDocMapper {
  const ProfileQueueDocMapper._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static List<PatientQueueHistoryEntity> mapAndSort(
    Iterable<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return sortList(docs.map(mapDoc).toList());
  }

  static List<PatientQueueHistoryEntity> sortList(
    List<PatientQueueHistoryEntity> list,
  ) {
    list.sort((a, b) {
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      final da = a.joinedAt ?? DateTime(2000);
      final db = b.joinedAt ?? DateTime(2000);
      return db.compareTo(da);
    });
    return list;
  }

  static PatientQueueHistoryEntity mapDoc(
    DocumentSnapshot<Map<String, dynamic>> d,
  ) => mapRaw(d.id, d.data() ?? const {});

  static PatientQueueHistoryEntity mapRaw(
    String id,
    Map<String, dynamic> data,
  ) {
    final status = (data['status'] ?? 'waiting').toString().trim().toLowerCase();
    final isActive =
        status != 'completed' && status != 'cancelled' && status != 'canceled';
    final joinedAt = parseDate(data['joinedAt']) ??
        parseDate(data['checkedInAt']) ??
        parseDate(data['createdAt']);
    final rawTime = (data['joinedTime'] ?? data['timeRaw'] ?? '')
        .toString()
        .trim();
    final rawDate = (data['date'] ?? '').toString().trim();
    final rawClinicImg =
        (data['clinicImageUrl'] ?? data['imageUrl'])?.toString().trim();

    return PatientQueueHistoryEntity(
      id: id,
      token: (data['token'] ?? data['queueToken'] ?? data['bookingRef'] ?? 'T-001')
          .toString(),
      clinicId: (data['clinicId'] ?? '').toString(),
      clinicName: (data['clinicName'] ?? 'Clinic').toString(),
      departmentName:
          (data['departmentName'] ?? data['doctorSpecialty'] ?? 'General Medicine')
              .toString(),
      serviceName: (data['serviceName'] ?? 'General Consultation').toString(),
      doctorName: (data['doctorName'] ?? 'Attending Doctor').toString(),
      joinedTime: rawTime.isNotEmpty ? rawTime : formatTime(joinedAt),
      date: rawDate.isNotEmpty ? rawDate : formatDay(joinedAt),
      waitTime: data['waitTime']?.toString(),
      position: (data['position'] as num?)?.toInt() ?? 0,
      estWaitMin: (data['estWaitMin'] as num?)?.toInt() ?? 15,
      status: status,
      isActive: isActive,
      joinedAt: joinedAt,
      clinicImageUrl:
          (rawClinicImg?.isNotEmpty ?? false) ? rawClinicImg : null,
      clinicImageVersion:
          (data['clinicImageVersion'] as num?)?.toInt() ??
          (data['imageVersion'] as num?)?.toInt() ??
          0,
      doctorPhotoUrl:
          (data['doctorPhotoUrl'] ?? data['photoUrl'] ?? '').toString().trim(),
    );
  }

  static DateTime? parseDate(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  static String formatTime(DateTime? dt) {
    if (dt == null) return 'Recent';
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    return '$h12:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
  }

  static String formatDay(DateTime? dt) {
    if (dt == null) return 'Recent';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }
}
