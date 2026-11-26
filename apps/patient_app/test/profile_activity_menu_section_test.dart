import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/domain/entities/patient_profile_entity.dart';
import 'package:patient_app/features/profile/domain/entities/patient_queue_history_entity.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:patient_app/features/profile/presentation/widgets/profile_tab/profile_activity_menu_section.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

void main() {
  testWidgets(
    'ProfileActivityMenuSection renders crisp single-line labels on 360px phone',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const profile = PatientProfileEntity(
        id: 'u1',
        name: 'Test User',
        initials: 'TU',
        email: 'test@example.com',
        phone: '+91 9876543210',
        healthId: 'QF-1',
        dob: '01 Jan 1995',
        memberSince: '2026',
        loyaltyCredits: 0,
        emergencyContactName: '',
        emergencyContactRelation: '',
        emergencyContactPhone: '',
        bp: '',
        sugar: '',
        weight: '',
        height: '',
        bmi: '',
        allergies: [],
        insuranceProvider: '',
        insurancePolicyNo: '',
        insuranceValidTill: '',
        insuranceCoverage: '',
        darkMode: true,
        visitsCount: 1,
        favoritesCount: 0,
        reviewsCount: 0,
      );

      final state = ProfileState(
        status: ProfileStatus.loaded,
        profile: profile,
        queueHistory: const [
          PatientQueueHistoryEntity(
            id: 'q1',
            token: 'GH-OJ-004',
            clinicId: 'c1',
            clinicName: 'Green Heaven Clinic',
            serviceName: 'Orthopedic Assessment',
            joinedTime: '10:00 AM',
            date: '25 Nov 2026',
            status: 'waiting',
            isActive: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ProfileActivityMenuSection(state: state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      for (final label in [
        'Live Queue',
        'Tokens & status',
        'Booking History',
        'Your appointments',
        'Payment History',
        'Receipts & refunds',
        'My Reviews',
        'Ratings & feedback',
        'Favorite Clinics',
        'Saved clinics',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      for (final verbose in [
        'Joined Live Queue History',
        'Tokens, live triage wait times & status',
        'Upcoming, completed & past appointments',
        'Consultation fees, receipts & refunds',
        'My Ratings & Reviews',
        'Clinic feedback & verified ratings',
        'Bookmarked healthcare centers',
      ]) {
        expect(find.text(verbose), findsNothing);
      }
      expect(find.text('● GH-OJ-004 Active'), findsOneWidget);
    },
  );
}
