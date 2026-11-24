import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/presentation/pages/help_support/concern_detail_chat_screen.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

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

      // Verify that it built without throwing ProviderNotFoundException
      expect(find.byType(ConcernDetailChatScreen), findsOneWidget);
      expect(find.text('Support Concern'), findsOneWidget);
    },
  );
}
