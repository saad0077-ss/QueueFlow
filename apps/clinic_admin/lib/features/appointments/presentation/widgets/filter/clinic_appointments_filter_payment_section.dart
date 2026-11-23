import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicAppointmentsFilterPaymentSection extends StatelessWidget {
  final String selectedPayment;
  final ValueChanged<String> onSelectPayment;

  const ClinicAppointmentsFilterPaymentSection({
    super.key,
    required this.selectedPayment,
    required this.onSelectPayment,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'id': 'all',
        'title': 'All Payments',
        'sub': 'Any payment state',
        'icon': '💳',
      },
      {'id': 'paid', 'title': 'Paid', 'sub': 'Settled fee', 'icon': '🟢'},
      {'id': 'due', 'title': 'Due', 'sub': 'Pending at desk', 'icon': '⏳'},
      {
        'id': 'refunded',
        'title': 'Refunded',
        'sub': 'Cancelled & refunded',
        'icon': '↩️',
      },
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSel = selectedPayment == opt['id'];
            return SizedBox(
              width: w,
              child: AppFilterSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectPayment(opt['id']!),
                emojiIcon: opt['icon'],
                title: opt['title']!,
                subtitle: opt['sub']!,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
