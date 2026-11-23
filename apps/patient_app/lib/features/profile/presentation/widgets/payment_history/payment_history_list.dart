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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = payments[index];
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
      },
    );
  }
}
