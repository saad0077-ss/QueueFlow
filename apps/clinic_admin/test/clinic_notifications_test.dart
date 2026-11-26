import 'package:clinic_admin/features/notifications/data/services/clinic_notifications_read_store.dart';
import 'package:clinic_admin/features/notifications/domain/entities/clinic_notification_item.dart';
import 'package:clinic_admin/features/notifications/presentation/widgets/clinic_notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Clinic Notifications Tests', () {
    final sampleItem = ClinicNotificationItem(
      id: 'test_1',
      title: 'Token #A-024 (waiting)',
      body: 'John Doe joined General Consultation',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: ClinicNotificationType.queue,
      routeNav: 'Live Queue',
      isRead: false,
    );

    test('ClinicNotificationItem copyWith works', () {
      final read = sampleItem.copyWith(isRead: true);
      expect(read.isRead, isTrue);
      expect(read.title, sampleItem.title);
      expect(read.id, sampleItem.id);
    });

    testWidgets('ClinicNotificationTile renders and handles tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ClinicNotificationTile(
              item: sampleItem,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Token #A-024 (waiting)'), findsOneWidget);
      expect(find.text('John Doe joined General Consultation'), findsOneWidget);
      expect(find.text('5m ago'), findsOneWidget);

      await tester.tap(find.byType(ClinicNotificationTile));
      expect(tapped, isTrue);
    });

    test('ClinicNotificationsReadStore persists per-clinic read state across sign-out and remote sync', () async {
      SharedPreferences.setMockInitialValues({});
      final store = ClinicNotificationsReadStore();

      await store.markRead('clinic_a', ['ticket_1', 'appt_2']);
      expect(await store.loadReadIds('clinic_a'), containsAll(['ticket_1', 'appt_2']));
      expect(await store.loadReadIds('clinic_b'), isEmpty);

      // Simulate sign-out + fresh browser/session where local prefs are empty,
      // then sign back in and receive clinicData from Firestore.
      store.resetSessionCache();
      SharedPreferences.setMockInitialValues({});
      final restored = await store.loadReadIds(
        'clinic_a',
        clinicData: {
          'readNotificationIds': ['ticket_1', 'appt_2', 'supp_3'],
        },
      );
      expect(restored, containsAll(['ticket_1', 'appt_2', 'supp_3']));
    });
  });
}
