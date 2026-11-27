import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/widgets/clinic_profile_avatar.dart';
import 'package:patient_app/core/widgets/doctor_avatar.dart';
import 'package:patient_app/features/profile/data/models/favorite_clinic_model.dart';
import 'package:patient_app/features/profile/data/models/patient_review_model.dart';
import 'package:patient_app/features/profile/domain/entities/favorite_clinic_entity.dart';
import 'package:patient_app/features/profile/domain/entities/patient_review_entity.dart';
import 'package:patient_app/features/profile/presentation/widgets/favorite_clinics/favorite_clinic_card.dart';
import 'package:patient_app/features/profile/presentation/widgets/reviews/my_review_card.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

// Valid 1x1 PNG bytes encoded as base64 data URI.
const _tinyPngDataUri =
    'data:image/png;base64,'
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

void main() {
  test('models parse clinic image and doctor photo fields accurately', () {
    final review = PatientReviewModel.fromJson({
      'clinicId': 'c-1',
      'clinicName': 'Green Heaven Clinic',
      'doctorName': 'Dr. Priya Nair',
      'rating': 5,
      'clinicImageUrl': _tinyPngDataUri,
      'clinicImageVersion': 42,
      'doctorPhotoUrl': _tinyPngDataUri,
    }, docId: 'r-1');

    expect(review.clinicImageUrl, _tinyPngDataUri);
    expect(review.clinicImageVersion, 42);
    expect(review.doctorPhotoUrl, _tinyPngDataUri);

    final fav = FavoriteClinicModel.fromJson({
      'id': 'c-1',
      'name': 'Green Heaven Clinic',
      'imageUrl': _tinyPngDataUri,
      'imageVersion': 7,
      'topDoctor': 'Dr. Priya Nair',
      'topDoctorPhotoUrl': _tinyPngDataUri,
    });

    expect(fav.imageUrl, _tinyPngDataUri);
    expect(fav.imageVersion, 7);
    expect(fav.topDoctorPhotoUrl, _tinyPngDataUri);
  });

  testWidgets('MyReviewCard displays clinic and doctor images + initials fallback', (
    tester,
  ) async {
    const withPhotos = PatientReviewEntity(
      id: 'rev-1',
      clinicId: 'c-1',
      clinicName: 'Green Heaven Clinic',
      doctorName: 'Dr. Priya Nair',
      doctorSpecialty: 'General Medicine',
      rating: 4,
      doctorRating: 4,
      clinicRating: 4,
      tags: ['Clean'],
      comment: 'Helpful doctor.',
      isAnonymous: false,
      date: '24 Nov 2026',
      clinicImageUrl: _tinyPngDataUri,
      doctorPhotoUrl: _tinyPngDataUri,
    );

    const withoutPhotos = PatientReviewEntity(
      id: 'rev-2',
      clinicId: 'c-2',
      clinicName: 'Sunrise Care Center',
      doctorName: 'Dr. Rahul Sharma',
      rating: 5,
      tags: [],
      comment: '',
      isAnonymous: false,
      date: '25 Nov 2026',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                MyReviewCard(review: withPhotos, onEdit: () {}, onDelete: () {}),
                const SizedBox(height: 12),
                MyReviewCard(review: withoutPhotos, onEdit: () {}, onDelete: () {}),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ClinicProfileAvatar), findsNWidgets(2));
    expect(find.byType(DoctorPhotoAvatar), findsNWidgets(2));
    // Clinic image + Doctor image decoded as Image widgets for card 1
    expect(find.byType(Image), findsNWidgets(2));
    // Card 2 renders clean initials instead of emoji placeholders
    expect(find.text('SC'), findsOneWidget);
    expect(find.text('DR'), findsOneWidget);
  });

  testWidgets('FavoriteClinicCard displays clinic and top doctor images', (
    tester,
  ) async {
    const fav = FavoriteClinicEntity(
      id: 'c-1',
      name: 'Green Heaven Clinic',
      department: 'General Medicine',
      rating: 4.8,
      reviewsCount: 12,
      address: 'Kochi',
      initials: 'GH',
      topDoctor: 'Dr. Priya Nair',
      imageUrl: _tinyPngDataUri,
      topDoctorPhotoUrl: _tinyPngDataUri,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: FavoriteClinicCard(
              clinic: fav,
              onUnfavorite: () {},
              onBook: () {},
              onLiveQueue: () {},
              onCall: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ClinicProfileAvatar), findsOneWidget);
    expect(find.byType(DoctorPhotoAvatar), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
    expect(find.text('Dr. Priya Nair'), findsOneWidget);
  });
}
