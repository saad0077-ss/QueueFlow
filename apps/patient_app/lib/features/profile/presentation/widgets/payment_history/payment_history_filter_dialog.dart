import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'payment_history_bloc.dart';
import 'payment_history_filter_dialog_chrome.dart';
import 'payment_history_filter_option.dart';
import 'payment_history_filter_option_tile.dart';

/// Modal filter dialog opened from the filter button inside the payment search bar.
class PaymentHistoryFilterDialog extends StatefulWidget {
  final String activeFilter;
  final int countAll;
  final int countQueue;
  final int countAppt;
  final int countRefunded;
  final ValueChanged<String> onApply;

  const PaymentHistoryFilterDialog({
    super.key,
    required this.activeFilter,
    required this.countAll,
    required this.countQueue,
    required this.countAppt,
    required this.countRefunded,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required String activeFilter,
    required int countAll,
    required int countQueue,
    required int countAppt,
    required int countRefunded,
    required ValueChanged<String> onApply,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => PaymentHistoryFilterDialog(
        activeFilter: activeFilter,
        countAll: countAll,
        countQueue: countQueue,
        countAppt: countAppt,
        countRefunded: countRefunded,
        onApply: onApply,
      ),
    );
  }

  static Future<void> showForBloc(
    BuildContext context,
    PaymentHistoryBloc bloc,
    PaymentHistoryState state,
  ) {
    return show(
      context,
      activeFilter: state.activeFilter,
      countAll: state.allPayments.length,
      countQueue: state.queuePayments.length,
      countAppt: state.apptPayments.length,
      countRefunded: state.refundedPayments.length,
      onApply: bloc.setFilter,
    );
  }

  @override
  State<PaymentHistoryFilterDialog> createState() =>
      _PaymentHistoryFilterDialogState();
}

class _PaymentHistoryFilterDialogState
    extends State<PaymentHistoryFilterDialog> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.activeFilter;
  }

  void _commitAndClose(String filter) {
    Navigator.of(context).pop();
    widget.onApply(filter);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final options = buildPaymentHistoryFilterOptions(
      primaryColor: colors.primary,
      countAll: widget.countAll,
      countQueue: widget.countQueue,
      countAppt: widget.countAppt,
      countRefunded: widget.countRefunded,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PaymentHistoryFilterDialogHeader(
                  onClose: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < options.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  PaymentHistoryFilterOptionTile(
                    option: options[i],
                    isSelected: _selectedFilter == options[i].id,
                    onTap: () =>
                        setState(() => _selectedFilter = options[i].id),
                  ),
                ],
                const SizedBox(height: 16),
                PaymentHistoryFilterDialogActions(
                  onReset: () => _commitAndClose('all'),
                  onApply: () => _commitAndClose(_selectedFilter),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
