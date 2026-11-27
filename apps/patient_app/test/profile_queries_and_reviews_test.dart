import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/data/models/patient_review_model.dart';
import 'package:patient_app/features/profile/data/repositories/profile_queue_doc_mapper.dart';
import 'package:patient_app/features/profile/domain/entities/patient_review_entity.dart';
import 'package:patient_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:patient_app/features/profile/presentation/pages/my_reviews_screen.dart';
import 'package:patient_app/features/profile/presentation/widgets/reviews/my_reviews_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class _FakeReviewRepo implements ProfileRepository {
  final List<PatientReviewEntity> reviews;
  _FakeReviewRepo(this.reviews);

  @override
  Future<List<PatientReviewEntity>> getUserReviews() async => reviews;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('PatientReviewModel.fromJson parses Timestamp createdAt cleanly', () {
    final model = PatientReviewModel.fromJson({
      'clinicId': 'sunrise',
      'clinicName': 'Sunrise Family Care',
      'rating': 4.0,
      'comment': 'Great care and fast service.',
      'createdAt': Timestamp.fromDate(DateTime(2026, 11, 24, 14, 30)),
    }, docId: 'r-1');

    expect(model.clinicName, 'Sunrise Family Care');
    expect(model.doctorName, '');
    expect(model.rating, 4);
    expect(model.date, '24 Nov 2026');
  });

  test('ProfileQueueDocMapper maps createdAt and sorts active first', () {
    final now = DateTime.now();
    final active = ProfileQueueDocMapper.mapRaw('t-active', {
      'token': 'A-09',
      'clinicId': 'c1',
      'clinicName': 'Green Heaven Clinic',
      'status': 'waiting',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 10))),
    });
    final done = ProfileQueueDocMapper.mapRaw('t-done', {
      'token': 'A-01',
      'clinicId': 'c1',
      'clinicName': 'Sunrise Care',
      'status': 'Completed',
      'joinedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
    });

    final sorted = ProfileQueueDocMapper.sortList([done, active]);
    expect(sorted.length, 2);
    expect(sorted[0].id, 't-active');
    expect(sorted[0].isActive, isTrue);
    expect(sorted[0].date, 'Today');
    expect(sorted[1].id, 't-done');
    expect(sorted[1].isActive, isFalse);
  });

  testWidgets('MyReviewsScreen loads fresh reviews and renders clinic + doctor reviews', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeReviewRepo(const [
      PatientReviewEntity(
        id: 'rev-c1',
        clinicId: 'c1',
        clinicName: 'Green Heaven Clinic',
        doctorName: '',
        rating: 5,
        clinicRating: 5,
        doctorRating: 0,
        tags: ['Clean Facility'],
        comment: 'Spotless waiting lounge.',
        isAnonymous: false,
        date: '24 Nov 2026',
        service: 'Clinic Experience',
      ),
      PatientReviewEntity(
        id: 'docrev-1',
        clinicId: 'c2',
        clinicName: 'Sunrise Family Care',
        doctorName: 'Dr. Priya Sharma',
        doctorSpecialty: 'General Physician',
        rating: 4,
        clinicRating: 4,
        doctorRating: 4,
        tags: [],
        comment: 'Very thorough checkup.',
        isAnonymous: false,
        date: '23 Nov 2026',
        service: 'Doctor Consultation',
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: BlocProvider(
          create: (_) => MyReviewsBloc(repository: repo, initialReviews: const []),
          child: const MyReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Green Heaven Clinic'), findsOneWidget);
    expect(find.text('Sunrise Family Care'), findsOneWidget);
    expect(find.text('Dr. Priya Sharma'), findsOneWidget);
    expect(find.text('"Spotless waiting lounge."'), findsOneWidget);
    expect(find.text('"Very thorough checkup."'), findsOneWidget);
  });
}
