import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/notifications/data/services/patient_notification_mapper.dart';
import 'package:patient_app/features/notifications/domain/entities/patient_notification_entity.dart';
import 'package:patient_app/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:patient_app/features/notifications/presentation/widgets/notification_empty_state.dart';
import 'package:patient_app/features/notifications/presentation/widgets/notification_filter_bar.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWidget(Widget child) =>
      MaterialApp(theme: AppTheme.darkTheme, home: Scaffold(body: child));

  group('PatientNotificationEntity & Mapper Tests', () {
    test('copyWith updates metadata and isRead cleanly', () {
      final notif = PatientNotificationEntity(
        id: 'n1',
        title: 'Token Called',
        body: 'Please proceed to Room 3',
        timestamp: DateTime(2026, 11, 24, 10, 0),
        category: PatientNotificationCategory.queue,
        route: '/live_queue',
        clinicName: 'Green Heaven Clinic',
        badgeLabel: 'Now Serving',
        isUrgent: true,
      );
      final updated = notif.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.clinicName, 'Green Heaven Clinic');
      expect(updated.badgeLabel, 'Now Serving');
      expect(updated.isUrgent, isTrue);
    });

    test('PatientNotificationMapper parses push maps and date formats', () {
      final now = DateTime.now();
      expect(PatientNotificationMapper.parseDate(now.toIso8601String()).day, now.day);
      expect(PatientNotificationMapper.parseDate(1700000000000).year, 2023);
      expect(PatientNotificationMapper.parseDate(null), isA<DateTime>());

      final push = PatientNotificationMapper.fromPushMap({
        'id': 'fcm_1',
        'title': '🔔 Token #A-004 Called!',
        'body': 'Proceed to Room 1 at Green Heaven Clinic',
        'route': '/live_queue',
        'category': 'queue',
        'clinicName': 'Green Heaven Clinic',
        'badgeLabel': 'Queue Alert',
        'isUrgent': true,
        'timestampMs': now.millisecondsSinceEpoch,
      }, false);

      expect(push.category, PatientNotificationCategory.queue);
      expect(push.isPushReceived, isTrue);
      expect(push.clinicName, 'Green Heaven Clinic');
      expect(push.badgeLabel, 'Queue Alert');
    });
  });

  group('Notification Widgets & Screen Tests', () {
    testWidgets('NotificationEmptyState displays All Caught Up state', (tester) async {
      await tester.pumpWidget(wrapWidget(const NotificationEmptyState()));
      expect(find.text('All Caught Up!'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('NotificationFilterBar includes all 5 filters and responds to tap', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        wrapWidget(
          StatefulBuilder(
            builder: (context, setState) => NotificationFilterBar(
              selectedIndex: selected,
              counts: const [5, 2, 1, 1, 1],
              onFilterChanged: (idx) => setState(() => selected = idx),
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Queue Alerts'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Announcements'), findsOneWidget);

      await tester.tap(find.text('Bookings'));
      await tester.pumpAndSettle();
      expect(selected, 2);
    });

    testWidgets('NotificationsScreen renders hero banner, push badge, and filters feed', (tester) async {
      final items = [
        PatientNotificationEntity(
          id: 'q1',
          title: '🔔 Token #A-007 Called!',
          body: 'Dr. Priya is ready to see you.',
          timestamp: DateTime.now(),
          category: PatientNotificationCategory.queue,
          route: '/live_queue',
          clinicName: 'Green Heaven Clinic',
          badgeLabel: 'Now Serving',
          isUrgent: true,
          isPushReceived: true,
        ),
        PatientNotificationEntity(
          id: 'b1',
          title: '✅ Appointment Confirmed · Dr. Rahul',
          body: '26 Nov 2026 at 10:30 AM · Smile Dental',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          category: PatientNotificationCategory.booking,
          route: '/my_bookings',
          clinicName: 'Smile Dental',
          badgeLabel: 'Confirmed',
          isRead: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: NotificationsScreen(streamOverride: Stream.value(items), initialPushEnabled: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live Push & Status Alerts'), findsOneWidget);
      expect(find.text('● Status Bar On'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);
      expect(find.byTooltip('Test System Alert'), findsOneWidget);
      expect(find.text('FCM Push'), findsOneWidget);
      expect(find.text('Green Heaven Clinic'), findsOneWidget);

      await tester.tap(find.text('Bookings'));
      await tester.pumpAndSettle();
      expect(find.text('✅ Appointment Confirmed · Dr. Rahul'), findsOneWidget);
      expect(find.text('🔔 Token #A-007 Called!'), findsNothing);

      await tester.tap(find.byTooltip('Test System Alert'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
