import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/widgets/clinic_profile_avatar.dart';
import 'package:patient_app/core/widgets/doctor_avatar.dart';
import 'package:patient_app/features/profile/data/repositories/profile_queue_doc_mapper.dart';
import 'package:patient_app/features/profile/domain/entities/patient_queue_history_entity.dart';
import 'package:patient_app/features/profile/presentation/widgets/queue_history/queue_history_active_card.dart';
import 'package:patient_app/features/profile/presentation/widgets/queue_history/queue_history_completed_card.dart';
import 'package:patient_app/features/profile/presentation/widgets/queue_history/queue_history_spotlight_card.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

const _tinyPngDataUri =
    'data:image/png;base64,'
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

void main() {
  test('ProfileQueueDocMapper parses clinic and doctor image fields', () {
    final entity = ProfileQueueDocMapper.mapRaw('t-1', {
      'token': 'A-012',
      'clinicId': 'c-1',
      'clinicName': 'Green Heaven Clinic',
      'doctorName': 'Dr. Priya Nair',
      'clinicImageUrl': _tinyPngDataUri,
      'clinicImageVersion': 3,
      'doctorPhotoUrl': _tinyPngDataUri,
    });

    expect(entity.clinicImageUrl, _tinyPngDataUri);
    expect(entity.clinicImageVersion, 3);
    expect(entity.doctorPhotoUrl, _tinyPngDataUri);
  });

  testWidgets('Queue history cards display clinic and doctor images + initials fallback', (
    tester,
  ) async {
    const activeWithPhotos = PatientQueueHistoryEntity(
      id: 'q-1',
      token: 'A-012',
      clinicId: 'c-1',
      clinicName: 'Green Heaven Clinic',
      departmentName: 'General Medicine',
      serviceName: 'Consultation',
      doctorName: 'Dr. Priya Nair',
      joinedTime: '10:30 AM',
      date: 'Today',
      position: 2,
      estWaitMin: 10,
      status: 'waiting',
      isActive: true,
      clinicImageUrl: _tinyPngDataUri,
      doctorPhotoUrl: _tinyPngDataUri,
    );

    const servedWithoutPhotos = PatientQueueHistoryEntity(
      id: 'q-2',
      token: 'B-005',
      clinicId: 'c-2',
      clinicName: 'Sunrise Care Center',
      serviceName: 'Checkup',
      doctorName: 'Dr. Rahul Sharma',
      joinedTime: '09:00 AM',
      date: 'Yesterday',
      status: 'completed',
      isActive: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                QueueHistorySpotlightCard(
                  ticket: activeWithPhotos,
                  onTrackInTracker: () {},
                ),
                QueueHistoryActiveCard(item: activeWithPhotos, onTrackLive: () {}),
                QueueHistoryCompletedCard(
                  item: servedWithoutPhotos,
                  onBookAgain: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ClinicProfileAvatar), findsNWidgets(3));
    expect(find.byType(DoctorPhotoAvatar), findsNWidgets(3));
    expect(find.byType(Image), findsNWidgets(4));
    expect(find.text('SC'), findsOneWidget);
    expect(find.text('DR'), findsOneWidget);
  });
}
