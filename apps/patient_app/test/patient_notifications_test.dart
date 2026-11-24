import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'package:patient_app/features/notifications/domain/entities/patient_notification_entity.dart';
import 'package:patient_app/features/notifications/data/services/patient_notification_mapper.dart';
import 'package:patient_app/features/notifications/presentation/widgets/notification_empty_state.dart';
import 'package:patient_app/features/notifications/presentation/widgets/notification_filter_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('PatientNotificationEntity Tests', () {
    test('copyWith updates isRead state correctly', () {
      final notif = PatientNotificationEntity(
        id: 'n1',
        title: 'Token Called',
        body: 'Please proceed to Room 3',
        timestamp: DateTime(2026, 11, 24, 10, 0),
        category: PatientNotificationCategory.queue,
        route: '/live_queue',
        isRead: false,
      );

      final updated = notif.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.id, 'n1');
      expect(updated.title, 'Token Called');
    });

    test('PatientNotificationMapper parseDate handles multiple formats', () {
      final now = DateTime.now();
      expect(PatientNotificationMapper.parseDate(now.toIso8601String()).day, now.day);
      expect(PatientNotificationMapper.parseDate(1700000000000).year, 2023);
      expect(PatientNotificationMapper.parseDate(null), isA<DateTime>());
    });
  });

  group('Notification Widgets Tests', () {
    testWidgets('NotificationEmptyState displays All Caught Up state',
        (tester) async {
      await tester.pumpWidget(wrapWidget(const NotificationEmptyState()));

      expect(find.text('All Caught Up!'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(
        find.text(
          'You have no pending alerts right now.\nQueue token calls and booking updates will appear here in real time.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('NotificationFilterBar displays chips and responds to selection',
        (tester) async {
      int selected = 0;

      await tester.pumpWidget(
        wrapWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return NotificationFilterBar(
                selectedIndex: selected,
                onFilterChanged: (idx) {
                  setState(() => selected = idx);
                },
              );
            },
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Queue Alerts'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);

      await tester.tap(find.text('Bookings'));
      await tester.pumpAndSettle();

      expect(selected, 2);
    });
  });
}
