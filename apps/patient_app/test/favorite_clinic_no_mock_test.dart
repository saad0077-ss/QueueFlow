import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/data/models/favorite_clinic_model.dart';
import 'package:patient_app/features/profile/presentation/widgets/favorite_clinics/favorite_clinic_card.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

void main() {
  test('FavoriteClinicModel.fromJson uses empty real defaults instead of mocks', () {
    final model = FavoriteClinicModel.fromJson({
      'id': 'clinic-1',
      'name': 'Green Heaven Clinic',
    });

    expect(model.rating, 0.0);
    expect(model.reviewsCount, 0);
    expect(model.address, '');
    expect(model.distance, '');
    expect(model.waitingCount, 0);
    expect(model.estWaitTime, '');
    expect(model.openHours, '');
    expect(model.topDoctor, '');
    expect(model.phone, '');
  });

  testWidgets('FavoriteClinicCard omits mock values when clinic data is sparse',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sparse = FavoriteClinicModel.fromJson({
      'id': 'clinic-1',
      'name': 'Green Heaven Clinic',
      'department': 'General Medicine',
      'address': 'Mannar Square, Panachipara',
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: FavoriteClinicCard(
              clinic: sparse,
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
    expect(find.text('Green Heaven Clinic'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
    expect(find.text('0 waiting'), findsOneWidget);
    expect(find.text('Mannar Square'), findsOneWidget);
    expect(find.text('1.2 km'), findsNothing);
    expect(find.text('3 in queue (~15 min)'), findsNothing);
    expect(find.textContaining('09:00 AM'), findsNothing);
    expect(find.textContaining('Dr. Priya Sharma'), findsNothing);
    expect(find.text('📞'), findsNothing);
  });
}
