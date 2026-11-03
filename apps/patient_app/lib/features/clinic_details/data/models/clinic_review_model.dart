import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_review_item.dart';

class ClinicReviewModel extends ClinicReviewItem {
  const ClinicReviewModel({
    required super.id,
    required super.patientName,
    required super.initials,
    required super.rating,
    required super.date,
    required super.comment,
    super.tags,
    super.doctor,
    super.verified,
    super.helpfulCount,
  });

  factory ClinicReviewModel.fromFirestore(DocumentSnapshot doc) {
    final map = (doc.data() as Map<String, dynamic>?) ?? {};
    return ClinicReviewModel.fromMap(map, id: doc.id);
  }

  factory ClinicReviewModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final name = (map['patientName'] ?? map['userName'] ?? 'Patient').toString().trim();
    String initials = 'PT';
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    final rawTags = (map['tags'] as List<dynamic>?) ?? [];

    return ClinicReviewModel(
      id: id ?? map['id'] ?? '',
      patientName: name,
      initials: (map['initials'] ?? initials).toString(),
      rating: (map['rating'] as num?)?.toInt() ?? 5,
      date: _formatDate(map['createdAt']) ?? (map['date'] ?? 'Recent').toString(),
      comment: (map['comment'] ?? '').toString(),
      tags: rawTags.map((e) => e.toString()).toList(),
      doctor: (map['doctor'] ?? map['doctorName'] ?? '').toString(),
      verified: map['verified'] as bool? ?? true,
      helpfulCount: (map['helpfulCount'] as num?)?.toInt() ?? 0,
    );
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static String? _formatDate(Object? raw) {
    if (raw is! Timestamp) return null;
    final d = raw.toDate();
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'initials': initials,
      'rating': rating,
      'date': date,
      'comment': comment,
      'tags': tags,
      'doctor': doctor,
      'verified': verified,
      'helpfulCount': helpfulCount,
    };
  }
}
