import 'package:flutter/material.dart';

class PaymentHistoryFilterOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final int count;

  const PaymentHistoryFilterOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.count,
  });
}

List<PaymentHistoryFilterOption> buildPaymentHistoryFilterOptions({
  required Color primaryColor,
  required int countAll,
  required int countQueue,
  required int countAppt,
  required int countRefunded,
}) {
  return [
    PaymentHistoryFilterOption(
      id: 'all',
      title: 'All Transactions',
      subtitle: 'Show every payment & refund',
      icon: Icons.receipt_long_rounded,
      accent: primaryColor,
      count: countAll,
    ),
    PaymentHistoryFilterOption(
      id: 'queue',
      title: 'Queue Tokens',
      subtitle: 'Walk-in live queue payments',
      icon: Icons.confirmation_number_rounded,
      accent: const Color(0xFF2563EB),
      count: countQueue,
    ),
    PaymentHistoryFilterOption(
      id: 'appointment',
      title: 'Bookings',
      subtitle: 'Scheduled doctor appointments',
      icon: Icons.calendar_month_rounded,
      accent: const Color(0xFF10B981),
      count: countAppt,
    ),
    PaymentHistoryFilterOption(
      id: 'refunded',
      title: 'Refunded',
      subtitle: 'Cancelled or credited back',
      icon: Icons.replay_rounded,
      accent: const Color(0xFF8B5CF6),
      count: countRefunded,
    ),
  ];
}
