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
  });

  factory FavoriteClinicModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final id = json['id'] as String? ?? '';
    String emoji = '🏥';
    if (id.contains('dent') || name.toLowerCase().contains('dent')) {
      emoji = '🦷';
    } else if (id.contains('sunrise') ||
        name.toLowerCase().contains('sunrise')) {
      emoji = '🌅';
    } else if (name.toLowerCase().contains('pediatric') ||
        name.toLowerCase().contains('child')) {
      emoji = '👶';
    } else if (name.toLowerCase().contains('skin') ||
        name.toLowerCase().contains('derma')) {
      emoji = '🔬';
    }

    return FavoriteClinicModel(
      id: id,
      name: name,
      department:
          json['department'] as String? ??
          json['category'] as String? ??
          'General Medicine',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : 4.8,
      reviewsCount:
          (json['reviewsCount'] as num?)?.toInt() ??
          (json['reviews'] as num?)?.toInt() ??
          48,
      address: json['address'] as String? ?? 'MG Road, Indiranagar',
      initials:
          json['initials'] as String? ??
          (name.isNotEmpty
              ? name
                    .split(' ')
                    .map((w) => w.isNotEmpty ? w[0] : '')
                    .take(2)
                    .join()
                    .toUpperCase()
              : 'CF'),
      accentColorHex: json['accentColorHex'] as int? ?? 0xFF2563EB,
      distance: (json['distance'] ?? '1.2 km').toString(),
      waitingCount:
          (json['waitingCount'] as num?)?.toInt() ??
          (json['activeQueueCount'] as num?)?.toInt() ??
          3,
      estWaitTime: (json['estWaitTime'] ?? json['currentWait'] ?? '15 min')
          .toString(),
      openHours: (json['openHours'] ?? 'Open 09:00 AM – 08:00 PM').toString(),
      topDoctor: (json['topDoctor'] ?? json['doctorName'] ?? 'Dr. Priya Sharma')
          .toString(),
      phone: (json['phone'] ?? '+91 98450 11234').toString(),
      iconEmoji: (json['iconEmoji'] ?? emoji).toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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

  static List<FavoriteClinicModel> get defaultFavorites => const [
    FavoriteClinicModel(
      id: 'smile-dental',
      name: 'Smile Dental Clinic',
      department: 'Dental & Oral Surgery',
      rating: 4.9,
      reviewsCount: 120,
      address: 'Shop 4, Indiranagar 100ft Road, Bangalore',
      initials: 'SD',
      accentColorHex: 0xFF14B8A6,
      distance: '0.8 km',
      waitingCount: 2,
      estWaitTime: '12 min',
      openHours: 'Open 09:30 AM – 08:30 PM',
      topDoctor: 'Dr. Rahul Menon',
      phone: '+91 98450 22345',
      iconEmoji: '🦷',
    ),
    FavoriteClinicModel(
      id: 'sunrise-health',
      name: 'Sunrise Health Clinic',
      department: 'General & Family Medicine',
      rating: 4.8,
      reviewsCount: 85,
      address: '14/B, Koramangala 4th Block, Bangalore',
      initials: 'SH',
      accentColorHex: 0xFF2563EB,
      distance: '1.4 km',
      waitingCount: 3,
      estWaitTime: '18 min',
      openHours: 'Open 08:30 AM – 09:00 PM',
      topDoctor: 'Dr. Priya Sharma',
      phone: '+91 98450 11234',
      iconEmoji: '🌅',
    ),
    FavoriteClinicModel(
      id: 'city-care',
      name: 'CityCare General Clinic',
      department: 'Multi-Specialty & Diagnostics',
      rating: 4.7,
      reviewsCount: 64,
      address: 'Plot 22, HSR Layout Sector 1, Bangalore',
      initials: 'CC',
      accentColorHex: 0xFF8B5CF6,
      distance: '2.6 km',
      waitingCount: 5,
      estWaitTime: '25 min',
      openHours: 'Open 08:00 AM – 10:00 PM',
      topDoctor: 'Dr. Marcus Vance',
      phone: '+91 98450 33456',
      iconEmoji: '🏥',
    ),
  ];
}
