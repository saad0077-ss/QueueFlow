import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/services/notification_local_store.dart';
import 'package:patient_app/core/services/notification_payload_helper.dart';
import 'package:patient_app/features/notifications/data/services/notification_firestore_read_sync.dart';
import 'package:patient_app/features/notifications/domain/entities/patient_notification_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Patient Notification Read Persistence & Tray Deduplication', () {
    test('isolates read IDs per uid, migrates legacy reads once, and restores from Firestore data', () async {
      SharedPreferences.setMockInitialValues({
        'patient_read_notification_ids': ['legacy_ticket_1'],
      });
      final sync = NotificationFirestoreReadSync();

      // Migrates pre-existing legacy read ID to first signed-in user and cleans legacy key.
      expect(await sync.loadMergedReadIds('user_a'), contains('legacy_ticket_1'));
      expect(await sync.loadMergedReadIds('user_b'), isEmpty);

      await sync.markRead('user_a', ['ticket_1', 'appt_2', 'broad_3']);
      expect(
        await sync.loadMergedReadIds('user_a'),
        containsAll(['legacy_ticket_1', 'ticket_1', 'appt_2', 'broad_3']),
      );

      sync.resetSessionCache();
      SharedPreferences.setMockInitialValues({});
      final restored = await sync.loadMergedReadIds(
        'user_a',
        userData: {
          'readNotificationIds': ['ticket_1', 'appt_2', 'broad_3', 'supp_4'],
        },
      );
      expect(restored, containsAll(['ticket_1', 'appt_2', 'broad_3', 'supp_4']));
      expect(
        await NotificationLocalStore.getReadIds(uid: 'user_a'),
        containsAll(['ticket_1', 'appt_2', 'broad_3', 'supp_4']),
      );
    });

    test('empty emission never marks seed initialized and already-read items never claim tray keys', () async {
      SharedPreferences.setMockInitialValues({});
      await NotificationPayloadHelper.dispatchUnreadAlerts(const []);
      expect(await NotificationLocalStore.isSeedInitialized(), isFalse);

      final readRecent = PatientNotificationEntity(
        id: 'ticket_done',
        title: 'Token Completed',
        body: 'Completed',
        timestamp: DateTime.now(),
        category: PatientNotificationCategory.queue,
        route: '/live_queue',
        isRead: true,
      );
      await NotificationPayloadHelper.dispatchUnreadAlerts([readRecent]);
      expect(await NotificationLocalStore.isSeedInitialized(), isTrue);
      // Since readRecent.isRead == true, dispatchUnreadAlerts must skip claiming/showing it.
      expect(
        await NotificationLocalStore.claimAlertKey(
          NotificationPayloadHelper.alertKeyFor(readRecent),
        ),
        isTrue,
      );
    });
  });
}
