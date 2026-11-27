import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/domain/entities/support_ticket_entity.dart';
import 'package:patient_app/features/profile/presentation/pages/help_support/concern_detail_chat_scaffold.dart';
import 'package:patient_app/features/profile/presentation/pages/help_support/concern_detail_chat_screen.dart';
import 'package:patient_app/features/profile/presentation/widgets/concern_chat/concern_chat_feed.dart';
import 'package:patient_app/features/profile/presentation/widgets/concern_chat/concern_detail_summary_card.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

SupportTicketEntity _ticket({required String status}) => SupportTicketEntity(
  id: 't1',
  ticketNumber: 'TK-7288',
  clinicId: 'c1',
  clinicName: 'QueueFlow Platform Operations',
  category: 'technical',
  subject: 'App GPS radar tracking issue',
  description: 'The queue distance radar is not updating accurately on my device.',
  status: status,
  priority: 'low',
  createdAt: '26/11/2026 7:20',
  slaNotice: '< 15m SLA',
  resolvedAt: status == 'resolved' ? 'Just now' : null,
  messages: const [
    TicketMessageEntity(
      sender: 'You',
      text: 'The queue distance radar is not updating accurately.',
      time: 'Just now',
      isUser: true,
    ),
    TicketMessageEntity(
      sender: 'System',
      text: 'Concern marked as resolved by Muhammed Saad.',
      time: 'Just now',
      isUser: false,
      senderRole: 'system',
    ),
  ],
);

Widget _scaffoldHost(SupportTicketEntity ticket) {
  final sc = ScrollController();
  final rc = TextEditingController();
  addTearDown(sc.dispose);
  addTearDown(rc.dispose);
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: ConcernDetailChatScaffold(
      ticket: ticket,
      scrollController: sc,
      replyController: rc,
      isSending: false,
      onToggleResolve: () {},
      onSendReply: () {},
      fallbackStartTimes: <String, DateTime>{},
    ),
  );
}

void main() {
  testWidgets(
    'ConcernDetailChatScreen renders successfully with ProfileFallbackProvider when no ancestor ProfileBloc exists',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ConcernDetailChatScreen(ticketId: 'test-ticket-123'),
        ),
      );
      expect(find.byType(ConcernDetailChatScreen), findsOneWidget);
      expect(find.text('Support Concern'), findsOneWidget);
    },
  );

  testWidgets('Web view renders problem + progress on left and chat on right', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_scaffoldHost(_ticket(status: 'resolved')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Step 4 of 4 • Concern Resolved'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);

    final summaryRect = tester.getRect(find.byType(ConcernDetailSummaryCard));
    final feedRect = tester.getRect(find.byType(ConcernChatFeed));
    expect(summaryRect.right, lessThan(feedRect.left));
  });

  testWidgets('Mobile view stacks summary above chat without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_scaffoldHost(_ticket(status: 'open')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Step 2 of 4 • Desk Triage'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);

    final summaryRect = tester.getRect(find.byType(ConcernDetailSummaryCard));
    final feedRect = tester.getRect(find.byType(ConcernChatFeed));
    expect(summaryRect.bottom, lessThanOrEqualTo(feedRect.top));
  });
}
