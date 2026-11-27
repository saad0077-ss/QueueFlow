import '../../domain/entities/favorite_clinic_entity.dart';

class FavoriteClinicModel extends FavoriteClinicEntity {
  const FavoriteClinicModel({
    required super.id,
    required super.name,
    required super.department,
    required super.rating,
    required super.reviewsCount,
    required super.address,
    required super.initials,
    super.accentColorHex,
    super.distance,
    super.waitingCount,
    super.estWaitTime,
    super.openHours,
    super.topDoctor,
    super.phone,
    super.iconEmoji,
    super.imageUrl,
    super.imageVersion,
    super.topDoctorPhotoUrl,
  });

  factory FavoriteClinicModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString().trim();
    final id = (json['id'] ?? '').toString().trim();
    final rawImgUrl = (json['imageUrl'] ?? json['image'] ?? json['photoUrl'])
        ?.toString()
        .trim();

    return FavoriteClinicModel(
      id: id,
      name: name,
      department: (json['department'] ?? json['category'] ?? '').toString().trim(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ??
          (json['reviews'] as num?)?.toInt() ??
          0,
      address: (json['address'] ?? '').toString().trim(),
      initials: (json['initials'] as String?)?.trim().isNotEmpty == true
          ? json['initials'].toString().trim()
          : _computeInitials(name),
      accentColorHex: json['accentColorHex'] as int? ?? 0xFF2563EB,
      distance: (json['distance'] ?? '').toString().trim(),
      waitingCount: (json['waitingCount'] as num?)?.toInt() ??
          (json['activeQueueCount'] as num?)?.toInt() ??
          0,
      estWaitTime: (json['estWaitTime'] ?? json['currentWait'] ?? '')
          .toString()
          .trim(),
      openHours: (json['openHours'] ?? '').toString().trim(),
      topDoctor: (json['topDoctor'] ?? json['doctorName'] ?? '').toString().trim(),
      phone: (json['phone'] ?? '').toString().trim(),
      iconEmoji: (json['iconEmoji'] ?? _emojiFor(id, name)).toString(),
      imageUrl: (rawImgUrl?.isNotEmpty ?? false) ? rawImgUrl : null,
      imageVersion: (json['imageVersion'] as num?)?.toInt() ?? 0,
      topDoctorPhotoUrl: (json['topDoctorPhotoUrl'] ?? '').toString().trim(),
    );
  }

  static String _computeInitials(String name) {
    if (name.isEmpty) return 'CL';
    return name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  static String _emojiFor(String id, String name) {
    final lower = name.toLowerCase();
    if (id.contains('dent') || lower.contains('dent')) return '🦷';
    if (id.contains('sunrise') || lower.contains('sunrise')) return '🌅';
    if (lower.contains('pediatric') || lower.contains('child')) return '👶';
    if (lower.contains('skin') || lower.contains('derma')) return '🔬';
    return '🏥';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'department': department,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'address': address,
    'initials': initials,
    'accentColorHex': accentColorHex,
    'distance': distance,
    'waitingCount': waitingCount,
    'estWaitTime': estWaitTime,
    'openHours': openHours,
    'topDoctor': topDoctor,
    'phone': phone,
    'iconEmoji': iconEmoji,
  };
}
