import 'package:awesome_notifications/awesome_notifications.dart'
    as awesome;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/services/notification_local_store.dart';
import 'package:patient_app/core/services/notification_navigator.dart';
import 'package:patient_app/core/services/notification_payload_helper.dart';
import 'package:patient_app/core/services/notification_service.dart';
import 'package:patient_app/features/notifications/domain/entities/patient_notification_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationNavigator Route Parsing & Pending Queue Tests', () {
    test('parses routes accurately', () {
      expect(NotificationNavigator.parseTargetTab('/live_queue?ticketId=1'), 1);
      expect(NotificationNavigator.parseTargetTab('/my_bookings?id=2'), 2);
      expect(NotificationNavigator.parseTargetTab('/home'), 0);
      expect(NotificationNavigator.parseTargetTab('/unknown'), isNull);
      expect(
        NotificationNavigator.parseSupportTicketId('/support_chat?ticketId=tk1'),
        'tk1',
      );
    });

    test('queues and consumes cold-start pending route once', () {
      NotificationNavigator.setPendingRoute('/live_queue?ticketId=abc');
      expect(NotificationNavigator.consumePendingRoute(), '/live_queue?ticketId=abc');
      expect(NotificationNavigator.consumePendingRoute(), isNull);
    });
  });

  group('NotificationPayloadHelper & LocalStore Tests', () {
    test('extracts typed RemoteMessage payloads for Awesome Notifications', () {
      const msg = RemoteMessage(
        messageId: 'm-123',
        notification: RemoteNotification(
          title: 'Token #A-04 Called',
          body: 'Proceed to room 1',
        ),
        data: {
          'type': 'queue_called',
          'route': '/live_queue?ticketId=t-1',
          'clinicName': 'Green Heaven Clinic',
        },
      );

      final parsed = NotificationPayloadHelper.extract(msg);
      expect(parsed.categoryKey, 'queue');
      expect(parsed.isUrgent, isTrue);
      expect(parsed.awesomeCategory, awesome.NotificationCategory.Reminder);
      expect(parsed.clinicName, 'Green Heaven Clinic');
      expect(parsed.route, '/live_queue?ticketId=t-1');
    });

    test('persists push history, read IDs, and deduplicates alert keys', () async {
      SharedPreferences.setMockInitialValues({});
      await NotificationLocalStore.recordPushEntry(
        id: 'fcm_1',
        title: 'Booking Confirmed',
        body: 'Slot confirmed at 10 AM',
        route: '/my_bookings',
        category: 'booking',
      );
      await NotificationLocalStore.markRead(['fcm_1']);

      final pushes = await NotificationLocalStore.loadPushEntries();
      final reads = await NotificationLocalStore.getReadIds();
      expect(pushes.length, 1);
      expect(pushes.first['title'], 'Booking Confirmed');
      expect(reads.contains('fcm_1'), isTrue);

      expect(await NotificationLocalStore.claimAlertKey('k1'), isTrue);
      expect(await NotificationLocalStore.claimAlertKey('k1'), isFalse);

      expect(await NotificationLocalStore.isSeedInitialized(), isFalse);
      await NotificationLocalStore.markSeedInitialized();
      expect(await NotificationLocalStore.isSeedInitialized(), isTrue);
    });

    test('alertKeyFor includes body and dispatchUnreadAlerts covers bookings & support', () async {
      SharedPreferences.setMockInitialValues({});
      final oldItem = PatientNotificationEntity(
        id: 'old_1',
        title: 'Booking Confirmed',
        body: 'Old message',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        category: PatientNotificationCategory.booking,
        route: '/my_bookings',
      );
      final freshBooking = PatientNotificationEntity(
        id: 'bk_1',
        title: 'Appointment Approved',
        body: 'Tomorrow 10:00 AM',
        timestamp: DateTime.now(),
        category: PatientNotificationCategory.booking,
        route: '/my_bookings',
        clinicName: 'Smile Dental',
      );
      final supportReply = PatientNotificationEntity(
        id: 'sup_1',
        title: 'Support Update',
        body: 'Initial ticket opened',
        timestamp: DateTime.now(),
        category: PatientNotificationCategory.support,
        route: '/support_chat?ticketId=sup_1',
      );

      final supportReplyUpdated = PatientNotificationEntity(
        id: 'sup_1',
        title: 'Support Update',
        body: 'Clinic replied: Bring ID card',
        timestamp: supportReply.timestamp,
        category: PatientNotificationCategory.support,
        route: '/support_chat?ticketId=sup_1',
      );

      expect(
        NotificationPayloadHelper.alertKeyFor(supportReply) !=
            NotificationPayloadHelper.alertKeyFor(supportReplyUpdated),
        isTrue,
      );

      await NotificationPayloadHelper.dispatchUnreadAlerts([oldItem, freshBooking]);
      expect(await NotificationLocalStore.isSeedInitialized(), isTrue);
      expect(await NotificationLocalStore.claimAlertKey(NotificationPayloadHelper.alertKeyFor(oldItem)), isFalse);
      expect(await NotificationLocalStore.claimAlertKey(NotificationPayloadHelper.alertKeyFor(freshBooking)), isFalse);

      // Subsequent dispatch (simulating closed-app wakeup) does not suppress unread updates.
      await NotificationPayloadHelper.dispatchUnreadAlerts([supportReply]);
      expect(await NotificationLocalStore.claimAlertKey(NotificationPayloadHelper.alertKeyFor(supportReply)), isFalse);

      expect(await NotificationService.sendTestAlert(), isFalse);
    });
  });
}
