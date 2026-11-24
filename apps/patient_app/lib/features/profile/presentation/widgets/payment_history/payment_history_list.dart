import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';

import '../../../domain/entities/patient_payment_item_entity.dart';
import 'payment_history_card.dart';
import 'payment_receipt_modal.dart';

class PaymentHistoryList extends StatelessWidget {
  final List<PatientPaymentItemEntity> payments;

  const PaymentHistoryList({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isGrid = constraints.maxWidth >= 768;
        if (!isGrid) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) => _buildCard(ctx, payments[idx]),
          );
        }

        final maxCols = constraints.maxWidth >= 1150 ? 3 : 2;
        final columns = payments.length < maxCols
            ? math.max(1, payments.length)
            : maxCols;
        final rows = <List<PatientPaymentItemEntity>>[];
        for (var i = 0; i < payments.length; i += columns) {
          rows.add(
            payments.sublist(i, (i + columns).clamp(0, payments.length)),
          );
        }

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var j = 0; j < columns; j++) ...[
                    if (j > 0) const SizedBox(width: 16),
                    Expanded(
                      child: j < row.length
                          ? _buildCard(context, row[j])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, PatientPaymentItemEntity item) {
    return PaymentHistoryCard(
      payment: item,
      onViewReceipt: () => PaymentReceiptModal.show(context, item),
      onDownloadReceipt: () {
        AppSnackBar.showSuccess(
          context,
          message: 'Receipt ${item.receiptNo} downloaded as PDF',
        );
      },
    );
  }
}
