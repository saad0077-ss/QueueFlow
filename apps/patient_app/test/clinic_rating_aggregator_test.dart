import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/services/clinic_rating_aggregator.dart';
import 'package:patient_app/features/home/data/repositories/home_clinics_rating_overlay.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';

void main() {
  test('summarize returns 0 and empty star distribution when no ratings', () {
    final s = ClinicRatingAggregator.summarize(const []);
    expect(s.average, 0.0);
    expect(s.count, 0);
    expect(s.starPercents, const [0, 0, 0, 0, 0]);
  });

  test('summarize calculates accurate average and star breakdown', () {
    final s = ClinicRatingAggregator.summarize(const [5, 3, 4, 5]);
    expect(s.count, 4);
    expect(s.average, 4.25);
    expect(s.starPercents, const [50, 25, 25, 0, 0]);
  });

  test('aggregateFromMaps combines clinic and doctor reviews and matches by name fallback', () {
    final summaries = ClinicRatingAggregator.aggregateFromMaps(
      clinicReviewMaps: const [
        {'clinicId': 'green-heaven', 'rating': 3},
        {'clinicId': 'clinic-1', 'clinicName': 'Sunrise Family Care Center', 'rating': 5},
      ],
      doctorReviewMaps: const [
        {'clinicId': 'green-heaven', 'rating': 5},
        {'clinicId': 'sunrise-care', 'rating': 4},
      ],
      clinicNamesById: const {
        'green-heaven': 'Green Heaven Clinic',
        'sunrise-care': 'Sunrise Family Care Center',
      },
    );

    expect(summaries['green-heaven']?.count, 2);
    expect(summaries['green-heaven']?.average, 4.0);
    expect(summaries['sunrise-care']?.count, 2);
    expect(summaries['sunrise-care']?.average, 4.5);
  });

  test('HomeClinicsRatingOverlay.apply sets aggregated rating and marks unrated clinics as New', () {
    const clinics = [
      ClinicEntity(
        id: 'green-heaven',
        name: 'Green Heaven Clinic',
        initials: 'GH',
        category: 'General Medicine',
        rating: 3.0,
        reviewCount: 1,
        distance: '',
        city: 'Panachipara',
        address: 'Panachipara',
        phone: '999',
        consultationFee: '₹400',
        openingHours: '',
      ),
      ClinicEntity(
        id: 'sunrise-care',
        name: 'Sunrise Family Care Center',
        initials: 'SF',
        category: 'Pediatrics & Child Care',
        rating: 4.8,
        reviewCount: 5,
        distance: '',
        city: 'Panachipara',
        address: 'Panachipara',
        phone: '999',
        consultationFee: '₹400',
        openingHours: '',
      ),
    ];

    final updated = HomeClinicsRatingOverlay.apply(clinics, {
      'green-heaven': (average: 4.5, count: 2, starPercents: [50, 50, 0, 0, 0]),
    });

    expect(updated[0].rating, 4.5);
    expect(updated[0].reviewCount, 2);
    expect(updated[0].hasRatings, isTrue);
    expect(updated[1].rating, 0.0);
    expect(updated[1].reviewCount, 0);
    expect(updated[1].hasRatings, isFalse);
  });
}
