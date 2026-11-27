import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/presentation/widgets/payment_history/payment_history_filter_dialog.dart';
import 'package:patient_app/features/profile/presentation/widgets/payment_history/payment_history_search_bar.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

void main() {
  testWidgets(
    'PaymentHistorySearchBar filter button opens dialog and applies/resets cleanly at 360px',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var activeFilter = 'all';
      var query = 'Smile';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Padding(
                padding: const EdgeInsets.all(16),
                child: PaymentHistorySearchBar(
                  query: query,
                  hasActiveFilter: activeFilter != 'all',
                  onChanged: (v) => setState(() => query = v),
                  onClear: () => setState(() => query = ''),
                  onFilterTap: () => PaymentHistoryFilterDialog.show(
                    context,
                    activeFilter: activeFilter,
                    countAll: 3,
                    countQueue: 1,
                    countAppt: 2,
                    countRefunded: 1,
                    onApply: (next) => setState(() => activeFilter = next),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('payment_history_filter_button')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Filter Transactions'), findsOneWidget);
      expect(find.text('Queue Tokens'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Refunded'), findsOneWidget);

      await tester.tap(find.byKey(const Key('payment_filter_option_queue')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply Filter'));
      await tester.pumpAndSettle();

      expect(activeFilter, 'queue');

      await tester.tap(find.byKey(const Key('payment_history_filter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(activeFilter, 'all');
      expect(tester.takeException(), isNull);
    },
  );
}
